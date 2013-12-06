#!/usr/bin/env python

from obspy.db.client import Client

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