#!/usr/bin/env python

import aifc

if __name__ == '__main__':
    fn = '/tmp/GlassLoud.aiff'
    f = aifc.open(fn, 'r')
    print "Reading", fn
    print "nchannels =", f.getnchannels()
    print "nframes   =", f.getnframes()
    print "sampwidth =", f.getsampwidth()
    print "framerate =", f.getframerate()
    print "comptype  =", f.getcomptype()
    print "compname  =", f.getcompname()
    gn = '/tmp/GlassLoud_out.aiff'
    print "Writing", gn
    g = aifc.open(gn, 'w')
    g.setparams(f.getparams())
    while 1:
        data = f.readframes(1024)
        if not data:
            break
        g.writeframes(data)
    g.close()
    f.close()
    print "Done."