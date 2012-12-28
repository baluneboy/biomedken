#!/usr/bin/env python

import random

def randomwalk_generator():
    last, rand = 1, random.random() # initialize candidate elements
    while rand > 0.1:               # threshhold terminator
        print '*',                  # display the rejection
        if abs(last-rand) >= 0.4:   # accept the number
            last = rand             # update prior value
            yield rand              # return AT THIS POINT
        rand = random.random()      # new candidate
    yield rand

def fibonacciFirstNish(n):
    """Fibonacci numbers generator, first n-ish"""
    a, b, counter = 0, 1, 0
    while True:
        if (counter > n): return
        yield a
        a, b = b, a + b
        counter += 1

# We have to take care when we use this iterator, that a termination criterium is used!
def fibonacci():
    """Fibonacci numbers generator"""
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

#for num in randomwalk_generator():
#    print(num)

#f = fibonacciFirstN(5)
#for x in f:
#    print x,
#print
#
#f = fibonacci()
#
#counter = 0
#for x in f:
#    print x,
#    counter += 1
#    if (counter > 10): break 
#print


