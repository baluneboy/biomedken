#!/usr/bin/env python

import sys
from pims.pad.amp_kpi import convert_sto2csv

#stofile = '/misc/yoda/www/plots/batch/padtimes/2014_032-062_msg_cir_fir.sto'
#stofile = '/misc/yoda/www/plots/batch/padtimes/2014_077-091_cir_fir_pwr_sams.sto'
#stofile = '/misc/yoda/www/plots/batch/padtimes/2014_077-092_cir_fir_pwr_sams2min.sto'
#stofile = '/misc/yoda/www/plots/user/sams/playback/er34_msg_cir_fir.sto'
#stofile = '/misc/yoda/www/plots/user/sams/playback/er34_msg_cir_firX.sto'
stofile = '/misc/yoda/www/plots/user/sams/playback/er34_msg_cir_fir_JanFeb.sto'

if __name__ == "__main__":
    convert_sto2csv( sys.argv[1] )
