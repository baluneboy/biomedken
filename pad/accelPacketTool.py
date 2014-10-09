#!/usr/bin/env python
# $Id$

# TODO
# - better handling of iteration when limit > 1...
#   for now, depend on user to pipe results through more (or less)

#----------------------------------------------------------
# Notes from PGUID Document KMAC sent me:
#----------------------------------------------------------
#
# START SAMS PACKET #######################################
## Header Part of Packet (44 bytes):
# 16 bytes EHS Primary Header
# 12 bytes     Secondary Header [called PDSS or EHS?]
#  6 bytes CCSDS Primary Header
# 10 bytes CCSDS Secondary Header
# --  --  --  --  --  --  --  --  --  --  --  --  --  --
## Payload Part of Packet (the remaining bytes):
# ~1200 bytes in the "Data Zone"
# END SAMS PACKET #########################################
#
# START HiRAP PACKET ######################################
## Header Part of Packet (60 bytes):
# 16 bytes EXPRESS Header
# 16 bytes EHS Primary Header
# 12 bytes     Secondary Header [called PDSS or EHS?]
#  6 bytes CCSDS Primary Header
# 10 bytes CCSDS Secondary Header
# --  --  --  --  --  --  --  --  --  --  --  --  --  --
## Payload Part of Packet (the remaining bytes):
# 1172 bytes in the "Data Zone" (HiRAP ALWAYS 1172 BYTES)
# END HiRAP PACKET ########################################

import sys
from accelPacket import *

# hex dump of packet (or header)
def packetDump(packet):
    """hex dump of packet (or header)"""
    hex = ''
    start = 0
    size = 16
    ln = len(packet)
    while start < ln:
        # print line number
        line = '%04x  ' % start
        #print hex representation
        c = 0
        asc = packet[start:min(start+size, ln)]
        for b in asc:
            if c == 8:
                line = line + '  '
            line = line + '%02x ' % ord(b)
            c = c + 1
        line = ljust(line, 58) + '"'
        # print ascii representation, replace unprintable characters with spaces
        for i in range(len(asc)):
            if ord(asc[i])<32 or ord(asc[i]) == 209:
                asc = replace(asc, asc[i], ' ')
        line = line + asc + '"\n'  
        hex = hex + line
        start = start + size
    return hex.rstrip('\n'), ln  

def get_utime(pkt, which='se'):
    if which == 'se':
        sec, usec = struct.unpack('II', pkt[36:44])
    elif which == 'tsh':
        sec, usec = struct.unpack('!II', pkt[64:72]) # ! for network byte order
    return sec + usec/1000000.0

def get_bcd2utime(pkt):
    century = BCD(pkt[0])
    year =    BCD(pkt[1]) + 100*century
    month =   BCD(pkt[2])
    day =     BCD(pkt[3])
    hour =    BCD(pkt[4])
    minute =  BCD(pkt[5])
    second =  BCD(pkt[6])
    millisec = struct.unpack('h', pkt[8:10])[0]
    millisec = millisec & 0xffff
    return HumanToUnixTime(month, day, year, hour, minute, second, millisec/1000.0)

def get_ccsds_time(hdr):
    UTIME1980 = 315964800.0
    b35, b36, b37, b38, b39 = struct.unpack('ccccc', hdr[34:39])
    coarse_hex = b35.encode('hex') + b36.encode('hex') + b37.encode('hex') + b38.encode('hex')
    fine_hex = b39.encode('hex')
    scale = 16 # for hexadecimal
    coarse = int(coarse_hex, scale) + UTIME1980
    fine = float(int(fine_hex, scale)) / (2.0**8)
    return coarse, fine_hex, fine

