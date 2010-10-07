from contextlib import contextmanager

@contextmanager
def tag(name):
	print "<%s>" % name
	yield
	print "</%s>" % name

patternset = set()
with open(r"c:\temp\trash.txt") as f:
	for line in f:
		patternset.add(line.rstrip())

with tag("mytag"):
	for i in patternset:
		print i