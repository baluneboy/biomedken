function time_t = sdn2unix(sdn);
% SDN2UNIX - convert MATLAB serial date number to UNIX timestamp
%   Usage:  time_t = sdn2unix(sdn);
%   Input: 	sdn - MATLAB serial date number (from datenum)
%   Output: time_t - UNIX timestamp (integer)
%
%  MATLAB - fractional days from 0000-Jan-00, UNIX - seconds from 1970-Jan-01
%  This would output the timestamp in "local time" (MATLAB has no correction to UTC)
%  See also unix2sdn, datenum

% Author: Roger Cheng
% $Id: sdn2unix.m 4160 2009-12-11 19:10:14Z khrovat $

time_t = round((sdn-719529)*86400);
% 86400 = 60 s * 60 m * 24 hr
% 719529 = SDN for 1970-Jan-01 00:00:00
% Rounding because UNIX time_t is int32 (or int64)