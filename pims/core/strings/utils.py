import re
from datetime import datetime
from dateutil.parser import parse
from pims.patterns.handbookpdfs import _SENSOR_PATTERN

def sensor_tuple(s):
    """
    Return tuple with (sensor, suffix)
    
    Examples
    --------
    >>> sensor_tuple('121f03')
    ('121f03', None)
    >>> sensor_tuple('121f05one')
    ('121f05', 'one')
    >>> sensor_tuple('ossbtmf')
    ('ossbtmf', None)
    >>> sensor_tuple('ossraw')
    ('ossraw', None)
    >>> sensor_tuple('0bbd')
    ('0bbd', None)
    >>> sensor_tuple('0BBD')
    ('0BBD', None)
    
    """
    m = re.search( re.compile(_SENSOR_PATTERN, re.IGNORECASE), s)
    sensor = m.group('head') + m.group('tail')
    suffix = m.group('suffix') or None
    return sensor, suffix

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

def title_case_special(s, exceptions=['a', 'an', 'of', 'the', 'is', 'for', 'vs.', 'by']):
    word_list = re.split(' ', s) #re.split behaves as expected
    final = [word_list[0].capitalize()]
    for word in word_list[1:]:
        final.append(word in exceptions and word or word.capitalize())
    return " ".join(final)

if __name__ == "__main__":
    import doctest
    doctest.testmod()
