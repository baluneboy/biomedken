#!/usr/bin/env python

import numpy as np
from obspy.realtime import RtTrace
from obspy import read
from obspy.realtime.signal import calculateMwpMag
import matplotlib.pyplot as plt

def read_example_trace():
    """Read first trace of example SAC data file and extract contained time offset and epicentral distance of an earthquake"""
    data_trace = read('/path/to/II.TLY.BHZ.SAC')[0]
    ref_time_offset = data_trace.stats.sac.a
    epicentral_distance = data_trace.stats.sac.gcarc
    return data_trace, ref_time_offset, epicentral_distance 

def split_trace_into3(data_trace):
    """Split given trace into a list of three sub-traces"""
    traces = data_trace / 3
    return traces

def assemble_rttrace_register2procs(data_trace, ref_time_offset):
    """Assemble real time trace and register two processes"""
    rt_trace = RtTrace()
    return rt_trace, rt_trace.registerRtProcess('integrate'), rt_trace.registerRtProcess('mwpIntegral', mem_time=240,
                                                                    ref_time=(data_trace.stats.starttime + ref_time_offset),
                                                                    max_time=120, gain=1.610210e+09)

def append_and_autoprocess_packet(rt_trace, traces):
    """Append and auto-process packet data into RtTrace"""
    for tr in traces:
        processed_trace = rt_trace.append(tr, gap_overlap_check=True)

def postprocess_Mwp(rt_trace, epicentral_distance):    
    """Some post processing to get Mwp"""
    peak = np.amax(np.abs(rt_trace.data))
    mwp = calculateMwpMag(peak, epicentral_distance)
    return peak, mwp

def demo():
    """
    from http://docs.obspy.org/packages/autogen/obspy.realtime.rttrace.RtTrace.html#obspy.realtime.rttrace.RtTrace
    
    >>> demo()    
    12684 301.506 30.0855
    3 Trace(s) in Stream:
    II.TLY.00.BHZ | 2011-03-11T05:47:30.033400Z - 2011-03-11T05:51:01.384085Z | 20.0 Hz, 4228 samples
    II.TLY.00.BHZ | 2011-03-11T05:51:01.434086Z - 2011-03-11T05:54:32.784771Z | 20.0 Hz, 4228 samples
    II.TLY.00.BHZ | 2011-03-11T05:54:32.834771Z - 2011-03-11T05:58:04.185456Z | 20.0 Hz, 4228 samples
    1 2
    0.136404 8.78902911791
    
    """
    
    # 1. Read first trace of example SAC data file and extract contained time offset and epicentral distance of an earthquake:
    data_trace, ref_time_offset, epicentral_distance = read_example_trace()
    print len(data_trace), ref_time_offset, epicentral_distance

    # 2. Split given trace into a list of three sub-traces:
    traces = split_trace_into3(data_trace)
    print traces
    
    # 3. Assemble real time trace and register two processes:
    rt_trace, i1, i2 = assemble_rttrace_register2procs(data_trace, ref_time_offset)
    print i1, i2
    
    # 4. Append and auto-process packet data into RtTrace:
    append_and_autoprocess_packet(rt_trace, traces)
    
    # 5. Some post processing to get Mwp:
    peak, mwp = postprocess_Mwp(rt_trace, epicentral_distance)
    print peak, mwp
    
    # 6. Plot
    #rt_trace.plot(color='red', tick_rotation=45, number_of_ticks=6)
    
    fig, ax = plt.subplots()
    rt_trace.plot(color='red', tick_rotation=45, fig=fig)
    ymin, ymax = ax.get_ylim()
    #ax.xaxis.set_ticks(np.arange(start, end, 0.712123))
    #ax.xaxis.set_major_formatter(ticker.FormatStrFormatter('%0.1f'))
    plt.yaxis.set_ticks(np.arange(ymin, ymax, 0.02))
    plt.show()    
    
if __name__ == "__main__":
    #import doctest
    #doctest.testmod(verbose=True)
    demo()
    