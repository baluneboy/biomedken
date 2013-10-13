import re

__all__ = [
    '_HANDBOOKPDF_PATTERN',
    '_OSSBTMFROADMAPPDF_PATTERN',
    '_SPGXROADMAPPDF_PATTERN',    
    ]

_HANDBOOKPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify|ancillary)"  # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


_OSSBTMFROADMAPPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>ossbtmf)"                       # sensor, then
    "_roadmap"                                  # underscore roadmap, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


_SPGXROADMAPPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>.*)"                            # sensor, then
    "_spg"                                      # underscore spg, then
    "(?P<axis>.)"                               # axis, then
    "_roadmaps"                                 # underscore roadmaps, then
    "(?P<sampleRate>[0-9]*[p\.]?[0-9]+)"        # zero or more digits, zero or one pee or dot, one or more digit, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


    #yyyy_mm_dd_HH_MM_ss.sss_SENSOR_PLOTTYPE_roadmapsRATE.pdf
    #(DTOBJ, SYSTEM=SMAMS, SENSOR, PLOTTYPE={pcss|spgX}, fs=RATE, fc='unknown', LOCATION='fromdb')
    #------------------------------------------------------------
    #2013_10_01_00_00_00.000_121f02_pcss_roadmaps500.pdf
    #2013_10_01_08_00_00.000_121f05ten_spgx_roadmaps500.pdf
    #2013_10_01_08_00_00.000_121f03one_spgs_roadmaps142.pdf
    #2013_10_01_08_00_00.000_hirap_spgs_roadmaps1000.pdf


    #yyyy_mm_dd_HH_ossbtmf_roadmap.pdf
    #(DTOBJ, SYSTEM=MAMS, SENSOR=OSSBTMF, PLOTTYPE=gvt3, fs=0.0625, fc=0.01, LOCATION=LAB1O2, ER1, Lockers 3,4)
    #------------------------------------------------------------
    #2013_10_01_08_ossbtmf_roadmap.pdf


if __name__ == '__main__':
    input_value = '   1/3 '
    m = _RATIONAL_PATTERN.match(input_value)
    if m is None:
        raise ValueError('Invalid literal for RATIONAL FORMAT: %r' % input_value)
    else:
        print '"%s/%s" matches rational format' % ( m.group('num'), m.group('denom') )

    input_value = '/tmp/1qualify_yes.pdf'
    m = _HANDBOOKPDF_PATTERN.match(input_value)
    if m is None:
        raise ValueError('Invalid literal for HANDBOOKPDF FORMAT: %r' % input_value)
    else:
        print '"%s" matches handbook pdf format' % m.group(0)