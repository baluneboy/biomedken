#!/usr/bin/env python

import pytz
import datetime
import time
import urllib2
import json
import os
import elementtree.ElementTree as ET

#url = 'http://scores.nbcsports.msnbc.com/ticker/data/gamesMSNBC.js.asp?jsonp=true&sport=MLB&period=20140525'
url = 'http://scores.nbcsports.msnbc.com/ticker/data/gamesMSNBC.js.asp?jsonp=true&sport=%s&period=%d'

def yesterday(league):

    # one day ago
    yyyymmdd = int((datetime.datetime.now(pytz.timezone('US/Eastern'))-datetime.timedelta(days=1)).strftime("%Y%m%d"))
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
            
            # let's see what this gives as-is
            start = int(time.mktime(time.strptime('%s %d' % (gamestate_tree.get('gametime'), yyyymmdd), '%I:%M %p %Y%m%d')))
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

if __name__ == "__main__":
    
    leagues = ['MLB'] # could be: ['MLB', 'NFL', 'NBA', 'NHL']
    for league in leagues:
        print yesterday(league)
        time.sleep( 10*(len(leagues)-1) ) # so website does not get mad at us
