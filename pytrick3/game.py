#!/usr/bin/python

# TODO
# - layout (top.mid,bot) 3 rows with 9 cols for this trick

import sys
import random
import pygame
import config

from pygame.locals import *
from copy import copy
from operator import itemgetter

import Image, ImageOps, ImageDraw, ImageFont, ImageEnhance
from collections import deque
import numpy as np

#from nonguitrick import non_gui_trick

def get_list(L, zero_pad=False):
    if zero_pad:
        fmtstr = '{0:>03}'
    else:
        fmtstr = '{0:>3}'
    return ' '.join(map(fmtstr.format, L))

class Mouse(pygame.sprite.DirtySprite):
    def __init__(self, filename):
        super(Mouse, self).__init__()
        pygame.mouse.set_visible(False)
        self.load_image(filename)
        self.default = self.image
        self.rect = self.image.get_rect()
        self.dirty = 2

    def load_image(self, filename=None):
        if filename == None:
            self.image = self.default
        else:
            self.image = pygame.image.load(filename).convert_alpha()
        self.rect = self.image.get_rect()

    def set_image(self, image=None):
        if image != None:
            self.image = image
            self.rect = self.image.get_rect()
        else:
            self.image = self.default
            self.rect = self.image.get_rect()

    def get_pos(self):
        return pygame.mouse.get_pos()

    def set_pos(self, position):
        pygame.mouse.set_pos(position)

    def update(self):
        self.rect.center = self.get_pos()

class Text(pygame.sprite.DirtySprite):
    def __init__(self, filename=None, size=36):
        super(Text, self).__init__()
        self.font = pygame.font.Font(filename, size)
        self.msg = None
        self.color = Color('black')
        self.antialias = True
        self.update()
        self.rect = self.image.get_rect()
        self.dirty = 2

    def set_color(self, color):
        self.color = color

    def update(self):
        if not self.msg == None:
            self.rect = self.image.get_rect(centerx=config.w/2)
            self.rect.y = 8
        self.image = self.font.render(self.msg, self.antialias, self.color)

class DebugText(Text):
    
    def __init__(self, filename='gui/font.ttf', size=24, where='top'):
        super(DebugText, self).__init__()
        self.font = pygame.font.Font(filename, size)
        self.msg = None
        self.color = Color('red')
        self.antialias = True
        self.update()
        self.rect = self.image.get_rect()
        self.dirty = 2
        self.indmap = {'top':0, 'mid':1, 'bot':2}
        self.where = where
        
    def update(self):
        if not self.msg == None:
            self.rect = self.image.get_rect(centerx=config.w/2)
            self.rect.y = self.indmap[self.where]*32 + 42
        self.image = self.font.render(self.msg, self.antialias, self.color)        

