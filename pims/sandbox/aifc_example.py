#!/usr/bin/env python

import aifc
import numpy as np
import cPickle
#import scipy
#import scipy.fftpack

def demo_whale(): 
    # Program to picke whale data 
    datafolder = "../data/smalldata/"
    filename = "train28.aiff"
    filename2 = "train1.aiff"
    label = 1
    s = aifc.open(datafolder + filename)
    s2 = aifc.open(datafolder + filename)
    #s = aifc.open("../data/small_data_sample/right_whale/train28.aiff")
    nframes = s.getnframes()
    nframes2 = s2.getnframes()
    strsig = s.readframes(nframes)
    strsig2 = s2.readframes(nframes2)
    y = np.fromstring(strsig, np.short).byteswap()
    y2 = np.fromstring(strsig2, np.short).byteswap()
     
    audiolist = []
    audiolist.append(y)
    audiolist.append(y2)
    x = np.array(audiolist)
     
    labellist = [1,0]
    xlabel = np.array(labellist)
    ourtuple = (x,xlabel)
    print xlabel.shape
    print x.shape
     
    wf = open("myFile.pkl","wb")
    cPickle.dump(ourtuple, wf)
    wf.close()
     
    s.close()

if __name__ == '__main__':
    fn = '/home/pims/Downloads/wood12.aiff'
    f = aifc.open(fn, 'r')
    print "Reading", fn
    print "nchannels =", f.getnchannels()
    print "nframes   =", f.getnframes()
    print "sampwidth =", f.getsampwidth()
    print "framerate =", f.getframerate()
    print "comptype  =", f.getcomptype()
    print "compname  =", f.getcompname()
    gn = '/home/pims/Downloads/wood12_out.aiff'
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