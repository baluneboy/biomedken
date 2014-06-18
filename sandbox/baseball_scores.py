#!/usr/bin/env python

#Created by Josh Fuerst
# for question/bug reports please visit http://www.fuerstjh.com and submit through contact page.

#only been tested on python 2.7
#Currently if an error is encountered the API does not handle the exception it raises it to the caller.


#******************* USAGE *******************

#import espn_api
#espn_api.get_scores(espn_api.NCAA_FB, 'Cincinnati, Ohio State')


#****************** ABOUT ****************************

#This API connects to ESPN bottomline and parses the page to get current game scores.
#Just call the get_scores function passing in a league string (defined below)

#The return value will be a dictionary of games. Each entry will have the following structure:
        # {espn_game_id:[team1_name,team1_score,team2_name,team2_score,game_time]}

#You can also pass in team_filter. This should be a comma separated string of the team names you wish to
#get scores for
#NOTE: the team names must appear as listed on espn bottomline. To see list run once with no filter

import urllib2
from urlparse import urlparse
import pandas as pd
from cStringIO import StringIO

# LEAGUE STRINGS
NCAA_FB = 'ncf'
NFL = 'nfl'
MLB = 'mlb'
NBA = 'nba'
NHL = 'nhl'
NCAA_BB = 'mens-college-basketball'

#class Team(object):
#    
#    def __init__(self, name, score):
#        self.name = name
#        self.score = score
#    
#class GameResults(object):
#    
#    def __init__(self, team1_name, team1_score, team2_name, team2_score, time):
#        self.team1 = Team(team1_name, team1_score)
#        self.team2 = Team(team2_name, team2_score)
#        self.time = time
#        
#gr = GameResults('Parma', '6', 'Lakewood', '4', 'noon')
#print gr.team1.name, gr.team1.score
#print gr.team2.name, gr.team2.score, gr.time
#raise SystemExit

def get_scores(league, team_filter=None):

    scores = StringIO()
    my_teams = []
    STRIP = "()1234567890 "
    if team_filter:
        my_teams = team_filter.split(',')
        team_filter = team_filter.lower().split(',')

    scores.write('AwayTeam,AwayScore,HomeTeam,HomeScore,Time')

    try:
        #visit espn bottomline website to get scores as html page
        url = 'http://sports.espn.go.com/'+league+'/bottomline/scores'
        #url = "file:///home/pims/dev/programs/python/pims/sandbox/data/test_espn_scores.html"
        #url = "file:///Users/ken/dev/programs/python/pims/sandbox/data/test_espn_scores.html"
        req = urllib2.Request(url)
        response = urllib2.urlopen(req)
        page = response.read()
        
        #url decode the page and split into list
        #data = urllib2.unquote(str(page)).split('&'+league+'_s_left')
        data = urllib2.unquote(str(page)).split(league+'_s_left')

        for i in range(1,len(data)):

            #get rid of junk at beginning of line, remove ^ which marks team with ball
            main_str = data[i][data[i].find('=')+1:].replace('^','')
    
            #extract time, you can use the ( and ) to find time in string
            time =  main_str[main_str.rfind('('):main_str.rfind(')')+1].strip()
    
            #extract score, it should be at start of line and go to the first (
            score =  main_str[0:main_str.rfind('(')].strip()
    
            #extract espn gameID use the keyword gameId to find it
            gameID = main_str[main_str.rfind('gameId')+7:].strip()
    
            if gameID == '':
                #something unexpected happened
                continue
    
            #split score string into each teams string
            team1_name = ''
            team1_score = '0'
            team2_name = ''
            team2_score = '0'
    
            if (' at ' not in score):
                teams = score.split('  ')
                team1_name = teams[0][0:teams[0].rfind(' ')].lstrip(STRIP)
                team2_name = teams[1][0:teams[1].rfind(' ')].lstrip(STRIP)
                team1_score = teams[0][teams[0].rfind(' ')+1:].strip()
                team2_score = teams[1][teams[1].rfind(' ')+1:].strip()
            else:
                teams = score.split(' at ')
                team1_name = teams[0].lstrip(STRIP)
                team2_name = teams[1].lstrip(STRIP)
    
            # add this score
            scores.write('\n%s,%s,%s,%s,%s' % ( team1_name, team1_score, team2_name, team2_score, time) )
            #if not team_filter:
            #    scores.write('\n%s,%s,%s,%s,%s' % ( team1_name, team1_score, team2_name, team2_score, time) )
            #elif team1_name.lower() in team_filter or team2_name.lower() in team_filter:
            #    scores.write('\n%s,%s,%s,%s,%s' % ( team1_name, team1_score, team2_name, team2_score, time) )

    except Exception as e:
        #print(str(e))
        raise e

    scores.seek(0) # "rewind" to the beginning of the StringIO object
    df_scores = pd.read_csv(scores)  
    return df_scores, my_teams

def get_scores_as_list(team_filter):
    df_scores, teams = get_scores(MLB, team_filter)
    return df_scores, teams

def fmt_print(s):
    out = ''
    out += '\n%s\t%s' %( s[1], s[0] )
    out += '\n%s\t%s %s' % (s[3], s[2], s[4])
    out += '\n' + '-' * 55
    return out

class BaseballScores(object):
    
    def __init__(self, team_filter='Cleveland,Detroit'):
        self.dataframe, self.teams = get_scores_as_list(team_filter=team_filter)

    #say Cleveland lost at Boston by a score of 10 to 3
    #say Cleveland won at Boston by a score of 10 to 3
    #say Cleveland beat Boston by a score of 10 to 3
    #say Cleveland lost to Boston by a score of 10 to 3
    # MYTEAM {lost at, won at, lost to, beat} OPPONENT by a score of MAX to MIN
    def fmt_print(self, s):
        print type(s)
        print s
        print '----'
        out = ''
        if 'FINAL' in s['Time']:
            s1 = int(s[1])
            s3 = int(s[3])
            if s1 > s3:
                outcome = 'won'
                suffix = 'by a score of %d - %d' % (s1, s3)
            else:
                outcome = 'lost'
                suffix = 'by a score of %d - %d' % (s3, s1)                
            out += '\n%s %s at %s %s' % ( s[0], outcome, s[2], suffix )
        return out

    def __str__(self):
        s = ''
        for score in self.dataframe.iterrows():
            s += self.fmt_print(score)
        return s

if __name__ == "__main__":
    scores = BaseballScores()
    print scores.dataframe
    
#         AwayTeam  AwayScore     HomeTeam  HomeScore     Time
#0       San Diego          1      Seattle          6  (FINAL)
#1       LA Angels          9    Cleveland          3  (FINAL)
#2         Toronto          1   NY Yankees          3  (FINAL)
#3         Houston          5   Washington          6  (FINAL)
#4      Cincinnati          6   Pittsburgh          5  (FINAL)
#5     Kansas City         11      Detroit          4  (FINAL)
#6       Minnesota          1       Boston          2  (FINAL)
#7    Philadelphia          5      Atlanta          2  (FINAL)
#8    Chicago Cubs          5        Miami          6  (FINAL)
#9       Baltimore          7    Tampa Bay          5  (FINAL)
#10  San Francisco          2  Chicago Sox          8  (FINAL)
#11        NY Mets          2    St. Louis          5  (FINAL)
#12      Milwaukee          7      Arizona          5  (FINAL)
#13          Texas          6      Oakland         10  (FINAL)
#14       Colorado          2   LA Dodgers          4  (FINAL)