class The27Cards(object):

    def __init__(self, the_27_cards):
        self.used = the_27_cards
        self.hands = [self.used[0:9], self.used[9:18], self.used[18:27]]
        self.show_hands()

    def show_hands(self):
        hand_num = 0
        for h in self.hands:
            print 'hand #%d  [' % hand_num,
            for c in h:
                print str(c.number) + c.suit, " ", #"at", c.rect.x, c.rect.y
            print ']'
            #fmtstr = '{:>3}'
            #return ' '.join(map(fmtstr.format, str(self.used.number) + self.used.suit))            
            hand_num += 1

    def deal(self, n_players, n_cards):
        if len(self.used) != 27:
            raise Exception('Wrong number of cards, expected 27.')
        self.hands = [self.used[i::n_players] for i in range(0, n_players)]
        self.n_players = n_players
        self.n_cards = n_cards

    def pile_numbers(self, r):
        """return pile numbers based which round, r, this is"""
        a = np.array([0,1,2])
        if r in a:
            x = 3**r
            return np.tile(a, [x,9/x]).transpose().reshape(1,27).squeeze()
        else:
            raise Exception('r must be in %s' % str(a))

    def show_cards(self, r):
        """show cards horizontally, and nicely based on round, r"""
        print get_list(self.pile_numbers(r))
        print get_list(self.used)
        print '-'*len(get_list(self.used))
        
    def show_piles(self, r):
        #self.used = self.hands[0] + self.hands[1] + self.hands[2]
        print 'ROUND #%d:' % (r+1),
        print get_list(self.hands[0]), ' | ', get_list(self.hands[1]), ' | ', get_list(self.hands[2])

    def tricky_restack(self, r, order):
        """this is where the magic happens, restack based on round and ternary encoding of favorite letter"""
        victim_points_to = int(raw_input('Which stack is it in [0, 1, 2]: '))
        #print 'tricky restack put pile ', victim_points_to, ' in position ', order[r]
        new_order = [x for x in [0,1,2] if x!=victim_points_to]
        new_order.insert(order[r], victim_points_to)
        self.hands[0], self.hands[1], self.hands[2] = self.hands[new_order[0]], self.hands[new_order[1]], self.hands[new_order[2]]
        #print get_list(self.hands[0]), ' | ', get_list(self.hands[1]), ' | ', get_list(self.hands[2])
        #print ''
        self.used = self.hands[0] + self.hands[1] + self.hands[2]

    def do_the_trick(self):
        fav_letter = 'K'
        mtb = ALPHAMAP[fav_letter][0]
        order = ALPHAMAP[fav_letter][1]
        my_card = get_card_and_letter(self.used)
        print '\nFor debug, your card is "%s" and fav_letter is "%s". >> %s <<\n' % (my_card, fav_letter, mtb)
        for r in range(3):
            self.show_piles(r)
            self.tricky_restack(r,order)
            self.hands = [self.used[i::self.n_players] for i in range(0, self.n_players)]
        ind_your_card = ( order[0]*(3**2) + order[1]*(3**1) + order[2]*(3**0) )
        print 'your card is:', self.used[ind_your_card]       

class ThreeLines(object):

    def __init__(self):
        self.top = DebugText(where='top')
        self.mid = DebugText(where='mid')
        self.bot = DebugText(where='bot')
        self.text = [self.top, self.mid, self.bot]
        for t in self.text: t.msg = 'ThreeLines ' + t.where
            
    def set_debug_text(self, s):
        t = s.split('\n')
        self.top.msg = t[0]
        self.mid.msg = t[1]
        self.bot.msg = t[2]
        for t in self.text: t.update()

