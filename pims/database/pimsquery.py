#!/usr/bin/env python

from time import sleep
import datetime
import socket
from MySQLdb import *
from _mysql_exceptions import *
from pims.config.conf import get_db_params


# FIXME add logging feature

# FIXME need hostname for testing (db @home vs. @work)
_HOSTNAME = socket.gethostname()
if _HOSTNAME == 'jimmy':
    _HANDBOOK_HOST = 'yoda'
else:
    _HANDBOOK_HOST = 'localhost'    

# TODO class this up (c'mon man)
_SCHEMA, _UNAME, _PASSWD = get_db_params('pimsquery')

#####################################################################################
# SQL helper routines ---------------------------------------------------------------
# create a connection (with possible defaults), submit command, return all results
# try to do all connecting through this function to handle exceptions
# plugable 0-argument function to be called when idling. It can return true to stop idling. 
add_idle_function = None
def add_idle(idle_function):
    global add_idle_function
    add_idle_function = idle_function
def idle_wait(seconds = 0):
    for i in range(seconds):
        if add_idle_function:
            if add_idle_function():
                return 1
        sleep(1)
    else: # always execute at least once
        if add_idle_function:
            return add_idle_function()
    return 0
def db_connect(command, host='localhost', user=_UNAME, passwd=_PASSWD, db=_SCHEMA):
    sql_retry_time = 30
    repeat = 1
    while repeat:
        try:
            con = Connection(host=host, user=user, passwd=passwd, db=db)
            cursor = con.cursor()
            cursor.execute(command)
            results = cursor.fetchall()
            repeat = 0
            cursor.close()
            con.close()
        except MySQLError, msg:
            print 'MySQL call failed, will try again in %s seconds' % sql_retry_time
            if idle_wait(sql_retry_time):
                return []
    return results
#####################################################################################

# FIXME did this one kinda quick, so scrub it
class HandbookQueryFilename(object):
    """Query yoda for handbook filename (should be none or one)."""
    def __init__ (self, filename, host=_HANDBOOK_HOST, user=_UNAME, passwd=_PASSWD, db='pimsdoc', table='Document'):
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
def db_insert_handbook(fname, title, regime, category, host=_HANDBOOK_HOST, user=_UNAME, passwd=_PASSWD, db='pimsdoc'):
    """Attempt db_insert_handbook MySQL routine and output flag_ok boolean and a message."""
    err_msg = None

    # FIXME I do not know how to get MySQLdb callproc to work, so go with execute on this query string:
    query_str = """
    use pimsdoc;
    set @filename = '%s';   # filename
    set @title = '%s';      # title (same as source in stored procedure)
    set @regime = '%s';     # vibratory or quasi-steady
    set @category = '%s';   # crew, vehicle, or equipment
    call auto_insert_handbook(@filename, @title, @regime, @category);
    """ % (fname, title, regime, category)

    # check for pre-existing filename    
    hbcf = HandbookQueryFilename(fname)
    if hbcf.file_exists:
        return "Database problem %s already exists in one of the records" % fname
    
    try:
        con = Connection(host=host, user=user, passwd=passwd, db=db)
        cursor = con.cursor()

        # FIXME preferred, but not working: cursor.callproc('auto_insert_handbook', (fname, title, regime, category) )
        cursor.execute(query_str)
        
        cursor.close()
        con.close()
        
    except Exception, e:
        
        err_msg = "Error db_insert_handbook %s" % e.message

    return err_msg


def demo():
    err_msg = db_insert_handbook('hb_qs_crew_A_Nice_Enough_Title.pdf', 'A Nice Enough Title', 'quasi-steady', 'crew')
    
    if err_msg:
        print 'oh dear'
    else:
        print 'okay fine'
    
    #hbcf = HandbookQueryFilename('hb_vib_equipment_testing3.pdf')
    #print hbcf.file_exists
    
if __name__ == "__main__":
    demo()