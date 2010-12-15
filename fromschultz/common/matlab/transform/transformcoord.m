function [data,sHeader] = transformcoord (data,sHeader,sCoord)

% TRANSFORMCOORD performs coordinate transformation on acceleration
% data given the header and plot parameters. No transformation is 
% when not required.

% 
%  Author: Eric Kelly
% $Id: transformcoord.m 4160 2009-12-11 19:10:14Z khrovat $
%


% Calculate transformation matrix for SS Analysis to CURRENT
M = euler2Typr(sHeader.DataCoordinateSystemRPY);
% Calculate transformation matrix for CURRENT to SS Analysis
Mt = M';
% Calculate transformation matrix for SS Analysis to FINAL
N = euler2Typr(sCoord.RPY);
% Calculate equivalent Transformation matrix 
T = N*Mt;

% Transform the data to the new system.
%%%%%% MAY NEED TO INSERT SIZE RESTRICTION AND USED NON_VECTORIZED FORM %%%%%%%
% temp = multmatrix_vec(data(:,2:4),T);
if size(data,2)==3
   data = multmatrix_vec(data,T);
else  
   data(:,2:4) = multmatrix_vec(data(:,2:4),T);
end

clear temp;

% Update the new header
sHeader.DataCoordinateSystemName = sCoord.Name;
sHeader.DataCoordinateSystemRPY = sCoord.RPY;
sHeader.DataCoordinateSystemXYZ = sCoord.XYZ;
sHeader.DataCoordinateSystemComment = sCoord.Comment;
sHeader.DataCoordinateSystemTime = sCoord.Time;
 