class Trick(object):

    def __init__(self):
        pygame.init()

        self.screen = pygame.display.set_mode((config.w, config.h), HWSURFACE|DOUBLEBUF)
        pygame.display.set_caption("The Trick")

        self.text = Text('gui/font.ttf')
        self.mouse = Mouse('gui/cursor.png')
        self.texthands = ThreeLines()

        self.background = pygame.image.load(config.path + 'background.png').convert()
        self.screen.blit(self.background, (0, 0))

        pygame.display.flip()

        self.xray_mode = True
        self.message = Message()

    def init(self):

        self.loser = False
        self.played = 0
        self.bad = 0

        self.mycard = None
        self.deck = Deck(classic=False, debug=True)
        self.table = Table(self.deck)

        self.sprites = pygame.sprite.LayeredDirty()
        self.mycards = pygame.sprite.LayeredDirty()

        self.cols = {}

        # set the spider card to lower left of table
        self.posx = (config.w-(config.n-1)*config.card_w)/2
        self.set_spidercard()

        # change y range to get 9 columns here (instead of 12)
        for y in range(1, config.n): # the ten used to be config.n
            self.cols[y] = []

        self.nrows = 3 # instead of original 4
        for x in range(1, self.nrows+1):
            for y in range(1, config.n):
                card = self.deck.pickup_one_card()
                card.set_position(config.xoffset+self.posx+(y-1)*config.card_w, config.yoffset+self.posx+config.card_h*(x-1))
                card.flip()
                self.cols[y].append(card.rect)
                self.table.add(card)
                self.sprites.add(card)

        self.the_27_cards = self.table.get_the_cards_list()
        #self.set_spidercard( card=self.the_27_cards[5] )

        self.text.visible = True
        self.text.msg = 'Press SPACE to restart or ESC to quit.'
        self.text.update()

        self.sprites.add(self.text, layer=self.sprites.get_top_layer()+1)
        self.sprites.add(self.mouse, layer=self.sprites.get_top_layer()+1)
        
        for th in self.texthands.text: self.sprites.add(th, layer=self.sprites.get_top_layer()+1)
        self.show_27_cards_by_pos()

    def set_spidercard(self, card=None):
        """ set the spider card to lower left of table """
        if card:
            n = card.number
            s = card.suit
        else:
            n = 1
            s = 'c'
        self.spidercard = SpiderCard(n, s, config.path + '{0:02}{1}.gif'.format(n, s))
        self.spidercard.set_fav_letter('K')
        self.spidercard.set_position(self.posx, 2*self.posx+2.5*config.card_h)
        self.spidercard.set_as_mine()        
        self.mycards.add(self.spidercard)
        self.sprites.add(self.spidercard)
        self.table.add(self.spidercard)        

    def get_27_cards_3_lines(self):
        pos = []
        for i, c in zip(range(27), self.the_27_cards):
            pos.append( ( str(c.number) + c.suit, i, c.rect.x, c.rect.y ) )
        order_by_pos = sorted(pos, key=itemgetter(3,2))
        line1 = get_list([ t[0] for t in order_by_pos[0:9] ])
        line2 = get_list([ t[0] for t in order_by_pos[9:18] ])
        line3 = get_list([ t[0] for t in order_by_pos[18:27] ])
        return '\n'.join([line1,line2,line3])

    def run(self, screen=None):
        self.quit = 0
        clock = pygame.time.Clock()
        while not self.quit:
            clock.tick(500) # changed 60 to 500
            self.loop()

    def bad_card(self, card):
        self.bad = self.bad+1
        self.posx = (config.w-(config.n-1)*config.card_w)/2
        card.set_position(config.w-self.posx-self.bad*config.card_w, 2*self.posx+4*config.card_h)
        self.sprites.add(card)

    def show_27_cards_by_pos(self):
        self.texthands.set_debug_text( self.get_27_cards_3_lines() )
        
    def loop(self):

        if self.played == 13*4-4:
            self.message.set_message('winner')
            self.sprites.add(self.message)
        else:
            if self.bad==4:
                self.loser = True
                self.message.set_message('loser')
                self.sprites.add(self.message)

        if self.mycard != None:
            if self.mycard.number == config.n:
                tmp = self.mycard
                self.mycard.kill()
                self.mycard = None
                self.mouse.set_image()
                self.bad_card(tmp)

        for event in pygame.event.get():
            if event.type == QUIT:
                pygame.quit()
                sys.exit()
            elif event.type == MOUSEMOTION:
                pass
            elif event.type == MOUSEBUTTONUP:
                pass
            elif event.type == MOUSEBUTTONDOWN:
                self.on_mouse_button_down(event.button)
            elif event.type == KEYUP:
                pass
            elif event.type == KEYDOWN:
                if event.key == K_ESCAPE:
                    pygame.quit()
                    sys.exit()
                if event.key == K_x:
                    self.toggle_xray_mode()
                if event.key == K_m:
                    x, y = self.mouse.get_pos()
                    for card in self.table.sprites():
                        if pygame.Rect(card.rect).collidepoint(x,y):
                            print card.number, card.suit
                if event.key == K_f:
                    print self.spidercard.get_fav_letter()
                if event.key == K_g:
                    self.message.set_message('loser')
                    self.sprites.add(self.message)
                if event.key == K_w:
                    self.message.set_message('winner')
                    self.sprites.add(self.message)
                if event.key == K_r or event.key == K_SPACE:
                    self.mouse.set_image()
                    self.init()
                if event.key == K_d:
                    self.texthands.set_debug_text('one\ntwo\nthree')
                if event.key == K_s:
                    self.shuffle(num_shuffles=5, delay_msec=1)
                    self.show_27_cards_by_pos()
                if event.key == K_t:
                    self.the_27_cards = self.table.get_the_cards_list()
                if event.key == K_a:
                    for c in self.the_27_cards:
                        c.flip()
                        self.draw()
                        pygame.time.delay(20)
                        c.flip()
                        self.draw()
                        pygame.time.delay(10)

        self.on_mouse_motion()
        self.text.update()
        self.draw()

    # FIXME is there a better way to shuffle objects (randomly move objects to new, prescribed set of positions)    
    def shuffle(self, num_shuffles=1, delay_msec=0):
        for i in range(num_shuffles):
            # get old positions into a double-ended queue
            oldxy = deque()
            [ oldxy.append((c.rect.x, c.rect.y)) for c in self.the_27_cards ]
            # shuffle the list of 27 cards
            random.shuffle(self.the_27_cards)
            # loop to reposition via deque popping
            for c in self.the_27_cards:
                xy = oldxy.popleft()
                c.rect.x, c.rect.y = xy[0], xy[1]
            pygame.time.delay(delay_msec)
            self.draw()

    def get_cards_string(self, ind):
        L = []
        for card in self.table.sprites()[ind*9:ind*9+9]:
            L.append('{0}{1}'.format(card.number, card.suit))
            #if len(L) == 9 or len(L) == 18:
            #    L.append('\n')
        return ' '.join(map(' {0} '.format, L))

    def toggle_xray_mode(self):
        self.xray_mode = not self.xray_mode
        self.text.msg = 'Press SPACE to restart or ESC to quit.'

    def on_mouse_motion(self):
        #pass
        if self.xray_mode:
            x, y = self.mouse.get_pos()
            for card in self.table.sprites():
                if pygame.Rect(card.rect).collidepoint(x,y):
                    self.text.msg = 'X-ray mode: {0}{1}'.format(card.number, card.suit)
                    break
                else:
                    self.text.msg = 'X-ray mode: nothing to see here'

    def on_mouse_button_down(self,btn):
        x, y = self.mouse.get_pos()
        for card in self.table.sprites():
            if pygame.Rect(card.rect).collidepoint(x,y):
                if btn == 1:  # left click
                    card.flip()
                elif btn == 3: # right click
                    card.overlay_demo()
                else:
                    pass
                break
        self.draw()

    def on_mouse_button_down_left(self):
        x, y = self.mouse.get_pos()
        for card in self.table.sprites():
            if pygame.Rect(card.rect).collidepoint(x,y):
                card.flip()
                break
        self.draw()

    def get_card_and_letter(self):
        print 'click on card you want'

    def do_the_trick(self):
        fav_letter = 'K'
        mtb = config.ALPHAMAP[fav_letter][0]
        order = config.ALPHAMAP[fav_letter][1]
        print fav_letter, mtb, order
        my_card = self.get_card_and_letter()
        #print '\nFor debug, your card is "%s" and fav_letter is "%s". >> %s <<\n' % (my_card, fav_letter, mtb)
        #for r in range(3):
        #    self.show_piles(r)
        #    self.tricky_restack(r,order)
        #    self.hands = [self.used[i::self.n_players] for i in range(0, self.n_players)]
        #ind_your_card = ( order[0]*(3**2) + order[1]*(3**1) + order[2]*(3**0) )
        #print 'your card is:', self.used[ind_your_card]

    def draw(self):
        self.sprites.clear(self.screen, self.background)
        self.sprites.update()
        pygame.display.update(self.sprites.draw(self.screen))

