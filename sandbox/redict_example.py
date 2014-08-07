#!/usr/bin/env python

import re

class redict(dict):
    def __getitem__(self, regex):
        r = re.compile(regex)
        mkeys = filter(r.match, self.keys())
        for i in mkeys:
            yield dict.__getitem__(self, i)

def method1(a, b):
    print 'method 1'
    print a, b

def method2(a, b):
    print 'method two'
    print a, b

def method3(fname):
    print 'method 3'
    print fname
    return [1, 2, 3]

def execute_method_for(s, mydict):
    # Match each regex on the string
    matches = (
        (regex.match(s), f) for regex, f in mydict.iteritems()
    )

    # Filter out empty matches, and extract groups
    matches = (
        (match.groups(), f) for match, f in matches if match is not None
    )

    # Apply all the functions
    for args, f in matches:
        f(*args)


mydict = {}
mydict[re.compile('actionname (\d+) (\d+)')] = method1
mydict[re.compile('differentaction (\w+) (\w+)')] = method2
mydict[re.compile('.*/(syslog|syslog\.\d{1})')] = method3

execute_method_for('actionname 12 3', mydict)
execute_method_for('differentaction what up', mydict)
patlist = []
execute_method_for('/home/pims/syslog', mydict, patlist)
print patlist

#red1 = redict(a='one', b='two')
#print red1
#
#keys_are_filenames = ["/home/pims/syslog", "/tmp/syslog.1", "c", "ab", "ce", "de"]
#vals_are_patlist = range(0,len(keys_are_filenames))
#red = redict(zip(keys_are_filenames, vals_are_patlist))
#
#for i in red[r".*/(syslog|syslog\.\d{1})"]:
#    print i