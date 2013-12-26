#!/usr/bin/env python
"""
Some hopefully useful classes and functions.
"""
from collections import MutableMapping
import inspect
import re

class TransformedDict(MutableMapping):
    """
    A dictionary that applies an arbitrary key-altering
    function before accessing the keys.
    """

    def __init__(self, *args, **kwargs):
        self.store = dict()
        self.update(dict(*args, **kwargs))  # use the free update to set keys

    def __getitem__(self, key):
        return self.store[self.__keytransform__(key)]

    def __setitem__(self, key, value):
        self.store[self.__keytransform__(key)] = value

    def __delitem__(self, key):
        del self.store[self.__keytransform__(key)]

    def __iter__(self):
        return iter(self.store)

    def __len__(self):
        return len(self.store)

    def __keytransform__(self, key):
        # key transform code goes here
        return key

class LowerKeysTransformedDict(TransformedDict):
    """Transform keys to lowercase."""
    def __keytransform__(self, key):
        return key.lower()

# one way to return variable name
def varname(p):
    """one way to return variable name"""
    for line in inspect.getframeinfo(inspect.currentframe().f_back)[3]:
          m = re.search(r'\bvarname\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)', line)
          if m:
            return m.group(1)

def demo():
    d = LowerKeysTransformedDict( [ ('Test', 1), ('camelCase', 'dogma') ] )
    d['piNg'] = 'pong'
    for k,v in d.iteritems():
        print k, v
    
    assert d.get('TEST') is d['test']   # free get
    assert 'TeSt' in d                  # free __contains__
                                        # free setdefault, __eq__, and so on
    
if __name__ == "__main__":
    demo()
    