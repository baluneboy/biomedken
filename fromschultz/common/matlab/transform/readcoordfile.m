function [sCoordMenu,strMessage] = readcoordfile

% READCOORDFILE reads the coordinate system database file dumped by
% realtime operations and outputs a menu to put into the SELF controls.
%
%
%[sCoordMenu,strMessage] = readcoordfile
%

% Author: Eric Kelly, March 19,2001

%
% $Id: readcoordfile.m 4160 2009-12-11 19:10:14Z khrovat $
%
strMessage = [];

% determine path of the file, coord.txt
strPSLocation = which('popstartup.m');
strFileRoot = strrep(strPSLocation,'popstartup.m','');
% Attempt to find the correct path. If samsff or oare look for STS. Default is ISS coord.txt
hgcbf = gcbf;
if ~isempty(hgcbf)
   h = guidata(hgcbf);
   if (~isempty(strmatch('oare',h.sHeader.DataType)) | ~isempty(strmatch('samsff',h.sHeader.DataType)))
      strFilePath = which('sts107_coord.txt');
   else
      strFilePath = which('coord.txt');
   end
else
   strFilePath = which('coord.txt');
end

isthere = exist(strFilePath);
isrightone = ~isempty(findstr(strFilePath,'anc_data'));

% check for existence and readability of file
if isthere & isrightone
   [fid,strError] = fopen(strFilePath,'rt');
   index =1;
   if (fid>0)
      % Read in a line of the file
      strLine = fgetl(fid);
      while strLine~=-1
         tildas = findstr(strLine,'~');
         
         % Coordinate System Name
         sCoordMenu.Name{index} = strLine(tildas(1)+1:tildas(2)-1);
         % Coordinate System Comment
         sCoordMenu.Comment{index} = strLine(tildas(8)+1:end);
         
         % Coordinate System RPY
         roll = str2num(strLine(tildas(2)+1:tildas(3)-1));
         pitch = str2num(strLine(tildas(3)+1:tildas(4)-1));
         yaw = str2num(strLine(tildas(4)+1:tildas(5)-1));
         sCoordMenu.RPY{index} = [roll pitch yaw];
         
         % Coordinate System XYZ
         x = str2num(strLine(tildas(5)+1:tildas(6)-1));
         y = str2num(strLine(tildas(6)+1:tildas(7)-1));
         z = str2num(strLine(tildas(7)+1:tildas(8)-1));
         sCoordMenu.XYZ{index} = [x y z];
         
         %Coordinate System Time
         sCoordMenu.Time{index} = convert1970time(strLine(1:tildas(1)-1));
         strLine = fgetl(fid);
         index=index+1;
      end
      fclose(fid);
      
      % Make the Column vectors
      sCoordMenu.Name = sCoordMenu.Name(:);
      sCoordMenu.Comment = sCoordMenu.Comment(:);
      sCoordMenu.RPY = sCoordMenu.RPY(:);
      sCoordMenu.XYZ = sCoordMenu.XYZ(:);
      sCoordMenu.Time = sCoordMenu.Time(:);
      
   else
      strMessage = 'Unable to read file, coordinate transformation and mapping disabled.';
      sCoordMenu=[];
   end
   
else
   strMessage = 'File not found, coordinate transformation and mapping disabled.';
   sCoordMenu=[];
end
