#!/usr/bin/env python

import datetime
from MySQLdb import *
from _mysql_exceptions import *
from pims.config.conf import get_db_params

# FIXME add logging feature

# TODO class this up (c'mon man)
_SCHEMA, _UNAME, _PASSWD = get_db_params('pimsquery')

# FIXME did this one kinda quick, so scrub it
class HandbookQueryFilename(object):
    """Query yoda for handbook filename (should be none or one)."""
    def __init__ (self, filename, host='localhost', user=_UNAME, passwd=_PASSWD, db='pimsdoc', table='Testing'):
        self.filename = filename
        self.host = host
        self.user = user
        self.passwd = passwd
        self.db = db
        self.table = table
        self.file_exists = self._file_exists()
        
    def _file_exists(self):
        """Establish db connection."""
        _db_conn = connect(host=self.host, user=self.user, passwd=self.passwd, db=self.db)
        files = self._query_file(_db_conn)
        _db_conn.close()
        if len(files) > 0:
            return True
        else:
            return False

    def _query_file(self, db_conn):
        """query for filename"""
        c = db_conn.cursor() 
        self._query_string = 'SELECT * FROM %s.%s where FileName = "%s";' % (self.db, self.table, self.filename)
        c.execute(self._query_string)
        s = c.fetchall()
        L = [a[0] for a in list(s)]
        return L

# FIXME this needs scrubbing on jimmy for yoda (and maybe new stored procedure/Routine)
def db_insert_handbook(fname, title, regime, hbcat, author='Ken Hrovat', host='localhost', user=_UNAME, passwd=_PASSWD, db='pimsdoc'):
    """Attempt db_insert_handbook MySQL routine and output flag_ok boolean and a message."""
    pubdate = datetime.datetime.now().strftime('%Y-%m-%d')
    #command = "call insert_handbook('" + title + "','" + fname + "','" + author + "','" + pubdate + "','" + regime + "'," + str(hbcat) + ",'" + title + "');"
    err_msg = None

    # check for pre-existing filename    
    hbcf = HandbookQueryFilename(fname)
    if hbcf.file_exists:
        return "Database problem %s already exists in one of the records" % fname
    
    try:
        con = Connection(host=host, user=user, passwd=passwd, db=db)
        cursor = con.cursor()
        #cursor.callproc('insert_handbook', (title,fname,author,pubdate,regime,hbcat,title) )
        cursor.callproc('prototype', (title,fname) )
        cursor.close()
        con.close()
        
    except MySQLdb.Error, e:
        
        err_msg = "MySQLdb error db_insert_handbook %d: %s" % (e.args[0], e.args[1])

    return err_msg


def demo():
    #if db_insert_handbook('hb_vib_vehicle_A_Nice_Enough_Title.pdf', 'A Nice Enough Title', 'vibratory', 2):
    #    print 'okay fine'
    #else:
    #    print 'oh dear'
    hbcf = HandbookQueryFilename('hb_vib_vehicle_Big_Bang.pdf')
    print hbcf.file_exists()
    
if __name__ == "__main__":
    demo()