#!/usr/bin/env python
# https://muharem.wordpress.com/2007/05/18/python-find-files-and-search-inside-them-find-grep/
import scriptutil as su
import re
flist = su.ffind('/tmp', shellglobs=('*.txt', '*.jpg'))
su.printr(flist)

flist = su.ffindgrep( '/tmp', namefs=(lambda s: s.endswith('.txt'), ), regexl=('tw[o0]', ) )
su.printr(flist)
print flist
