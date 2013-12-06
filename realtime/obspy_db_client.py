#!/usr/bin/env python

from obspy.db.client import Client

#def quick_test():
#    # 'mysql+mysqldb://<user>:<password>@<host>[:<port>]/<dbname>'
#    # 'mysql://username:password@serverlocation/mysqldb_databasename?charset=utf8&use_unicode=0'
#    engine = create_engine('mysql://pims:pims2000@localhost/pims?charset=utf8&use_unicode=0', pool_recycle=3600)
#    connection = engine.connect()
#    result = engine.execute("select time from 121f03 order by time desc limit 11")
#    for row in result:
#        print "time:", row['time']
#    result.close()
#quick_test()
#raise SystemExit

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