#!/usr/bin/env python

import re

class RegExpDict(dict):
    def __getitem__(self, regex):
        r = re.compile(regex)
        mkeys = filter(r.match, self.keys())
        for i in mkeys:
            yield dict.__getitem__(self, i)

def method1(a, b):
    print '\nmethod 1'
    print a, b

def method2(a, b):
    print '\nmethod two'
    print a, b

def syslog_foldpat_list(fname):
    print '\nfold patterns for %s' % fname
    return [
    # Feb 25 09:59:59 icu-f01 newsyslog[29283]: logfile turned over
    '(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 newsyslog\[\d+\]: logfile turned over\n)+',
    # 2014-08-04T06:26:01.758675+00:00 icu-f01 CRON[10452]:blah
    '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}.\d{2}:\d{2} icu-f01 CRON\[\d+\]:.*\n)+',
    ]
    
def messages_foldpat_list(fname):
    print '\nfold patterns for %s' % fname
    return [
    # Feb 25 09:59:59 icu-f01 newsyslog[29283]: logfile turned over
    '(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 newsyslog\[\d+\]: logfile turned over\n)+',
    # 2014-08-04T06:26:01.758675+00:00 icu-f01 CRON[10452]:blah
    '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}.\d{2}:\d{2} icu-f01 CRON\[\d+\]:.*\n)+',
    ]

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
        return f(*args)

mydict = {}
mydict[re.compile('actionname (\d+) (\d+)')] = method1
mydict[re.compile('differentaction (\w+) (\w+)')] = method2
mydict[re.compile('.*/(syslog|syslog\.\d{1})')] = syslog_foldpat_list
mydict[re.compile('.*/(messages|messages\.\d{1})')] = messages_foldpat_list

out = execute_method_for('actionname 12 3', mydict)
out = execute_method_for('differentaction what up', mydict)
print out

fname = '/home/pims/syslog'
out = execute_method_for(fname, mydict)
print out

fname = '/home/sams-ii/messages.2'
out = execute_method_for(fname, mydict)
print out

#red1 = RegExpDict(a='one', b='two')
#print red1
#
#keys_are_filenames = ["/home/pims/syslog", "/tmp/syslog.1", "c", "ab", "ce", "de"]
#vals_are_patlist = range(0,len(keys_are_filenames))
#red = RegExpDict(zip(keys_are_filenames, vals_are_patlist))
#
#for i in red[r".*/(syslog|syslog\.\d{1})"]:
#    print i