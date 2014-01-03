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
        
    
