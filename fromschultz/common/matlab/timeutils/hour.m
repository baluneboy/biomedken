function h = hour(d) 
%HOUR   Hour of date or time. 
%       H = HOUR(D) returns the hour of the day given a serial date number or 
%       a date string, D. 
% 
%       For example, h = hour(728647.5590548427) or  
%       h = hour('19-Dec-1994, 13:24:08.17') returns h = 13. 
%        
%       See also DATEVEC, SECOND, MINUTE. 

if nargin < 1 
  error('Please enter D.') 
end 
if isstr(d) 
  d = datenum(d); 
end 
c = datevec(d(:));  % Generate date vector from date 
h = c(:,4);     % Extract hour 
if ~isstr(d) 
  h = reshape(h,size(d)); 
end