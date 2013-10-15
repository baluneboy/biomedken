
__all__ = [
    '_HANDBOOKPDF_PATTERN',
    '_OSSBTMFROADMAPPDF_PATTERN',
    '_SPGXROADMAPPDF_PATTERN',
    '_ISTATPDF_PATTERN',
    '_PLOTTYPES',
    '_ABBREVS',
    ]

_HANDBOOKPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify|ancillary)"  # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )

_ISTATPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>.*)"                            # sensor, then
    "_(?P<plot_type>i\w*)"                      # underscore iabbrev, then
    "(?P<axis>.)"                               # axis, then
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
    "_(?P<plot_type>\w*)"                       # underscore spg, then
    "(?P<axis>.)"                               # axis, then
    "_roadmaps"                                 # underscore roadmaps, then
    "(?P<sample_rate>[0-9]*[p\.]?[0-9]+)"       # zero or more digits, zero or one pee or dot, one or more digit, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )

_SENSOR_PATTERN = (
    "\A(?P<head>121f0|hira|oss|0bb)"                 # known head at the start of string, then
    "(?P<tail>btmf|raw|\w{1})"                  # btmf, raw, or single alphanumeric
    "(?P<suffix>one|ten)?\Z"                    # zero or one enum for suffix to finish string
    )

_PLOTTYPES = {
    'gvt':   'Acceleration vs. Time',
    'spg':   'Spectrogram',
    'pcss':  'PCSA',
    'istat': 'Interval Stat',
    '':      'empty',
}

_ABBREVS = {
'vib':  'Vibratory',
'qs':   'Quasi-Steady',
}

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

def demo_hbfpat():
    import re
    input_value = '/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_vehicle_EWIS_Port_Truss_Unknown/1qualify_2013_09_01_121f05006_spga_irmss_entire_month.pdf'
    m = re.match( re.compile(_ISTATPDF_PATTERN), input_value)
    if m is None:
        raise ValueError('Invalid literal for PATTERN: %r' % input_value)
    else:
        print 'timestr: %s' % m.group('timestr')

if __name__ == "__main__":
    demo_hbfpat()
