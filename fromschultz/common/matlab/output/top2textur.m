function casUR12=top2textur(sHeader);

%top2textur - use header to generate top 2 lines of upper right text
%
%casUR12=top2textur(sHeader);
%
%Input: casCoordinateSys - cell array of strings (pretty) from EK xform
%
%Output: casUR12 - cell array of strings for top 2 in upper left

%Author: Ken Hrovat, 3/24/2001
%Modified Eric Kelly 4/9/2001
%$Id: top2textur.m 4160 2009-12-11 19:10:14Z khrovat $

strData = sprintf('[%4.1f %4.1f %4.1f]',sHeader.DataCoordinateSystemRPY); 

casUR12{1} = sHeader.ISSConfiguration; 
casUR12{2} = [sHeader.DataCoordinateSystemName strData];