class Table(object):

    def __init__(self, deck):
        self.deck = deck
        self.x = (config.w - (config.n-1)*config.card_w)/2
        self.y = config.h-self.x
        self.w = config.n*config.card_w
        self.h = 4*config.card_h

        self.lines = {
            1: pygame.Rect(0, self.x, self.w, config.card_h),
            2: pygame.Rect(0, config.card_h+self.x, self.w, config.card_h),
            3: pygame.Rect(0, config.card_h*2+self.x, self.w, config.card_h),
            #4: pygame.Rect(0, config.card_h*3+self.x, self.w, config.card_h)
        }

        self.suits = {}
        self.cards = pygame.sprite.LayeredDirty()

    def get_the_cards_list(self):
        return self.sprites()[1:] # skip first "spidercard"

    def add(self, card):
        self.cards.add(card)

    def get_lines(self):
        return self.lines.values()

    def suit_of_line(self, n):
        return

    def sprites(self):
        return self.cards.sprites()

class Deck(object):

    def __init__(self, classic=True, debug=False):
        self.debug = debug
        self.card_w = config.card_w
        self.card_h = config.card_h
        self.cards = []
        filename = config.path + '{0:02}{1}.gif'

        if self.debug:
            nrange = config.n
        else:
            nrange = config.n+1

        for s in config.suits:        
            for n in range(1, nrange):
                self.cards.append(Card(n, s, filename.format(n, s)))

    def pickup_one_card(self):
        if self.debug:
            card = self.cards[0]
        else:
            card = random.choice(self.cards)
        self.cards.remove(card)
        return card

