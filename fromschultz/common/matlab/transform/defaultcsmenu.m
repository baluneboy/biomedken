
function [sCoordMenu]= defaultcsmenu(strWhichMenu,sHeader);
%DEFAULTCSMENU creates a coordinate system menu from the data header structure
%when the coordinate system database file can not be found.
%
%  Author Eric Kelyl
% $Id: defaultcsmenu.m 4160 2009-12-11 19:10:14Z khrovat $
%
   switch (strWhichMenu)
   case 'CoordSys'   
      
      sCoordMenu.Name = {sHeader.DataCoordinateSystemName};
      sCoordMenu.Comment = {sHeader.DataCoordinateSystemComment};
      sCoordMenu.RPY = {sHeader.DataCoordinateSystemRPY};
      sCoordMenu.XYZ = {sHeader.DataCoordinateSystemXYZ};
      sCoordMenu.Time = {sHeader.DataCoordinateSystemTime};

   case 'Mapping'
      sCoordMenu.Name = {sHeader.SensorCoordinateSystemName};
      sCoordMenu.Comment = {sHeader.SensorCoordinateSystemComment};
      sCoordMenu.RPY = {sHeader.SensorCoordinateSystemRPY};
      sCoordMenu.XYZ = {sHeader.SensorCoordinateSystemXYZ};
      sCoordMenu.Time = {sHeader.DataCoordinateSystemTime};

   end
   