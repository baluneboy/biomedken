#!/usr/bin/env python
# $Id $

from string import *
import struct
import sys
from MySQLdb import *
from time import *
from commands import *

# convert "Unix time" to "Human readable" time
def UnixToHumanTime(utime):
	fraction = utime - int(utime)
	s = split(getoutput('date -u -d "1970-01-01 %d sec" +"%%Y %%m %%d %%H %%M %%S"' % int(utime)) )
	s[5] = atoi(s[5]) + fraction
	return "%s-%s-%s %s:%s:%06.4f" % tuple(s)

# create a connection (with possible defaults), submit command, return all results
def sqlConnect(command, shost='localhost', suser='pims', spasswd='pims2000', sdb='pims'):
	try:
		con = Connection(host=shost, user=suser, passwd=spasswd, db=sdb)
		cursor = con.cursor()
		cursor.execute(command)
		results = cursor.fetchall()
		cursor.close()
		con.close()
		return results
	except MySQLError, msg:
		print msg[1]
		print 'MySQL call to %s failed, exiting' % shost
		sys.exit()

if __name__ == '__main__':
	pimsComputers = ['jimmy', 'chef', 'ike', 'butters', 'kyle', 'cartman', 'stan', 'kenny', 'timmeh', 'tweek', 'mr-hankey', 'manbearpig', 'towelie']
	myname = split(getoutput('uname -a'))[1]
	myname = split(myname, '.')[0]

	# first check to see if the computer is up
	up = {}
	for c in pimsComputers:
		result = getoutput("dbup.py %s" % c)
		if result == 'NO':
			up[c]=0
			print '%9s is DOWN' % c
		else:
			up[c]=1

	timeNow = time()
	print ' time now: ', UnixToHumanTime(timeNow)
	print '%9s %12s %8s %19s %19s %10s' % ('COMPUTER', '_____________TABLE', '___COUNT', '___________MIN-TIME', '___________MAX-TIME', '________AGE')

	for c in pimsComputers:
		if up[c]:
			n = c
			if c == myname:
				n = 'localhost' # mysql permissions require localhost if you are local

			results = sqlConnect('show tables', n)
			for i in results:
				r = sqlConnect('show columns from %s' % i[0], n)
				timeFound = 0
				for col in r:
					if col[0] == 'time':
						timeFound = 1
						break

				if timeFound:
					r = sqlConnect('select count(time) from %s' % i[0], n)
					count = r[0][0]
					if count==0:
						minTime=0
						maxTime=0
						age=time() # time now
					else:
						# get three values in one pass in case slow database is not indexed
						r = sqlConnect('select max(time), from_unixtime(min(time)), from_unixtime(max(time)) from %s' % i[0], n)
						maxTimeF = r[0][0]
						minTime = r[0][1]
						maxTime = r[0][2]
						age = time() - maxTimeF

					print '%9s %18s %8d %19s %19s %11d' % (c, i[0], count, minTime, maxTime, age)
