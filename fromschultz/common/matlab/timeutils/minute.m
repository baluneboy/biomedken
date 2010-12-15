function m = minute(d) 
%MINUTE Minute of date or time. 
%       M = MINUTE(D) returns the minute given a serial date number or a 
%       date string, D. 
% 
%       For example, m = minute(728647.559054842) or  
%       m = minute('19-Dec-1994, 13:25:08.17') returns m = 25. 
%    
%       See also DATEVEC, SECOND, HOUR. 

if nargin < 1 
  error('Please enter D.') 
end 
if isstr(d) 
  d = datenum(d); 
end 
c = datevec(d(:));   % Generate date vectors from dates 
m = c(:,5) ;     % Extract minute 
if ~isstr(d) 
  m = reshape(m,size(d)); 
end