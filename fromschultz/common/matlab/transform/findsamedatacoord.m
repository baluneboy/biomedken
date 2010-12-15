function [issame,samename]= findsamedatacoord(sHeader,sCoordList)

% FINDSAMECOORD search through the coordinate system structure list and compares
% sHeader Data parameters to determine if sHeader is equal to one in the list.  For 
% coordinate system structures to be the same, all fields must be equal.  
% Returned is the index of the matching coordinate system, and the index of 
% any coordinate systems with matching name fields.
%
%Inputs: sHeader - coordinate system structure
%        sHeaderList - list of coordinate system strutures
%
%Outputs: issame - index of matching structure, returns empty set if no match
%         samename - index of structures with matching Name fields, returns empty on no match
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
% $Id: findsamedatacoord.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize search string
samename = [];
issame =[];

% Find matching name
samename = find(strcmp(sHeader.DataCoordinateSystemName,sCoordList.Name));
issame = samename;

if ~isempty(samename)
   % step through every instance with names the same
   for i =length(samename):-1:1
      % Check Comment
      if strcmp(sHeader.DataCoordinateSystemComment,sCoordList.Comment{samename(i)})
         % Check orientation
         if(sHeader.DataCoordinateSystemRPY==sCoordList.RPY{samename(i)})
            % Check location
            if ~(sHeader.DataCoordinateSystemXYZ==sCoordList.XYZ{samename(i)})
               % location not same
               issame(i) =[];
            end              
         else
            % orientation not same
            issame(i) =[];   
         end
      else
         % comment not same
         issame(i) =[];
      end
   end
end
