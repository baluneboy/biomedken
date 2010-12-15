function [proj,orth]=orthogonalprojection(a,b);
% ORTHOGONALPROJECTION - Find orthogonal projection (proj) of vector a onto
% vector b and the vector difference between a and proj ( orth = a - proj ).
% Vectors a and b should have 2-elements and same size.
%
% INPUTS:
% a - 2-element [x y] vector we are projecting
% b - 2-element [x y] vector we project onto
%
% OUTPUTS:
% proj - 2-element [x y] projection vector of a along b
% orth - 2-element [x y] vector equal to ( a - proj )
%
% EXAMPLE:
% xy_position = [5 0]; r = -xy_position % POSITIVE TOWARD THE ORIGIN
% xy_velocity = [-2 0];
% [proj,orth]=orthogonalprojection(xy_velocity,r)

% AUTHOR: Ken Hrovat
% $Id: orthogonalprojection.m 4160 2009-12-11 19:10:14Z khrovat $

% Find dot product
dotprod=dot(a,b);

% Find length of vectors (b is vector we are projecting onto)
norma=norm(a);
normb=norm(b);

% Find useful quotient (for convenience)
dotprod_over_normb=dotprod/normb;

% Use dot product to get magnitude along b and multiply by unit vector along b
proj=(dotprod_over_normb)*b/normb;

% Get orthogonal component by vector subtraction
orth=a-proj;