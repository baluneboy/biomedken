#!/usr/bin/env python
# $Id$

# TODO
# - better handling of iteration when limit > 1...
#   for now, depend on user to pipe results through more (or less)

############
# N O T E S:
#-----------------------------------------------------------------
### START SAMS PACKET ######################################
## Header Part of Packet (44 bytes):
# 16 bytes EHS Primary Header
# 12 bytes     Secondary Header [called PDSS or EHS?]
#  6 bytes CCSDS Primary Header
# 10 bytes CCSDS Secondary Header
# --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
## Payload Part of Packet (the remaining bytes):
# ~1200 bytes in the "Data Zone"
#
### START HiRAP PACKET ######################################
## Header Part of Packet (60 bytes):
# 16 bytes EXPRESS Header
# 16 bytes EHS Primary Header
# 12 bytes     Secondary Header [called PDSS or EHS?]
#  6 bytes CCSDS Primary Header
# 10 bytes CCSDS Secondary Header
# --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
## Payload Part of Packet (the remaining bytes):
# ~XXXX bytes in the "Data Zone"

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
    return hex, ln  

def get_utime(pkt):
    sec, usec = struct.unpack('II', pkt[36:44])
    return sec + usec/1000000.0

def get_ccsds_time(hdr):
    UTIME1980 = 315964800.0
    b35, b36, b37, b38, b39 = struct.unpack('ccccc', hdr[34:39])
    coarse_hex = b35.encode('hex') + b36.encode('hex') + b37.encode('hex') + b38.encode('hex')
    fine_hex = b39.encode('hex')
    scale = 16 # for hexadecimal
    coarse = int(coarse_hex, scale) + UTIME1980
    return coarse, fine_hex

def get_ccsds_sequence(hdr):
    VALUE_MASK = 0x0FFF
    b31, b32 = struct.unpack('cc', hdr[30:32])
    my_hexdata = b31.encode('hex') + b32.encode('hex')
    #print my_hexdata
    scale = 16 # for hexadecimal
    num_of_bits = 16 # total bits
    #print int(my_hexdata, scale)
    #print bin(int(my_hexdata, scale))
    #print bin(int(my_hexdata, scale))[2:]
    ##print bin(int(my_hexdata, scale))[2:].zfill(num_of_bits)
    ##print bin(int(my_hexdata, scale) & VALUE_MASK)
    return int(my_hexdata, scale) & VALUE_MASK

# ----------------------------------------------------------------------
# EXAMPLES:
#
# SAMS SE
# accelPacketTool.py 121f02 kenny desc 1 details
#
# SAMS TSH
# accelPacketTool.py es05 ike asc 1 utimes
#
# MAMS OSS
# accelPacketTool.py oss stan desc 1 details
#
# MAMS OSS BESTTMF
# accelPacketTool.py besttmf stan desc 1 utimes
#
# MAMS HiRAP
# accelPacketTool.py hirap towelie desc 1 details

# iterate over db query results to show pertinent packet details (and header too)
if __name__ == '__main__':
    """iterate over db query results to show pertinent packet details (and header too)"""
    
    # get inputs
    table = sys.argv[1] # db table name (like 121f02)
    host =  sys.argv[2] # db host name (like kenny)
    order = sys.argv[3] # 'asc' or 'desc' for query's "order by time" clause
    limit = sys.argv[4] # integer for query's "limit" clause
    which = sys.argv[5] # 'details' or 'utimes' from packets
    
    # get query results
    results = sqlConnect('select * from %s order by time %s limit %s' % (table, order, limit), host)
    #results = sqlConnect('select * from %s where time < unix_timestamp("2014-09-26 02:48:24") order by time %s limit %s' % (table, order, limit), host)

    # iterate over results
    # NOTE: results[0] = time, results[1] = packet blob, results[2] = type, results[3] = header blob
    for t, p, k, h in results:
        
        if 'details' == which:
            print '\nThe 4 db columns are:'
            print '(1) time: %s' % UnixToHumanTime( t )
            print '(2) type: %d\n' % k
            
            phex, plen = packetDump(p)
            print '(3) packet (hex dump of %d bytes)' % plen
            print '-'*80
            print phex
            
            hhex, hlen = packetDump(h)
            print '(4) header (hex dump of %d bytes)' % hlen
            print '-'*80
            print hhex
            
            # NOTE:
            # the code above should work regardless of bogus records that might
            # trip up the code below that depends on recognizable packet content
            
            # guess packet and print details parsed from the packet blob
            pkt = guessPacket(p)
            print 'db column time:', UnixToHumanTime( t )
            print '   packet time:', UnixToHumanTime( pkt.time() )
            print 'packet endTime:', UnixToHumanTime( pkt.endTime() )
            print '          name:', pkt.name()
            print '          rate:', pkt.rate()
            print '       samples:', pkt.samples()
            #print 'measurementsPerSample:', pkt.measurementsPerSample()
            print 'txyz:'
            for t,x,y,z in pkt.txyz():
                print "t:{0:>9.4f}  xmg:{1:9.4f}  ymg:{2:9.4f}  zmg:{3:9.4f}".format(t, x/1e-3, y/1e-3, z/1e-3)

        # show sams2 utime part of packet
        ccsds_coarse_time, ccsds_fine_time_hex = get_ccsds_time(h)
        #print ccsds_fine_time_hex, float.fromhex(ccsds_fine_time_hex)
        ccsds_coarse_time_human = UnixToHumanTime(ccsds_coarse_time)
        ccsds_sequence_counter = get_ccsds_sequence(h)
        #utime_hex = p[36:44].encode('hex')
        utime = get_utime(p)
        #vcdu_count_hex = h[17:20].encode('hex')
        #print '%06d,%s,0x%s,%8d,0x%s,%s,%s' % (ccsds_sequence_counter, UnixToHumanTime(utime), utime_hex, int(vcdu_count_hex, 16), vcdu_count_hex, table, ccsds_coarse_time_human)
        #print 'ccsds_sequence_counter:%05d, ccsds_coarse_time:%s, pkt_time:%s, pkt_utime_hex:0x%s, table:%s' % (ccsds_sequence_counter, ccsds_coarse_time_human, UnixToHumanTime(utime), utime_hex, table)
        print 'ccsds_sequence_counter:%05d, ccsds_coarse_time:%s, pkt_time:%s, table:%s' % (ccsds_sequence_counter, ccsds_coarse_time_human, UnixToHumanTime(utime), table)
