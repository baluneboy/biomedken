function [xnew,iNan]=excisenan(x);

%EXCISENAN remove NaNs from a vector.
%
%xnew=excisenan(x); % OR [xnew,iNan]=excisenan(x);

% modified by: Kenneth Hrovat on 2/10/05 to return indices of NaNs
% $Id: excisenan.m 4160 2009-12-11 19:10:14Z khrovat $

blnNan=~isnan(x);
xnew=x(blnNan);
if nargout>1
   iNan=find(~blnNan);
end