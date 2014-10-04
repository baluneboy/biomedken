#!/usr/bin/env python

import math
import struct
import ctypes
from binascii import hexlify
from accelPacket import UnixToHumanTime, HumanToUnixTime

# prefix dictionary for struct packing
ENDIANNESS = {
    'native, native'  : '@',
    'native, standard': '=',
    'little-endian'   : '<',
    'big-endian'      : '>',
    'network'         : '!',
    'unspecified'     : '',
    }

def show_pack(fmt, values, en='network'):
    fmt = ENDIANNESS[en] + ' ' + fmt
    s = struct.Struct(fmt)
    print 'Format    : "%s" (endianness prefix "%s" for %s byte ordering)' % (fmt, ENDIANNESS[en], en)
    b = ctypes.create_string_buffer(s.size)
    print 'Before    :', hexlify(b.raw), '(hex fmt pre-allocated, empty buffer)'
    s.pack_into(b, 0, *values)
    print 'After     :', hexlify(b.raw), '(hex fmt packed-into buffer with "%s" byte ordering)' % en
    print 'Original  :', values
    print 'Unpacked  :', s.unpack_from(b, 0)
    return b

def demo_pack_unpack(ut, endianness='network'):
    print 'human time: %s (ORIGINAL)' % UnixToHumanTime(ut)
    fracsec, sec = math.modf(ut)
    usec = fracsec*1000000.0
    print 'unix time : %.3f (ORIGINAL)' % ut
    print 'ut_secpart: %s' % format(int(sec), '#034b'),  # 32 bits  + 2 placeholders for "0b" prefix
    print '(hex: %s)' % format(int(sec), '#x')           #  8 bytes + 2 placeholders for "0x" prefix
    print 'utusecpart: %s' % format(int(usec), '#034b'), # 32 bits  + 2 placeholders for "0b" prefix
    print '(hex: %s)' % format(int(usec), '#010x')       #  8 bytes + 2 placeholders for "0x" prefix
    b = show_pack('II', (int(sec), int(usec)), en=endianness) # 2nd arg for values is always a tuple
    
    # verify that b works like what is expected in Ted's code
    en_prefix = ENDIANNESS[endianness]
    sec1, usec1 = struct.unpack(en_prefix + 'II', b) # endianness refix to specify byte ordering of unpack
    print 'human time: %s (ORIGINAL)' % UnixToHumanTime(ut)
    print 'human time: %s (AFTER PACK-UNPACK)' % UnixToHumanTime( sec1 + usec1/1000000.0 )
    print

if __name__ == "__main__":
    ut = HumanToUnixTime(2014, 10, 04, 12, 34, 56, 0.789)
    demo_pack_unpack(ut)
    
    for fine_bin in range(0, 256):
        print '%03d %0.3f' %(fine_bin, fine_bin/2.0**8)
