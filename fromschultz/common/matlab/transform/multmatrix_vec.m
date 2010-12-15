function [data] = multmatrix_vec(data,T)

%  MULTMATRIX_VEC is used to convert the accleration data into new coordinates.  This is a vectorized
% version of MULTMATRIX
%

% 
%  Author: Eric Kelly
% $Id: multmatrix_vec.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Initialize newdata
newdata = zeros(size(data));

% Transformation of coordinates is simply [xnew;ynew;znew] = M*[xold;yold;zold]
% Code is in vectorized form to speed operations
newdata(:,1) = T(1,1)*data(:,1) + T(1,2)*data(:,2) + T(1,3)*data(:,3);
newdata(:,2) = T(2,1)*data(:,1) + T(2,2)*data(:,2) + T(2,3)*data(:,3);
newdata(:,3) = T(3,1)*data(:,1) + T(3,2)*data(:,2) + T(3,3)*data(:,3);

% Set the accleration columns in data to the newdata and clear newdata
data = newdata;
clear newdata;