def get_ccsds_sequence(hdr):
    VALUE_MASK = 0x0FFF
    b31, b32 = struct.unpack('cc', hdr[30:32])
    my_hexdata = b31.encode('hex') + b32.encode('hex')
    #print my_hexdata
    scale = 16 # for hexadecimal
    #print int(my_hexdata, scale)
    #print bin(int(my_hexdata, scale))
    #print bin(int(my_hexdata, scale))[2:]
    ##num_of_bits = 16 # total bits
    ##print bin(int(my_hexdata, scale))[2:].zfill(num_of_bits)
    ##print bin(int(my_hexdata, scale) & VALUE_MASK)
    return int(my_hexdata, scale) & VALUE_MASK

# general query
class GeneralQuery(object):
    """general query"""
    
    def __init__(self, host, table, query_suffix):
        self.host = host
        self.table = table
        self.query_suffix = query_suffix
        self.set_querystr()

    def __str__(self):
        return '%s (%s)' % (self.__class__.__name__, self.querystr)

    def set_querystr(self):
        self.querystr = 'SELECT * FROM %s %s;' % (self.table, self.query_suffix)       

    def get_results(self):
        return sqlConnect(self.querystr, self.host)

# default query has limit of 1 and desc time order
class DefaultQuery(GeneralQuery):
    """default query has limit of 1 and desc time order"""
    
    def __init__(self, host, table):
        super(DefaultQuery, self).__init__(host, table, query_suffix='ORDER BY time DESC LIMIT 1')

# SAMS SE half-sec foursome query
class SamsSeHalfSecFoursomeQuery(GeneralQuery):
    """
    SAMS SE half-sec foursome query has limit of 12
    -- should show 3 examples of KMAC's pattern of 4 pkts/half-sec = 4 pkts per CCSDS counter foursome
    ---> ccsds_time clusters of 4 with same time and with clusters a half second apart
    ---> ccsds_sequence_counter foursomes with monotonically decreasing (by exactly one) within each foursome
    """

    def __init__(self, host, table):
        super(SamsSeHalfSecFoursomeQuery, self).__init__(host, table, query_suffix = 'ORDER BY time DESC LIMIT 12')

# SAMS TSH one-sec eightsome query
class SamsTshOneSecEightsomeQuery(GeneralQuery):
    """
    SAMS TSH one-sec eightsome query has limit of 24
    -- should show 2 examples of TSH pattern of 8 pkts/sec = 8 pkts per CCSDS counter eightsome
    ---> ccsds_time clusters of 4 or 8 with same time and with clusters a multiple of 4msec apart
    ---> ccsds_sequence_counter eightsomes with monotonically decreasing (by exactly one) within each eightsome
    """

    def __init__(self, host, table):
        super(SamsTshOneSecEightsomeQuery, self).__init__(host, table, query_suffix = 'ORDER BY time DESC LIMIT 24')

# "start, length" query has ascending order with special limit to imply "start at rec" and "give me this many records"
class StartLenAscendQuery(GeneralQuery):
    """Like SELECT * FROM 121f04 ORDER BY time ASC LIMIT 2, 3; # ASC & LIMIT imply start at rec (2+1) and give me 3 results"""

    def __init__(self, host, table, start, length):
        suffix = 'ORDER BY time ASC LIMIT %d, %d' % ( (start-1) , length ) # zero is 1st rec
        super(StartLenAscendQuery, self).__init__(host, table, query_suffix = suffix)

# default packet query has limit of 1 and desc time order
class OLDDefaultPacketQuery(object):
    """default packet query has limit of 1 and desc time order"""
    
    def __init__(self, host, table, order='DESC', limit=1):
        self.host = host
        self.table = table
        self.order = order
        self.limit = limit
        self.set_querystr()

    def __str__(self):
        return '%s (%s)' % (self.__class__.__name__, self.querystr)

    def set_querystr(self):
        self.querystr = 'SELECT * FROM %s ORDER BY time %s LIMIT %s;' % (self.table, self.order, self.limit)       

    def get_results(self):
        return sqlConnect(self.querystr, self.host)

