#!/usr/bin/env python

import re
import subprocess
from dateutil import parser
from pims.config.conf import get_config

def get_samsops_db_params(app_name):
    cfg = get_config()
    config_dict = cfg['apps'][app_name]
    host = config_dict['host']
    schema = config_dict['schema']
    uname = config_dict['uname']
    pword = config_dict['pword']
    return host, schema, uname, pword    
    
# Get sensitive authentication credentials for internal MySQL db query
_HOST, _SCHEMA, _UNAME, _PASSWD = get_samsops_db_params('samsquery')

class SimpleQueryAOS(object):
    """simple query for AOS/LOS"""
    def __init__(self, host, schema, uname, pword):
        self.host = host
        self.schema = schema
        self.uname = uname
        self.pword = pword        
        self.query = 'select GSE_tiss_time , IF(GSE_aos_los =0, \\"LOS\\",\\"AOS\\") as aos_los from RT_ICU_gse_data;'
        self.run_query()

    def __str__(self):
        self.run_query()
        return '%s,%s' % (self.gse_tiss_dtm, self.aos_los)

    def run_query(self):
        cmdQuery = 'mysql --skip-column-names -h %s -D %s -u %s -p%s --execute="%s"' % (self.host, self.schema, self.uname, self.pword, self.query)
        p = subprocess.Popen([cmdQuery], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        results, err = p.communicate()
        search_pat = re.compile('(.*)\t([AL]OS)').search
        m = search_pat(results)
        gse_tiss_time, aos_los = m.group(1,2)
        self.header = 'class, gse_tiss_dtm, aos_los'
        self.gse_tiss_dtm = parser.parse(gse_tiss_time)
        self.aos_los = aos_los

def demo():
    aos = SimpleQueryAOS(_HOST, _SCHEMA, _UNAME, _PASSWD)
    print aos
    
if __name__ == "__main__":
    demo()