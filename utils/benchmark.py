#!/usr/bin/env python

from time import time

## simple timing-based benchmark class
#BENCH_TOTAL = 0
#BENCH_COUNT = 0
#def benchmark(startTime):
#    global BENCH_COUNT, BENCH_TOTAL
#    BENCH_COUNT = BENCH_COUNT + 1
#    BENCH_TOTAL = BENCH_TOTAL + (time() - startTime)

# simple timing-based benchmark
class Benchmark(object):
    """simple timing-based benchmark"""
    
    def __init__(self, label):
        self.label = label
        self.seconds = 0.0
        self.count = 0
        
    def __str__(self):
        avg = self.get_avg()
        fmt = 'benchmark {0:s}: n = {1:d}, avg = {2:.1f}, total = {3:.1f}s'
        return fmt.format(self.label, self.count, avg, self.seconds)
                
    def start(self):
        self.start_time = time()
        
    def get_avg(self):
        self.count += 1
        self.seconds += time() - self.start_time
        return self.seconds / self.count

def demo():
    from time import sleep
    bm = Benchmark('demo')
    for i in range(5):
        bm.start()
        sleep(i)
        print bm

if __name__ == "__main__":
    demo()