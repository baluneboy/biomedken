function [newdata] = multmatrix(data,T)

%  MULTMATRIX_ is used to convert the accleration data into new coordinates.  This is used for
% a time series of data where accleration data is in columns [2:4]
%

% 
%  Author: Eric Kelly
% $Id: multmatrix.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Transformation of coordinates is simply [xnew;ynew;znew] = M*[xold;yold;zold]
for i = 1:size(data,1)
  data(i,2:4) = (T*data(:,2:4)')';
end


