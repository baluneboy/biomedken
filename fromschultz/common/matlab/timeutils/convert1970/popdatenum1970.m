function [numDate] = popdatenum1970(strDate);

%POPDATENUM1970 converts the pims date string, format YYYY_MM_DD_hh_mm_ss.sss
% to Unix time. Time in secondsrelative to 1970
%
%   ie. 
%     popdatenum1970('1970_01_01_00_00_00.000')  = 0
%     popdatenum1970('1980_01_01_00_00_00.000')  =  6.2483e+010

numDate =(popdatenum(strDate) - popdatenum('1970_01_01_00_00_00.000'))*86400;

