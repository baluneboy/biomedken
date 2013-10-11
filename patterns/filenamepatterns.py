import re

"""
classPatterns = (
    ( SpgxRoadmapPdf,       '.*(\d{1})(qualify|quantify)_(.*)_(.*)_(spg.)_roadmaps(.*)(\+.*){0,1}\.pdf$' ),     # .*_ossbtmf_roadmap\.pdf
    ( OssBtmfRoadmapPdf,    '.*(\d{1})(qualify|quantify).*_ossbtmf_roadmap(\+.*){0,1}\.pdf$' ),                 # .*_ossbtmf_roadmap\.pdf
    ( PcssRoadmapPdf,       '.*(\d{1})(qualify|quantify).*_pcss_roadmaps(.*)(\+.*){0,1}\.pdf$' ),               #   .*_pcss_roadmaps.*\.pdf
    ( AncillaryPdf,         '.*(\d{1})(ancillary).*\.pdf$' ),                                                   #   .*_pcss_roadmaps.*\.pdf
)
"""

def patternNotes(self):
    return """
    #===========================================================================
    #
    #yyyy_mm_dd_HH_MM_ss.sss_SENSOR_PLOTTYPE_roadmapsRATE.pdf
    #(DTOBJ, SYSTEM=SMAMS, SENSOR, PLOTTYPE={pcss|spgX}, fs=RATE, fc='unknown', LOCATION='fromdb')
    #------------------------------------------------------------
    #2013_10_01_00_00_00.000_121f02_pcss_roadmaps500.pdf
    #2013_10_01_08_00_00.000_121f05ten_spgx_roadmaps500.pdf
    #2013_10_01_08_00_00.000_121f03one_spgs_roadmaps142.pdf
    #2013_10_01_08_00_00.000_hirap_spgs_roadmaps1000.pdf
    #
    #===========================================================================
    #
    #yyyy_mm_dd_HH_ossbtmf_roadmap.pdf
    #(DTOBJ, SYSTEM=MAMS, SENSOR=OSSBTMF, PLOTTYPE=gvt3, fs=0.0625, fc=0.01, LOCATION=LAB1O2, ER1, Lockers 3,4)
    #------------------------------------------------------------
    #2013_10_01_08_ossbtmf_roadmap.pdf
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    classPatterns = (
        ( OssBtmfRoadmapPdf,    '.*(\d{1})(qualify|quantify).*_ossbtmf_roadmap(\+.*){0,1}\.pdf$' ),                 # .*_ossbtmf_roadmap\.pdf
        ( SpgxRoadmapPdf,       '.*(\d{1})(qualify|quantify)_(.*)_(.*)_(spg.)_roadmaps(.*)(\+.*){0,1}\.pdf$' ),     # .*_ossbtmf_roadmap\.pdf
        ( PcssRoadmapPdf,       '.*(\d{1})(qualify|quantify).*_pcss_roadmaps(.*)(\+.*){0,1}\.pdf$' ),               #   .*_pcss_roadmaps.*\.pdf
        ( AncillaryPdf,         '.*(\d{1})(ancillary).*\.pdf$' ),                                                   #   .*_pcss_roadmaps.*\.pdf
        )
    """
    
_RATIONAL_FORMAT = re.compile(r"""
    \A\s*                      # optional whitespace at the start, then
    (?P<sign>[-+]?)            # an optional sign, then
    (?=\d|\.\d)                # lookahead for digit or .digit
    (?P<num>\d*)               # numerator (possibly empty)
    (?:                        # followed by
       (?:/(?P<denom>\d+))?    # an optional denominator
    |                          # or
       (?:\.(?P<decimal>\d*))? # an optional fractional part
       (?:E(?P<exp>[-+]?\d+))? # and optional exponent
    )
    \s*\Z                      # and optional whitespace to finish
""", re.VERBOSE | re.IGNORECASE)

if __name__ == '__main__':
    input_value = '   1/3 '
    m = _RATIONAL_FORMAT.match(input_value)
    if m is None:
        raise ValueError('Invalid literal for RATIONAL FORMAT: %r' % input_value)
    else:
        print '"%s/%s" matches rational format' % ( m.group('num'), m.group('denom') )
