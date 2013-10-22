# For new handbook PDF type, do the following here:
# 1. Add it's name as string to __all__ near top
# 2. Add it's regex pattern info section below
# 3. Use Rx helper to verify good matching
# 4. Add new class in handbook.py

__all__ = [
    '_HANDBOOKPDF_PATTERN',
    '_OSSBTMFROADMAPPDF_PATTERN',
    '_RADGSEROADMAPNUP1X2PDF_PATTERN',    
    '_SPGXROADMAPPDF_PATTERN',
    '_ISTATPDF_PATTERN',
    '_PLOTTYPES',
    '_ABBREVS',
    '_PSD3ROADMAPPDF_PATTERN',
    '_CVFSROADMAPPDF_PATTERN',
    ]


#/tmp/pth/1qualify_notes.pdf
#---------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<notes>.*)\.pdf\Z
_HANDBOOKPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


#/tmp/pth/3qualify_2013_09_01_121f05006_irmsy_entire_month.pdf
#-------------------------------------------------------------
#.*(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>[\d_\.]*)_(?P<sensor>.*)_(?P<plot_type>imm|irms)(?P<axis>.)_(?P<notes>.*)\.pdf
_ISTATPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>[\d_\.]*)"                     # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>.*)"                            # sensor, then
    "_(?P<plot_type>imm|irms)"                  # underscore iabbrev, then
    "(?P<axis>.)"                               # axis, then
    "_(?P<notes>.*)"                            # underscore notes, then
    "\.pdf\Z"                                   # extension to finish
    )


#/tmp/pth/4quantify_2013_09_28_16_radgse_roadmapnup1x2.pdf
#---------------------------------------------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>radgse)_roadmapnup1x2(?P<notes>.*)\.pdf\Z
_RADGSEROADMAPNUP1X2PDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>radgse)"                        # sensor, then
    "_roadmapnup1x2"                            # underscore roadmapnup1x2, then
    "(?P<notes>.*)"                             # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


#/tmp/pth/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
#---------------------------------------------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>ossbtmf)_roadmap(?P<notes>.*)\.pdf\Z
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


#/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500.pdf
#--------------------------------------------------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>.*)_(?P<plot_type>\w*)(?P<axis>.)_roadmaps(?P<sample_rate>[0-9]*[p\.]?[0-9]+)(?P<notes>.*)\.pdf\Z
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


#/tmp/4qualify_2013_10_08_13_35_00_es03_psd3_compare_msg_wv3fans.pdf
#-------------------------------------------------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>.*)_(?P<plot_type>\w*)(?P<axis>.)_(?P<notes>.*)\.pdf\Z
_PSD3ROADMAPPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>.*)"                            # sensor, then
    "_(?P<plot_type>psd)"                       # underscore spg, then
    "(?P<axis>.)"                               # axis, then
    "_(?P<notes>.*)"                            # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


#/tmp/5quantify_2013_10_08_13_35_00_es03_cvfs_msg_wv3fans_compare.pdf
#-------------------------------------------------------------------
#.*/(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>.*)_(?P<plot_type>\w*)(?P<axis>.)_(?P<notes>.*)\.pdf\Z
_CVFSROADMAPPDF_PATTERN = (
    ".*/"                                       # path at the start, then
    "(?P<page>\d{1})"                           # a digit, then
    "(?P<subtitle>qualify|quantify)"            # enum for subtitle, then
    "_"                                         # underscore, then
    "(?P<timestr>.*)"                           # timestr, then    
    "_"                                         # underscore, then
    "(?P<sensor>.*)"                            # sensor, then
    "_(?P<plot_type>cvf)"                       # underscore spg, then
    "(?P<axis>.)"                               # axis, then
    "_(?P<notes>.*)"                            # notes, then
    "\.pdf\Z"                                   # extension to finish
    )


#121f03one, hirap, ossbtmf
#-------------------------
#\A(?P<head>121f0|hira|oss|0bb)(?P<tail>btmf|raw|\w{1})(?P<suffix>one|ten|006)?\Z
_SENSOR_PATTERN = (
    "\A(?P<head>121f0|es0|hira|oss|0bb|rad)"    # known head at the start of string, then
    "(?P<tail>btmf|raw|gse|\w{1})"              # btmf, raw, or single alphanumeric
    "(?P<suffix>one|ten|006)?\Z"                # zero or one enum for suffix to finish string
    )


_PLOTTYPES = {
    'gvt':   'Acceleration vs. Time',
    'psd':   'Power Spectral Density',
    'spg':   'Spectrogram',
    'pcss':  'PCSA',
    'cvf':   'Cumulative RMS vs. Frequency',
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
    input_value = '/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_vehicle_Cygnus_Capture_Install/4quantify_2013_09_28_16_radgse_roadmapnup1x2.pdf'
    m = re.match( re.compile(_RADGSEROADMAPNUP1X2PDF_PATTERN), input_value)
    if m is None:
        raise ValueError('Invalid literal for PATTERN: %r' % input_value)
    else:
        print 'timestr: %s' % m.group('timestr')

if __name__ == "__main__":
    demo_hbfpat()
