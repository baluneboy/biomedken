#!/usr/bin/env python

#Another point: format() being a function, it can be used as argument in other functions:

from datetime import datetime,timedelta

L = [12, 45, 78, 784, 2, 69, 1254]
print L
print map('#{}'.format,L)
print ' '.join(map('{:>6}'.format, L))

once_upon_a_time = datetime(2010, 7, 1, 12, 0, 0)
delta = timedelta(days=13, hours=8,  minutes=20)
gen =(once_upon_a_time +x*delta for x in xrange(4))
print '\n'.join(map('{:%Y-%m-%d %H:%M:%S}'.format, gen))
