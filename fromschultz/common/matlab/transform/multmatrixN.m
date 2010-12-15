function [C] = multmatrixN (A,B)

% This function is used to multiply a vector of 3x1 matrices by a vector of 3x3 matrices.
% The first vector of matrices (A) must be 3x3xN and the second (B) must be 3x1xN.
%
%       [C] = multmatrix (A,B)

% Written by Eric Kelly
% February 25, 2000
% $Id: multmatrixN.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize C and temp
C = zeros(size(B));

for i = 1:3
   for j = 1:3
     C(i,1,:) = C(i,1,:) + (A(i,j,:).*B(j,1,:));   
   end 
end







