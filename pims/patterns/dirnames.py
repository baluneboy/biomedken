
__all__ = [
    '_HANDBOOKDIR_PATTERN',
    ]

#\A(?P<parentdir>.*)/hb_(?P<regime>vib|qs)_(?P<category>\w+?)_(?P<title>.*)$
_HANDBOOKDIR_PATTERN = (
    "\A(?P<parentdir>.*)/hb_"                   # parentdir slash hb underscore to start string
    "(?P<regime>vib|qs)_"                       # enum for regime underscore, then
    "(?P<category>\w+?)_"                       # non-greedy alphanum for category underscore, then
    "(?P<title>.*)\Z"                           # any title to finish string
    )

if __name__ == '__main__':
    import re
    input_value = '/tmp/path/hb_vib_vehicle_One_two'
    m = re.compile(_HANDBOOKDIR_PATTERN).match(input_value)
    if m is None:
        raise ValueError('Invalid literal for _HANDBOOKDIR_PATTERN: %r' % input_value)
    else:
        print '"%s" matches _HANDBOOKDIR_PATTERN' % input_value
        print m.group('regime')
        print m.group('category')
        print m.group('title')