# custom packet query
class OLDCustomQuery(DefaultPacketQuery):
    """custom packet query"""
    
    def __init__(self, host, table, where_clause='WHERE time > 0', order_clause='ORDER BY time DESC', limit_clause='LIMIT 2'):
        self.host = host
        self.table = table
        self.order = None
        self.limit = None
        self.where_clause = where_clause
        self.order_clause = order_clause
        self.limit_clause = limit_clause
        self.set_querystr()

    def set_querystr(self):
        self.querystr = 'SELECT * FROM %s %s %s %s;' % (self.table, self.where_clause, self.order_clause, self.limit_clause)       

# SAMS SE half-sec foursome query
class OLDSamsSeHalfSecFoursomeQuery(DefaultPacketQuery):
    """
    SAMS SE half-sec foursome query has limit of 12
    -- should show 3 examples of KMAC's pattern of 4 pkts/half-sec = 4 pkts per CCSDS counter foursome
    ---> ccsds_time clusters of 4 with same time and with clusters a half second apart
    ---> ccsds_sequence_counter foursomes with monotonically decreasing (by exactly one) within each foursome
    """

    def __init__(self, host, table, order='DESC', limit=12):
        super(SamsSeHalfSecFoursomeQuery, self).__init__(host, table, order=order, limit=limit)

# SAMS TSH one-sec eightsome query
class OLDSamsTshOneSecEightsomeQuery(DefaultPacketQuery):
    """
    SAMS TSH one-sec eightsome query has limit of 16
    -- should show 2 examples of TSH pattern of 8 pkts/sec = 8 pkts per CCSDS counter eightsome
    ---> ccsds_time clusters of 4 or 8 with same time and with clusters a multiple of 4msec apart
    ---> ccsds_sequence_counter eightsomes with monotonically decreasing (by exactly one) within each eightsome
    """

    def __init__(self, host, table, order='DESC', limit=24):
        super(SamsTshOneSecEightsomeQuery, self).__init__(host, table, order=order, limit=limit)

# "start, length" query has ascending order with special limit to imply "start at rec" and "give me this many records"
class OLDStartLenQuery(DefaultPacketQuery):
    """Like SELECT * FROM 121f04 ORDER BY time ASC LIMIT 2, 3; # ASC & LIMIT imply start at rec (2+1) and give me 3 results"""

    def __init__(self, host, table, start, length):
        self.host = host
        self.table = table
        self.order = 'ASC'
        self.limit = '%d, %d' % ( (start-1) , length ) # zero is 1st rec
        self.set_querystr()

