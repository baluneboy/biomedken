#!/usr/bin/env python

import datetime
from MySQLdb import *
from _mysql_exceptions import *
from pims.config.conf import get_db_params

# FIXME add logging feature

# TODO class this up (c'mon man)
_SCHEMA, _UNAME, _PASSWD = get_db_params('pimsquery')

# FIXME this needs scrubbing on jimmy for yoda (and maybe new stored procedure/Routine)
def db_insert_handbook(fname, title, regime, hbcat, author='Ken Hrovat', host='localhost', user=_UNAME, passwd=_PASSWD, db='pimsdoc'):
    """Attempt db_insert_handbook MySQL routine and output flag_ok boolean and a message."""
    pubdate = datetime.datetime.now().strftime('%Y-%m-%d')
    #command = "call insert_handbook('" + title + "','" + fname + "','" + author + "','" + pubdate + "','" + regime + "'," + str(hbcat) + ",'" + title + "');"
    try:
        
        con = Connection(host=host, user=user, passwd=passwd, db=db)
        cursor = con.cursor()
        #cursor.callproc('insert_handbook', (title,fname,author,pubdate,regime,hbcat,title) )
        cursor.callproc('prototype', (title,fname) )
        cursor.close()
        con.close()
        flag_ok = True
        msg = 'okay db_insert_handbook'
        
    except MySQLdb.Error, e:
        
        flag_ok = False
        msg = "MySQLdb error db_insert_handbook %d: %s" % (e.args[0], e.args[1])

    return flag_ok, msg
    
def demo():
    if db_insert_handbook('hb_vib_vehicle_A_Nice_Enough_Title.pdf', 'A Nice Enough Title', 'vibratory', 2):
        print 'okay fine'
    else:
        print 'oh dear'
    
if __name__ == "__main__":
    demo()