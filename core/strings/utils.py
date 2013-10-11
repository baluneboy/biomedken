from datetime import datetime
from dateutil.parser import parse

def underscore_as_datetime(u):
    """
    Return datetime from year_month_... string.
    """
    if '.' in u:
        ystr, mstr = u.split('.')
        mstr = '.' + mstr
    else:
        ystr, mstr = u, ''
    dvec =  [int(x) for x in ystr.split('_')]
    d1 = datetime(*dvec)
    bigstr = '%s%s' % (d1, mstr)
    return parse(bigstr)
