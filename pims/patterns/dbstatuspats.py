# a robust line from dbstatus.py output
#-------------------------------------------------------------
#\s*(?P<computer>\w+(?:-\w+)*)\s+(?P<table>.*)\s+(?P<count>\d+)\s+(?P<mintime>None|0|\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(?P<maxtime>None|0|\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(?P<age>[+-]?\d+)
_DBSTATUSLINE_PATTERN = (
    "\s*"                                                         # zero or more spaces
    "(?P<computer>\w+(?:-\w+)*)\s+"                               # computer name (possibly hyphenated like mr-hankey) space
    "(?P<sensor>\w+(?:-\w+)*)\s+"                                 # table name space
    "(?P<count>\d+)\s+"                                           # count space
    "(?P<mintime>None|0|\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+"  # mintime space
    "(?P<maxtime>None|0|\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+"  # maxtime space
    "(?P<age>[+-]?\d+)"                                           # age
    )