class Message(pygame.sprite.DirtySprite):
    def __init__(self):
        super(Message, self).__init__()
        self.images = {
            'loser': pygame.image.load(config.path+'loser.png').convert_alpha(),
            'winner': pygame.image.load(config.path+'winner.png').convert_alpha()
        }
        self.set_message('loser')
    def set_position(self, x, y):
        self.rect.x = x
        self.rect.y = y
    def set_message(self, message):
        self.message = message
        self.image = self.images[message]
        self.rect = self.image.get_rect()
        self.dirty = 2
        #if message == 'loser':
        #    self.posx = (config.w-(config.n-1)*config.card_w)/2
        #    self.rect.x = 1 #self.posx
        #    self.rect.y = 1 #2*self.posx+4*config.card_h
        #else:
        #    self.rect.x = (config.w-self.rect.w)/2
        #    self.rect.y = (config.h-self.rect.h)/2
        self.rect.x = (config.w-self.rect.w)/2
        self.rect.y = (config.h-self.rect.h)/2
            

class Card(pygame.sprite.DirtySprite):

    def __init__(self, number, suit, filename):
        super(Card, self).__init__()
        self.filename = filename
        self.rect = pygame.Rect(0, 0, config.card_w, config.card_h)
        self.number = number
        self.suit = suit
        self.front = pygame.image.load(self.filename).convert_alpha()
        self.back = pygame.image.load(config.hidden_card_filename).convert_alpha()
        self.hidden = True
        self.image = self.back
        self.mine = False
        self.row = 0

    def reduce_opacity(self, im, opacity):
        """Returns an image with reduced opacity."""
        assert opacity >= 0 and opacity <= 1
        if im.mode != 'RGBA':
            im = im.convert('RGBA')
        else:
            im = im.copy()
        alpha = im.split()[3]
        alpha = ImageEnhance.Brightness(alpha).enhance(opacity)
        im.putalpha(alpha)
        return im

    def watermark(self, im, mark, position, opacity=1):
        """Adds a watermark to an image."""
        if opacity < 1:
            mark = self.reduce_opacity(mark, opacity)
        if im.mode != 'RGBA':
            im = im.convert('RGBA')
        # create a transparent layer the size of the image and draw the
        # watermark in that layer.
        layer = Image.new('RGBA', im.size, (0,0,0,0))
        if position == 'tile':
            for y in range(0, im.size[1], mark.size[1]):
                for x in range(0, im.size[0], mark.size[0]):
                    layer.paste(mark, (x, y))
        elif position == 'scale':
            # scale, but preserve the aspect ratio
            ratio = min(
                float(im.size[0]) / mark.size[0], float(im.size[1]) / mark.size[1])
            w = int(mark.size[0] * ratio)
            h = int(mark.size[1] * ratio)
            mark = mark.resize((w, h))
            layer.paste(mark, ((im.size[0] - w) / 2, (im.size[1] - h) / 2))
        else:
            layer.paste(mark, position)
        # composite the watermark with the layer
        return Image.composite(layer, im, layer)

    def overlay_demo(self, n_pile=9, n_order=99):
        self.dirty = 2
        im = self.pygame_to_pil_img( self.front )
        mark = Image.open('images/1024x768/overlay.png')
        draw = ImageDraw.Draw(im)
        draw.text((44, 2), '%d,%02d' % (n_pile, n_order), font=ImageFont.load_default(), fill=128)    
        self.front = self.pil_to_pygame_img( self.watermark(im, mark, 'tile', 0.5) )
        self.image = self.front

    def invert_colors(self):
        pil_image = self.pygame_to_pil_img(self.front)
        inverted_image = ImageOps.invert(pil_image)
        self.front = self.pil_to_pygame_img(inverted_image)
    
    def pygame_to_pil_img(self, pg_surface):
        imgstr = pygame.image.tostring(pg_surface, 'RGBA')
        return Image.fromstring('RGBA', pg_surface.get_size(), imgstr)
    
    def pil_to_pygame_img(self, pil_img):
        imgstr = pil_img.tostring()
        return pygame.image.fromstring(imgstr, pil_img.size, 'RGBA')

    def grayscale_front(self):
        surf = self.front
        width, height = surf.get_size()
        for x in range(width):
            for y in range(height):
                red, green, blue, alpha = surf.get_at((x, y))
                L = 0.3 * red + 0.59 * green + 0.11 * blue
                gs_color = (L, L, L, alpha)
                surf.set_at((x, y), gs_color)
        self.front = surf

    def set_as_mine(self):
        self.mine = True

    def is_mine(self):
        return self.mine

    def set_visible(self):
        if self.hidden:
            self.flip()

    def flip(self):
        self.dirty = 2
        self.hidden = not self.hidden
        if self.hidden:
            self.image = self.back
        else:
            self.image = self.front

    def set_position(self, x, y):
        self.rect.x = x
        self.rect.y = y

