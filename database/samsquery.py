#!/usr/bin/env python

import re
import subprocess
import datetime
from dateutil import parser
from pims.config.conf import get_config
import pandas as pd
from cStringIO import StringIO

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

#print _HOST, _SCHEMA; raise SystemExit

class EeStatusQuery(object):
    """workaround query for updating web page with EE status"""

    def __init__(self, host, schema, uname, pword):
        self.host = host
        self.schema = schema
        self.uname = uname
        self.pword = pword
        self.query = self._get_query()

    def __str__(self):
        results = self.run_query()
        return results

    def _get_query(self):
        query = 'SELECT * FROM samsnew.ee_packet ORDER BY timestamp DESC LIMIT 55;'
        return query

    def run_query(self):
        cmdQuery = 'mysql -h %s -D %s -u %s -p%s --execute="%s"' % (self.host, self.schema, self.uname, self.pword, self.query)
        p = subprocess.Popen([cmdQuery], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        results, err = p.communicate()
        return results


class SimpleQueryAOS(object):
    """simple query for AOS/LOS"""
    def __init__(self, host, schema, uname, pword):
        self.host = host
        self.schema = schema
        self.uname = uname
        self.pword = pword
        self.query = self._get_query()
        self.run_query()

    def _get_query(self):
        #query = 'select GSE_tiss_time , IF(GSE_aos_los =0, \\"LOS\\",\\"AOS\\") as aos_los from RT_ICU_gse_data;'
        query = 'select ku_timestamp , IF(ku_aos_los_status =0, \\"LOS\\",\\"AOS\\") as aos_los from gse_packet order by ku_timestamp desc limit 1;'
        return query

    def __str__(self):
        self.run_query()
        return '%s,%s' % (self.gse_tiss_dtm, self.aos_los)

    def get_aos_tisstime(self):
        self.run_query()
        return self.aos_los, self.gse_tiss_dtm

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

def workaroundRTtableEE(htmlFile):
    ee_results = EeStatusQuery(_HOST, _SCHEMA, _UNAME, _PASSWD).run_query()
    s = StringIO()
    header = ee_results[0]
    s.write(header)
    for result in ee_results[1:]:
        s.write(result)
    s.seek(0) # "rewind" to the beginning of the StringIO object
    df = pd.read_csv( s, sep='\t' )
    
    # drop unwanted columns
    unwanted_columns = ['se_id_head0', 'se_id_head1', 'time_in_sec',
                        'head0_tempX', 'head0_tempY', 'head0_tempZ',
                        'head1_tempX', 'head1_tempY', 'head1_tempZ']                        
                        
    for uc in unwanted_columns:
        df = df.drop(uc, 1)
    
    df_sorted = df.sort(['ee_id', 'timestamp'], ascending = [True, False])

    html = """<html>
                <head>
                <meta http-equiv="refresh" content="30">
                <title>SAMS EE Status</title>
                </head>
                <body>
                During AOS, this page should update about once a minute.<br>"""
                #Updated at GMT %s<br>""" % str(datetime.datetime.now())[0:19]
    html += df_sorted.groupby('ee_id').first().reset_index().to_html(
        formatters={
                'ee_id':lambda x: "%9s" % x[-3:].replace('-', ' '),
                'timestamp':lambda x: "%33s" % str(x),
        }) + "</body></html>"
    
    with open(htmlFile, 'w') as fo:
        fo.write(html)

def demo3():
    buf = StringIO()
    df = pd.DataFrame({'correlation':[0.5, 0.1,0.9], 'p_value':[0.1,0.8,0.01]})
    df.to_html('/tmp/trash2.html',
               formatters={
                'p_value':lambda x: "*%f*" % x if x<0.05 else str(x),
                'correlation':lambda x: "%3.1f" % x
                })

if __name__ == "__main__":
    workaroundRTtableEE('/misc/yoda/www/plots/user/sams/eetemp.html')
