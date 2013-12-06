#!/usr/bin/env python

from obspy.db.client import Client

def quick_test():
    from sqlalchemy import create_engine
    # 'mysql+mysqldb://<user>:<password>@<host>[:<port>]/<dbname>'
    # 'mysql://username:password@serverlocation/mysqldb_databasename?charset=utf8&use_unicode=0'
    engine = create_engine('mysql://pims:pims2000@localhost/pims?charset=utf8&use_unicode=0')
    connection = engine.connect()
    result = engine.execute("select time from 121f03 order by time desc limit 9")
    for row in result:
        print "time:", row['time']
    r2 = engine.execute('select from_unixtime(time) as gmt from 121f03 order by time desc limit 6')
    for r in r2:
        print "GMT:", r['gmt']
    result.close()
    r2.close()
    
quick_test()
raise SystemExit

class PimsClient(Client):
    """
    Client for a database created by PIMS packetGrabber (instead of obspy.db).
    """
    def __init__(self, *args, **kwargs):
        super(PimsClient, self).__init__(*args, **kwargs)
        """
        Initializes the client.

        :type url: string, optional
        :param url: A string that indicates database dialect and connection
            arguments. See
            http://docs.sqlalchemy.org/en/latest/core/engines.html for more
            information about database dialects and urls.
            
        :type session: class:`sqlalchemy.orm.session.Session`, optional
        :param session: An existing database session object.
        
        :type debug: boolean, optional
        :param debug: Enables verbose output.
        """
        super(PimsClient, self).__init__(*args, **kwargs)
        self.extra_stuff = 'extra_stuff'