function [strMmm,numMonth] = monthnum(strM);
%monthnum Month number.
%
%   [strMmm,numMonth] = monthnum(strM); % returns the month in numeric and 
%                                       % string given strM

%   Author: Ken Hrovat, 9/28/2000
% $Id: monthnum.m 4160 2009-12-11 19:10:14Z khrovat $

cMonth = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

if ( nargin < 1 | ~isstr(strM) | length(strM)~=3 )
  error('Please enter 3 character string for strM.')
end

numMonth=strmatch(lower(strM),lower(cMonth));

if isempty(numMonth)
   strMmm='';
elseif length(numMonth)>1
   msg=sprintf('input string: %s somehow gives multiple matches',strM);
   error(msg);
else
   strMmm=cMonth{numMonth};
end

   

