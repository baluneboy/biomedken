#!/usr/bin/env python

"""
A simple utility to replace "flex", "ext", "sup", "pro" with pos/neg signs.

Kenneth Hrovat, 2010
"""
import sys, re
import csv

# Utilities
def replaceAngleWord(old,new,str):
    txt = re.sub(r"(\d{1,})\s*(" + old + ")", new + r" \1", str);
    return txt

def replaceALL(str):
    str = replaceAngleWord(r"flex", "NEGATIVE", str);
    str = replaceAngleWord(r"ext", "POSITIVE", str);
    return str

# Main
if __name__ == "__main__":
    reader = csv.reader(open(sys.argv[1]),delimiter=",")
    for row in reader:
        #print "ROW[-1] IS:" + '"' + row[-1] + '"'
        for item in row[:-1]:
            item = replaceALL(item);
            print item + ", ",
        print replaceALL(row[-1]) + "\n"