class SpiderCard(Card):
    
    def __init__(self, number, suit, filename):
        super(SpiderCard, self).__init__(number, suit, filename)
        self.overlay_demo()
        self.back = pygame.image.load(config.path + 'spiderback.gif').convert_alpha()
        self.image = self.back

    def set_fav_letter(self, fav_letter='K'):
        self.dirty = 2
        self.fav_letter = fav_letter
        im = self.pygame_to_pil_img( self.front )
        draw = ImageDraw.Draw(im)
        draw.text((22, 2), '%s <<<' % fav_letter, font=ImageFont.load_default(), fill=128)    
        self.front = self.pil_to_pygame_img( im )
        
    def get_fav_letter(self):
        return self.fav_letter
    
if __name__ == '__main__':

    if '-h' in sys.argv:
        print 'PySolita, version 0.9'
        print 'Usage: game.py <video_mode>, where <video_mode> is:'
        print '     -a   for 800x600'
        print '     -b   for 1024x768 (default)'
        print '     -c   for 1344x768'
        sys.exit(0)

    config.init((1024, 768))
    if '-b' in sys.argv:
        config.init((1024, 768))
        config.suits = ['c', 'd', 'h']
        config.n = 10
        config.ncards = 3*config.n
        config.xoffset =   0
        config.yoffset =  44

    trick = Trick()
    trick.init()
    trick.run()
