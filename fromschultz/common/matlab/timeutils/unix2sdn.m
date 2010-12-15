function sdn = unix2sdn(time_t);
% UNIX2SDN - convert MATLAB serial date number to UNIX timestamp
%  	Usage:	sdn = unix2sdn(time_t);
%  	Input: 	time_t - UNIX timestamp (integer)
%  	Output: sdn - MATLAB serial date number (format of datenum)
%
%  MATLAB - fractional days from 0000-Jan-00, UNIX - seconds from 1970-Jan-01
%  See also sdn2unix, datenum

% Author: Roger Cheng
% $Id: unix2sdn.m 4160 2009-12-11 19:10:14Z khrovat $

sdn = time_t/86400+719529;
% 86400 = 60 s * 60 m * 24 hr
% 719529 = SDN for 1970-Jan-01 00:00:00