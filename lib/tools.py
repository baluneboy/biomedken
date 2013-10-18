#!/usr/bin/env python
"""
Some hopefully useful bedrock tools.
"""
from collections import MutableMapping

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
        return key
    
def demo():
    class LowerKeysTransformedDict(TransformedDict):
        """Transform keys to lowercase."""
        def __keytransform__(self, key):
            return key.lower()

    z = LowerKeysTransformedDict( [ ('Test', 1), ('camelCase', 'dogma') ] )
    z['piNg'] = 'pong'
    for k,v in z.iteritems():
        print k, v
    
    assert z.get('TEST') is z['test']   # free get
    assert 'TeSt' in z                  # free __contains__
                                        # free setdefault, __eq__, and so on
    
if __name__ == "__main__":
    demo()
    