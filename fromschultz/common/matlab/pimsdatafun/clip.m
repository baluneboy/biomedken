function cx = clip(x,limit)

% CLIP limit excursions of input vector; also referred to as limiter, saturation or thresholding
%
% cx = clip(x,limit);
%
% INPUTS:
% x - vector of signal to limit
% limit - scalar threshold to clip at
%
% OUTPUT:
% cx - vector of signal clipped at limit
%
% ELAMPLE:
% limit = 1; t = 0:0.01:1; x = sin(2*pi*t);
% cx = clip(x,0.5);
% plot(t,x,t,cx,'r')

% Author: Ken Hrovat
% Adapted from "Little Bits of MATLAB" by James H. McClellan
% $Id: clip.m 4160 2009-12-11 19:10:14Z khrovat $

cx = x.*(abs(x)<=limit) + limit*(x>limit) - limit*(x<-limit);