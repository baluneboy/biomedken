function [coordinfo] = popgetcoordinfo
%
%  GETCOORDINFO loads the data from coordloc.dat into a structure for use 
%  in MAMSGUI.  
%              [rackinfo] = getcoordinfo;
%
%   rackinfo is a structure with field arrays x,y,z,id 
%
%
%  Current path of rackloc.dat is
%       /home/behemoth5/ekelly/matlabwork/mamsfiles/mamsdata/rackloc.dat
%  Current size of header in rackloc.dat should be
%       15 lines

%
% Author: Eric Kelly
% $Id: popgetcoordinfo.m 4160 2009-12-11 19:10:14Z khrovat $
%

cloc = '/home/behemoth5/ekelly/matlabwork/mamsfiles/mamsdata/coordloc.dat';
[x,y,z,Y,P,R,temp] = textread(cloc,'%f %f %f %f %f %f %s','headerlines',15);

coordinfo.name = temp;
for j = length(x):-1:1;
   coordinfo.loc{j,1} = [x(j) y(j) z(j)];
   coordinfo.rpy{j,1} = [R(j) P(j) Y(j) ];
end
