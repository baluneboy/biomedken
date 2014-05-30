#!/usr/bin/env python

import os
import time
import json
import pytz
import urllib2
import datetime
from dateutil import parser
import elementtree.ElementTree as ET

#url = 'http://scores.nbcsports.msnbc.com/ticker/data/gamesMSNBC.js.asp?jsonp=true&sport=MLB&period=20140525'
url = 'http://scores.nbcsports.msnbc.com/ticker/data/gamesMSNBC.js.asp?jsonp=true&sport=%s&period=%d'

class MyColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

def demo_colorize():
    print MyColors.HEADER + "HEADER: No active frommets remain. Continue?" + MyColors.ENDC    
    print MyColors.OKBLUE + "OKBLUE: No active frommets remain. Continue?" + MyColors.ENDC    
    print MyColors.OKGREEN + "OKGREEN: No active frommets remain. Continue?" + MyColors.ENDC    
    print MyColors.WARNING + "WARNING: No active frommets remain. Continue?" + MyColors.ENDC    
    print MyColors.FAIL + "FAIL: No active frommets remain. Continue?" + MyColors.ENDC    

#demo_colorize(); raise SystemExit

def yesterday(league):

    # one day ago
    yestday = datetime.datetime.now(pytz.timezone('US/Eastern'))-datetime.timedelta(days=1)
    yyyymmdd = int(yestday.strftime("%Y%m%d"))
    games = []

    try:
        f = urllib2.urlopen(url % (league, yyyymmdd))
        jsonp = f.read()
        f.close()
        json_str = jsonp.replace('shsMSNBCTicker.loadGamesData(', '').replace(');', '')
        json_parsed = json.loads(json_str)
        for game_str in json_parsed.get('games', []):
            game_tree = ET.XML(game_str)
            visiting_tree = game_tree.find('visiting-team')
            home_tree = game_tree.find('home-team')
            gamestate_tree = game_tree.find('gamestate')
            home = home_tree.get('nickname')
            away = visiting_tree.get('nickname')
            os.environ['TZ'] = 'US/Eastern'
            
            #print gamestate_tree.get('gametime')        # like "8:10 PM"
            #print type(gamestate_tree.get('gametime'))  # str
            #start = int(time.mktime(time.strptime('%s %d' % (gamestate_tree.get('gametime'), yyyymmdd), '%I:%M %p %Y%m%d')))
            start = parser.parse( yestday.strftime("%Y-%m-%d ") + gamestate_tree.get('gametime') )
            del os.environ['TZ']

            games.append({
              'league': league,
              'start': start, # convert from unixtime since 1970 (seconds)
              'home': home,
              'away': away,
              'home-score': int(home_tree.get('score')),
              'away-score': int(visiting_tree.get('score')),
              'status': gamestate_tree.get('status'), # is lower() final?
              'clock': gamestate_tree.get('display_status1'),
              'clock-section': gamestate_tree.get('display_status2')
            })
    except Exception, e:
        print e

    return games

def get_example_games():
    return [
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401124200), 'home': 'Braves', 'away': 'Red Sox', 'clock': 'Final', 'away-score': '8', 'home-score': '6', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401124200), 'home': 'Mets', 'away': 'Pirates', 'clock': 'Final', 'away-score': '5', 'home-score': '3', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401124200), 'home': 'Mets', 'away': 'Pirates', 'clock': 'Final', 'away-score': '5', 'home-score': '3', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401125700), 'home': 'Nationals', 'away': 'Marlins', 'clock': 'Final', 'away-score': '3', 'home-score': '2', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401127800), 'home': 'White Sox', 'away': 'Indians', 'clock': 'Final', 'away-score': '2', 'home-score': '6', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401127800), 'home': 'Brewers', 'away': 'Orioles', 'clock': 'Final', 'away-score': '7', 'home-score': '6', 'clock-section': '10'},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401127800), 'home': 'Twins', 'away': 'Rangers', 'clock': 'Final', 'away-score':  '7', 'home-score': '2', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401134700), 'home': 'Athletics', 'away': 'Tigers', 'clock': 'Final', 'away-score': '0', 'home-score': '10', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401134700), 'home': 'Giants', 'away': 'Cubs', 'clock': 'Final', 'away-score': '8', 'home-score': '4', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401135000), 'home': 'Mariners', 'away': 'Angels', 'clock': 'Final', 'away-score': '1', 'home-score': '5', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401135300), 'home': 'Cardinals', 'away': 'Yankees', 'clock': 'Final', 'away-score': '6', 'home-score': '4', 'clock-section': '12'},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401138300), 'home': 'Phillies', 'away': 'Rockies', 'clock': 'Final', 'away-score': '0', 'home-score': '9', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401145620), 'home': 'Blue Jays', 'away': 'Rays', 'clock': 'Final', 'away-score': '5', 'home-score': '10', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401149400), 'home': 'Royals', 'away': 'Astros', 'clock': 'Final', 'away-score': '9', 'home-score': '2', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401149400), 'home': 'Dodgers', 'away': 'Reds', 'clock': 'Final', 'away-score': '3', 'home-score': '4', 'clock-section': ''},
        {'status': 'Final', 'league': 'MLB', 'start': datetime.datetime.fromtimestamp(1401149400), 'home': 'Diamondbacks', 'away': 'Padres', 'clock': 'Final', 'away-score': '5', 'home-score': '7', 'clock-section': ''},
        ]    

if __name__ == "__main__":
    
    #leagues = ['MLB'] # could be: ['MLB', 'NFL', 'NBA', 'NHL']
    #for league in leagues:
    #    print yesterday(league)
    #    time.sleep( 10*(len(leagues)-1) ) # so website does not get mad at us
    #
    #raise SystemExit


    #games = yesterday(['MLB'])
    games = get_example_games()
    for g in games:
        if int(g['away-score']) < int(g['home-score']):
            hcolor = MyColors.OKGREEN
            acolor = '' #MyColors.FAIL
        else:
            hcolor = '' #MyColors.FAIL
            acolor = MyColors.OKGREEN
        print '\n%s%s %s%s' % (acolor, g['away'], g['away-score'], MyColors.ENDC) # FIXME LATER becomes %d for int scores
        print '%s%s %s%s' % (hcolor, g['home'], g['home-score'], MyColors.ENDC) # FIXME LATER becomes %d for int scores
        print 'Started at %s' % g['start']
