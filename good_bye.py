import operator
from itertools import *

def prod(iterable):
    "Multiply elements of iterable."
    return reduce(operator.mul, iterable, 1)