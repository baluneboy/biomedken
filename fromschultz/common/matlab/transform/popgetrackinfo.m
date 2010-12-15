function [menulist,rackinfo] = popgetrackinfo
%
%  GETRACKINFO loads the data from rackloc.dat into a structure for use 
%  in MAMSGUI.  
%              [rackinfo] = getrackinfo;
%
%  rackinfo is a structure with field arrays rackinfo.id and rackinfo.loc 
%
%  Current path of rackloc.dat is
%       /home/behemoth5/ekelly/matlabwork/mamsfiles/mamsdata/rackloc.dat
%  Current size of header in rackloc.dat should be
%       15 lines

%
% Author: Eric Kelly
% $Id: popgetrackinfo.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Location of rackloc.dat
rloc = '/home/behemoth5/ekelly/matlabwork/mamsfiles/mamsdata/rackloc.dat';

% Read the coordinates and name into variables
[x,y,z,temp] = textread(rloc,'%f %f %f %s','headerlines',15);

for j = length(x)+1:-1:2;
   rackinfo{j,1} = [x(j-1) y(j-1) z(j-1)];
end
menulist = cappend({'No Mapping'},temp);
