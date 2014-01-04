#!/usr/bin/env python

#from obspy import UTCDateTime, Trace
from obspy import Stream

class PadStream(Stream):
    
    def __str__(self, extended=False):
        """Returns short summary string of the current stream."""
        # get longest id
        id_length = self and max(len(tr.id) for tr in self) or 0
        out = str(len(self.traces)) + ' Trace(s) in PadStream:\n'
        if len(self.traces) <= 20 or extended is True:
            out = out + "\n".join([tr.__str__(id_length) for tr in self])
        else:
            out = out + "\n" + self.traces[0].__str__() + "\n" + \
                    '...\n(%i other traces)\n...\n' % (len(self.traces) - \
                    2) + self.traces[-1].__str__() + '\n\n[Use "print(' + \
                    'PadStream.__str__(extended=True))" to print all Traces]'
        return out    
    
    def sort(self, keys=['starttime', 'endtime'], reverse=False):
        """Sort by starttime, then by endtime (override)."""
        super(PadStream, self).sort(keys=keys, reverse=reverse)

    def span(self):
        """get times"""
        self.sort()
        span = self[-1].stats.endtime - self[0].stats.starttime
        return span

def demo_ingest(offset):
    # Trace 1: 1111
    # Trace 2:          555
    # 1 + 2  : 1111.....555
    #          123456789^
    import numpy as np
    from obspy import UTCDateTime, Trace

    tr1 = Trace(data=np.ones(3, dtype=np.int32) * 1)
    tr2 = Trace(data=np.ones(2, dtype=np.int32) * 2)
    tr2.stats.starttime = tr1.stats.endtime + ( tr1.stats.delta + offset )
    stream = PadStream([tr1, tr2])
    print "span", stream.span()
    for tr in stream: print tr
    stream.verify()
    stream.merge()
    print "span", stream.span()
    for tr in stream: print tr, "offset",
    print ( tr1.stats.delta + offset )
    print stream[-1][:], "mean=", stream[-1][:].mean(), "std=", stream[-1][:].std()
    print '-' * 100
    
if __name__ == "__main__":
    for offset in range(-200,200,50):
        demo_ingest(offset/100.0)