class PacketInspector(object):
    
    def __init__(self, host, table, query, details=True):
        self.host = host
        self.table = table
        self.query = query
        self.details = details
        self.results = None

    def __str__(self):
        s = '%s: use %s' % (self.__class__.__name__, self.query)
        if self.details:
            s += ' with details.'
        else:
            s += ' without details.'
        return s

    def do_query(self):
        self.results = self.query.get_results()

    # FIXME this is where we left off with non-class version of code
    #       include method to get this into DataFrame too?
    def show_results_awkwardly(self):
        # NOTE:
        # results[0] is time
        # results[1] is packet blob
        # results[2] is type
        # results[3] is header blob
        print self
        for t, p, k, h in self.results:
    
            # get CCSDS header time and sequence counter
            ccsds_coarse_time, ccsds_fine_time_hex, ccsds_fine_time = get_ccsds_time(h)
            ccsds_time_human = UnixToHumanTime(ccsds_coarse_time + ccsds_fine_time)
            ccsds_sequence_counter = get_ccsds_sequence(h)
            
            if self.details:
                print '='*88
                print 'The 4 columns in %s table are:' % self.table
                print '(1) time: %s' % UnixToHumanTime( t )
                print '(2) type: %d' % k
                
                phex, plen = packetDump(p)
                print '(3) packet (hex dump of %d bytes)' % plen
                print '-'*80
                print phex
                print '-'*80
                
                hhex, hlen = packetDump(h)
                print '(4) header (hex dump of %d bytes)' % hlen
                print '-'*80
                print hhex
                print '-'*80
                
                # NOTE:
                # the code above should work regardless of bogus records that might
                # trip up the code below that depends on recognizable packet content
                
                # guess packet and print details parsed from the packet blob
                pkt = guessPacket(p)
                if pkt.type == 'unknown':
                    print '??? UNKNOWN PACKET TYPE'
                    print '======================='
                    print 'db column time:', UnixToHumanTime( t ), '(%.4f)' % t
                    print '   packet time:'
                    print 'packet endTime:'
                    print '          name:'
                    print '          rate:'
                    print '       samples:'
                    #print 'measurementsPerSample:', pkt.measurementsPerSample()
                    utime = None
                    htime = 'unknown'
                else:
                    print 'db column time:', UnixToHumanTime( t ), '(%.4f)' % t
                    print '   packet time:', UnixToHumanTime( pkt.time() )
                    print 'packet endTime:', UnixToHumanTime( pkt.endTime() )
                    print '          name:', pkt.name()
                    print '          rate:', pkt.rate()
                    print '       samples:', pkt.samples()
                    #print 'measurementsPerSample:', pkt.measurementsPerSample()
                    utime = pkt.time()
                    htime = UnixToHumanTime( utime )
                    for t,x,y,z in pkt.txyz():
                        print "tsec:{0:>9.4f}  xmg:{1:9.4f}  ymg:{2:9.4f}  zmg:{3:9.4f}".format(t, x/1e-3, y/1e-3, z/1e-3)
    
            elif self.table == 'hirap':
                utime = get_bcd2utime(p) # for hirap, it's BCD time in packet
                htime = UnixToHumanTime( utime )
            
            elif self.table.startswith('121f0'):
                #utime_hex = p[36:44].encode('hex')
                utime = get_utime(p) # for sams2 it's unixtime (sec, usec) in packet
                htime = UnixToHumanTime( utime )     

            elif self.table.startswith('es0'):
                utime = get_utime(p, which='tsh') # for sams2 tsh it's again unixtime (sec, usec) in diff part of packet
                htime = UnixToHumanTime( utime ) 
    
            else:
                htime = 'NoHandler4ThisTableName'
    
            # FIXME put this above details and improve handling of details versus utimes form of output
            print 'ccsds_time:%s, ccsds_sequence_counter:%05d, pkt_time:%s, table:%s' % (ccsds_time_human, ccsds_sequence_counter, htime, self.table)
    
# ----------------------------------------------------------------------
# EXAMPLES:
#
# SAMS SE
# accelPacketTool.py kenny 121f02
# accelPacketTool.py ike es05

# iterate over db query results to show pertinent packet details (and header too)
if __name__ == '__main__':
    """iterate over db query results to show pertinent packet details (and header too)"""
      
    # input parameters
    host = sys.argv[1]  # LIKE kenny
    table = sys.argv[2] # LIKE 121f02
    details = False
    
    # create query object (without actually running the query)
    if table.startswith('121f0'):
        query = SamsSeHalfSecFoursomeQuery(host, table)

    elif table.startswith('es0'):
        query = SamsTshOneSecEightsomeQuery(host, table)

    elif table == 'hirap':
        # FIXME is hirap just a case where ccsds_seq is "mostly or nearly contiguous"?
        query = StartLenQuery(host, table, 1, 245) # does it show pattern at rec ~80, ~160, and ~240?
        query = CustomQuery(host, table, where_clause='WHERE time > unix_timestamp("2014-10-09 18:00:00")', order_clause='ORDER BY time DESC', limit_clause='LIMIT 2')

    else:
        query = DefaultPacketQuery(host, table) 
    
    # create packet inspector object using query object as input
    pkt_inspector = PacketInspector(host, table, query=query, details=details)
    
    # now run the query and show results
    pkt_inspector.do_query()
    pkt_inspector.show_results_awkwardly()
