#!/usr/bin/env python

import bz2
file=r"c:\temp\trashtest.txt"
f=open(file, "w")
f.write(bz2.compress("mypassword"))
f.close()
w = open(file, "r")
password = bz2.decompress(w.read())
w.close()
print password  