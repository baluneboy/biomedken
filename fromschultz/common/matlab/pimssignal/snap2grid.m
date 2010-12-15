function y=snap2grid(x,gridmin,gridstep,gridmax,lean);
% SNAP2GRID quantize output to take only values on (or snap to) the grid specified by grid inputs
% if gridstep and gridmax are not specified, then use elements of gridmin as the entire grid.
%
% y=snap2grid(x,gridmin,gridstep,gridmax,lean);
%
% INPUTS:
% x - vector of inputs
% gridmin - scalar for lower grid value
% gridstep - scalar for grid interval
% gridmax - scalar for upper grid value
% lean - scalar such that:
%               if lean>0, then use  ceil function to coerce
%               if lean<0, then use floor function to coerce
%               otherwise, then use round function to coerce
%
% OUTPUTS:
% y - vector of quantized outputs

% written by: Ken Hrovat on 3/27/00
% $Id: snap2grid.m 4160 2009-12-11 19:10:14Z khrovat $

switch nargin
case 2 % inputs are: x and grid values (use round for lean)
   lean=0;
   gridvals=gridmin;
case 3 % inputs are: x, grid values, and lean
   gridvals=gridmin;
   lean=gridstep;
case 4 % inputs are: x, gridmin, gridstep, and gridmax (use round for lean)
   lean=0;
   gridvals=gridmin:gridstep:gridmax;
case 5 % inputs are: x, gridmin, gridstep, gridmax, and lean   
   gridvals=gridmin:gridstep:gridmax;
otherwise
   error('unaccounted for case on number of inputs')
end % switch nargin

% Error check grid values
if length(gridvals)<2
   error('there must be at least 2 grid values')
end
dg=diff(gridvals);
if any(dg<=0)
   error('grid values must be strictly increasing')
end

% Error check lean
if length(lean)>1
   error('length(lean) must be one')
end

% Snap to grid values
% There's a TBD way to vectorize this loop [using
% repmat and diff?]
y=zeros(size(x));
for i=1:length(x)
   y(i)=localSnap(x(i),gridvals,lean);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=localSnap(in,gridvals,lean);

ind=find(gridvals==in);
if ~isempty(ind)
   out=gridvals(ind);
   return
end

indpos=find(gridvals>in);
if ~isempty(indpos)
   right=gridvals(indpos(1));
else
   out=gridvals(end);
   return
end

indneg=find(gridvals<in);
if ~isempty(indneg)
   left=gridvals(indneg(end));
else
   out=gridvals(1);
   return
end

if lean>0
   out=right;
elseif lean<0
   out=left;
else
   bounds=[right left]; %use this order for midpoint case
   dg=abs(bounds-in);
   [dmin,ind]=min(dg);
   out=bounds(ind);
end

