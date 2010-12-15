function [index]= findsamecoord(sHeader,sCoordList,strCriteria)

% FINDSAMECOORD search through the coordinate system structure list and compares
% sHeader Data parameters to determine if sHeader is equal to one in the list.  For 
% coordinate system structures to be the same, all fields must be equal.  
% Returned is the index of the matching coordinate system, and the index of 
% any coordinate systems with matching name fields.
%
%Inputs: sHeader - coordinate system structure
%        sHeaderList - list of coordinate system strutures
%        sCriteria - 'data' or 'sensor' to match DataCoordinate aor SensorCoordinate in header file
%Outputs: index - index of matching structure, returns empty set if no match
%       
%  
%  Note:   sHeaderList is of different form than sHeader
%  EXAMPLE:
%  
%  sHeader.DataCoordinateSystemName = 'PCS'                        sHeaderList.Name{1:N}
%  sHeader.DataCoordinateSystemComment ='USLAB,LAB1O1,Drawer2'     sHeaderList.Comment{1:N}
%  sHeader.DataCoordinateSystemRPY = [90 180 45]                   sHeaderList.RPY{1:N}
%  sHeader.DataCoordinateSystemXYZ = [3 4 5]                       sHeaderList.XYZ{1:N}
%  sHeader.DataCoordinateSystemTime                                sHeaderList.Time{1:N}
%

%Author: Eric Kelly, March 21,2001
% $Id: findsamecoord.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize search string
index =[];

% Capitalize the first letter, lowercase all others
strCriteria = lower(strCriteria);
strCriteria = [upper(strCriteria(1)) strCriteria(2:end)];

% Make the fieldname
strFieldName = [strCriteria 'CoordinateSystemName'];
strFieldTime = [strCriteria 'CoordinateSystemTime'];

indexName = find(strcmp(getfield(sHeader,strFieldName),sCoordList.Name));
indexTime = find(strcmp(getfield(sHeader,strFieldTime),sCoordList.Time));

index = intersect(indexName,indexTime);

 
