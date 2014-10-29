#!/usr/bin/env python

# normalize signal
def normalize(a):
    sf = max(abs(a))
    if sf == 0:
        return a
    return a / sf
