function [sf,pUnits] = getsf(cUnits,dUnits)

% GETSF returns a multiplier to convert from one set of units
% to another for use in PIMS offline software.
%
% [sf] = getsf(cUnits,dUnits)
%
% where cUnits is the current units, and dUnits is the desired units,
% and Y(dUnits) = sf * Y(cUnits).
%
% Strings for standard units conversions are:
% Time: seconds,minutes,hours,days
% Acceleration: mcg,mg,g
% Angles: radians,degrees

% 
%  Author: Eric Kelly
% $Id: getsf.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Change acceleration units into workable units
switch cUnits
case {'\mug','mug','micro-g','mcg'}
    cUnits = 'microg';
case {'mg','milli-g'}
    cUnits = 'millig';
end

switch dUnits
case {'\mug','mug','micro-g','mcg','microg'}
    pUnits = '\mug';
    dUnits = 'microg';
case {'mg','milli-g','millig'}
   dUnits = 'millig';
   pUnits = 'mg';
end

% formulate string to pass into units and get scale factor
strConversion = [cUnits '/' dUnits];

sf = double(units(strConversion));

