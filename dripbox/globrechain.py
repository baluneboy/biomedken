#!/usr/bin/env python

import sys, argparse
import glob, re

class Error(Exception):
    """Base class for exceptions in this module."""
    pass

class InputError(Error):
    """Exception raised for errors in the input."""
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return repr(self.msg)

def parseArgs(argv):
    """Parse arguments (string patterns to match)."""
    parser = argparse.ArgumentParser(description='Glob-and-match patterns.')
    parser.add_argument('globPattern', metavar='globPattern', type=str,
                       help='is a glob pattern string to be matched')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-p', metavar='regexPattern', type=str, nargs='*',
                       help='pattern string(s) to be matched')
    group.add_argument('-f', metavar='filename', type=file, nargs=1,
                       help='filename that contains text; one pattern per line')
    args = parser.parse_args()
    
    # Deal with command-line switches
    blnSimpleGlob = False
    if args.f is None and args.p is None:
        blnSimpleGlob = True

    return blnSimpleGlob, args

def showGlobResults(gr):
	"""Output results of initial glob operation."""
	for fobj in gr:
		print fobj

def searchRegex(pat,str):
	"""Search string (str) for regular expression pattern (pat)."""
	m = re.search(pat,str)
	return m

def getRegexPatternsFromFile(f):
	"""Read pattern(s) from line(s) of file."""
	print "NOT YET FROM FILE!!!!"
	return [r".*w.*"]

def regexFilterList(theList,pat):
	"""Use regex pattern to filter list."""
	newList = [m.group(0) for m in (re.search(pat,item) for item in theList) if m]
	return newList
	
def main():
	"""The main routine for globrechain."""

	# Parse args
	blnSimpleGlob, args = parseArgs(sys.argv)
	globPattern = args.globPattern

	# Do simple glob
	globResults = glob.glob(globPattern)
	
	# Simply glob results when no regex patterns input
	if blnSimpleGlob:
		showGlobResults(globResults)
		return
	
	# Fetch regex pattern(s)...
	if args.f is None:
		#...from command line
		regexPatternList = args.p
	elif args.p is None:
		#...from file
		regexPatternList = getRegexPatternsFromFile(args.f)
	
	# Apply regex pattern(s) sequentially to glob results
	results = set()
	for pattern in regexPatternList:
		for match in regexFilterList(globResults,pattern):
			results.add(match)
	
	# Dispense the results
	for r in results:
		print r

if __name__ == '__main__':
	main()
	sys.exit(0)