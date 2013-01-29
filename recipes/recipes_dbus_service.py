#!/usr/bin/env python

usage = """Usage:
python recipes_dbus_service.py &
python recipes_dbus_async_client.py"""

import datetime
import gobject
import dbus
import dbus.service
import dbus.mainloop.glib

class DemoException(dbus.DBusException):
    _dbus_error_name = 'gov.pims.DemoException'

class SamsStatus(dbus.service.Object):

    @dbus.service.method("gov.pims.SamsService",
                         in_signature='s', out_signature='as')
    def HelloWorld(self, hello_message):
        print (str(hello_message))
        return ["Hello", " from recipes_dbus_service.py", "with unique name",
                session_bus.get_unique_name()]

    @dbus.service.method("gov.pims.SamsService",
                         in_signature='', out_signature='')
    def RaiseException(self):
        raise DemoException('The RaiseException method does what you might expect.')

    @dbus.service.method("gov.pims.SamsService",
                         in_signature='b', out_signature='s')
    def show_status(self, verbose):
        s = ''
        if verbose:
            s += 'verbose output\n'
        s += "Show status at %s from recipes_dbus_service.py with unique name %s." % ( datetime.datetime.now(), session_bus.get_unique_name() )
        return s

    @dbus.service.method("gov.pims.SamsService",
                         in_signature='', out_signature='a{ss}')
    def GetDict(self):
        return {"first": "Hello Dict", "second": " from recipes_dbus_service.py"}

    @dbus.service.method("gov.pims.SamsService",
                         in_signature='', out_signature='')
    def Exit(self):
        mainloop.quit()

if __name__ == '__main__':
    
    # create session bus object for SAMS status
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    session_bus = dbus.SessionBus()
    name = dbus.service.BusName("gov.pims.SamsService", session_bus)
    object = SamsStatus(session_bus, '/SamsStatus')

    mainloop = gobject.MainLoop()
    print "Running SAMS status example service."
    print usage
    mainloop.run()
