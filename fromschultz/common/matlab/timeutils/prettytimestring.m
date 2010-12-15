function [strNeat,strMsg]=prettytimestring(strInput,strOld,strDesiredFormat);

%prettytimestring - standardize datetime string in strDesiredFormat.
%
%[strNeat,strMsg]=prettytimestring(strInput,strOld,strDesiredFormat);  % see below for strDesiredFormat 
%
%Input: strInput - string input for datetime
%       strOld - string for previous datetime
%       strDesiredFormat - string for format to use
%
%Outputs: strNeat - string for standard datetime in recognized strDesiredFormat
%         strMsg - string message for graceful exit

% author: Ken Hrovat, 9/29/2000
% $Id: prettytimestring.m 4160 2009-12-11 19:10:14Z khrovat $

strNeat='';
strMsg='';

[strNeat,strFormatIn]=popdatestr(strInput,strDesiredFormat);
if ~strcmp(strFormatIn,strDesiredFormat)
   strNeat=strOld;
   strMsg=sprintf('input format, %s, does not match desired format, %s',strFormatIn,strDesiredFormat);
end
