function [sHandles,casRackQSData] = qscomp_overview(varargin);

% Get inputs from syntax 
switch nargin
case 2 % gui call
   [hDisposalFig,sParameters]=deal(varargin{:});
   h=guidata(hDisposalFig);
   data=h.data;
   sHeader=h.sHeader;
   sSearch=h.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   strComment=sParameters.strComment;
   sCoord=sParameters.sCoord;
   sMap=sParameters.sMap;
case 4 % command line call
   [data,sHeader,sParameters,strComment]=deal(varargin{:});
   sSearch=sParameters.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   sCoord=sParameters.sCoord;
   sMap=sParameters.sMap;   
otherwise
   error('wrong nargin')
end

% Plot the template
[sHandles] = plotqsoverview;
hFig = sHandles.Figure11;

% Get the rack positions
strRackLoc = which('rackloc.dat');
[x,y,z,casAltName,casRackName] = textread(strRackLoc,'%f %f %f %s %s');
Rdata = [x y z];
clear x y z;

% This plot is always in SSA coordinates;
[sCoordMenu,strMessage] = readcoordfile;
index=find(strcmp(sCoordMenu.Name,'SSAnalysis'));
sCoord.Name = sCoordMenu.Name{index};
sCoord.Comment = sCoordMenu.Comment{index};
sCoord.XYZ = sCoordMenu.XYZ{index};
sCoord.RPY  = sCoordMenu.RPY{index};
sCoord.Time = sCoordMenu.Time{index};

% Trim the data to one orbit.
% The duration of one orbit in seconds
orbitlength =  5400;
   
% Determine appropriate sampling interval in number of points
interval = round(orbitlength * sHeader.SampleRate);
data = data(1:interval,:);
%%%%NEED TO REFLECT TRIMMING DATA IN HEADER%%%%

% Coordinate System Transformation
% compare the Name and Time, if they are different, do transformation
if ~(strcmp(sHeader.DataCoordinateSystemName,sCoord.Name)...
      & strcmp(sHeader.DataCoordinateSystemTime,sCoord.Time))
   [data,sHeader] = transformcoord(data,sHeader,sCoord);
end

% Get top Right standard lines of ancillary text
sText.casUR=top2textur(sHeader);
% Get top left standard lines of ancillary text
sText.casUL=top2textul(sHeader);

% DO Mapping Routines for quasi-steady data
%if ~isempty(findstr(sHeader.DataType,'tmf'))
%  if ~(strcmp(sHeader.SensorCoordinateSystemName, sMap.Name) &...
%        strcmp(sHeader.SensorCoordinateSystemComment,sMap.Comment)); 
%     sTempParam.sMap = sMap;sTempParam.sCoord=sCoord;
%     [data,sHeader] = qsmapping(data,sHeader,sTempParam,sSearch);
%   end
%end

for i=1:length(casRackName)
   % Create the parameters to be used in mapping algorithm
   sParameters.sMap.Name = casRackName{i};
   sParameters.sMap.XYZ = Rdata(i,:);
   sParameters.sMap.Comment;
   
   % mdata is mapped data, msHeader is mapped header file
   % Use this one for normal
   [mdata,msHeader] = qsmapping(data,sHeader,sParameters,sSearch,1);
   
   %Use this one for AC projections 
   %[mdata,msHeader] = qsmapping_over(data,sHeader,sParameters,sSearch,1);
   %[qscdata] = calcqsvector(mdata,interval);
   
   orbavg = nanmean(mdata(:,2:4));
   orbavg_vec = orbavg';
   orbavg_mag = pimsrss(orbavg(1),orbavg(2),orbavg(3)); 
   Uavg = orbavg_vec/orbavg_mag;
   
   % Make a 3x1xinterval array to dot with the acceleration data
   Uavg_3d = zeros(3,1,interval);
   Uavg_3d(1,1,:) = Uavg(1);
   Uavg_3d(2,1,:) = Uavg(2);
   Uavg_3d(3,1,:) = Uavg(3);
   
   %Reshape the acceleration data to speed perpendicular comp calculation
   A = reshape (mdata(1:interval,2:4)',3,1,interval);
   
   % Calculate the magnitudes
   alongmag = squeeze(dot(A,Uavg_3d,1));
   mag = pimsrss(mdata(:,2),mdata(:,3),mdata(:,4));
   perpmag = sqrt(mag.^2 - alongmag.^2);
   
   % Alternative calculation
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %	alongmag2=zeros(size(mdata,1),1);
   %	mag2=alongmag2;
   %	perpmag2=alongmag2;
   %	for jj = 1:size(mdata,1)
   %		acc_vec = [mdata(jj,2);mdata(jj,3);mdata(jj,4)];
   %		alongmag2(jj)=dot(acc_vec,Uavg);
   %		mag2(jj)=pimsrss(mdata(jj,2),mdata(jj,3),mdata(jj,4));
   %		perpmag2(jj)=sqrt(mag2(jj)^2 - alongmag2(jj)^2);
   %	end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % In microg
   maxmag = max(mag)*1e6;
   maxperp = max(perpmag)*1e6;
   
   
   %casRackQSData{i} = {casRackName{i},max(mag),max(perpmag)};  
   casRackQSData{i} = {casRackName{i},Rdata/12,[min(mag) nanmean(mag) max(mag)],...
         [min(perpmag) nanmean(perpmag) max(perpmag)],orbavg_vec,Uavg};

   sHandles = locUpdateRack(sHandles,casRackName{i},maxmag,maxperp);
   pause(0.01);
   
end

h = get(0,'UserData');
indComma= findstr(sHeader.ISSConfiguration,',');
strIncrement = sprintf('Inc%02d',str2num(sHeader.ISSConfiguration(indComma-2:indComma-1)));
strTemp = popdatestr(sHeader.sdnDataStart,-4);
strDOY= [strTemp(1:4) '_' strTemp(6:8)];
strPath = fullfile(h.sUser.ResultsPath,strIncrement,'qsoverview',strDOY);
if ~exist(strPath)
   [statusVal,strMsg]=pimsmkdir(strPath);
end

save(fullfile(strPath,'qsoverviewdata'),'casRackQSData');

strFileName = fullfile(strPath,sprintf('qsoverview_%s',strDOY));
loc_WriteQSCompReport(strFileName,casRackQSData,msHeader,orbitlength);

%-----------------------------------------------------------------------%
function sHandles=locUpdateRack(sHandles,strRackName,mag,perp);

strPatchTag = ['Patch' strRackName];
strMagTag = ['Text' strRackName 'Mag'];
strPerpTag = ['Text' strRackName 'Perp'];

%Magnitude
strMagOutput = sprintf('M: %5.2f',mag);
hText = getfield(sHandles,strMagTag);
set(hText,'String',strMagOutput);

%Perp magnitude
strPerpOutput = sprintf('P: %5.2f',perp); 
hText = getfield(sHandles,strPerpTag);
set(hText,'String',strPerpOutput);

% Color of rack, 0 out = green, perp out= yellow, mag out =  orange, both out = red
if mag > 1;
   if perp > .2
      rackcolor = [1 .5 .5];%red
   else
      rackcolor = [1 .75 .5];%orange
   end
else %mag <1
   if perp > .2
      rackcolor = [.9 .9 .6];%yellow
   else
      rackcolor = [.56 .8 .56];%green
   end
end

hPatch = getfield(sHandles,strPatchTag);
set(hPatch,'FaceColor',rackcolor);

%-----------------------------------------------------------------------%
function loc_WriteQSCompReport(strFileName,casData,sHeader,orbitlength);

% Writes a csv from data generated by qscomp_overview

if ~exist(strFileName)
   % Create the file
   fid = fopen(strFileName,'w');
   
   % Create the header
   strHeader1 = 'GMT,, at';
   % Rack names and XYZ values
   for i = 1:length(casData)
      strRackName = casData{i}{1};
      Rdata = casData{i}{2};
      strHeader1 = [strHeader1 sprintf('%s: [%6.2f %6.2f %6.2f] (ft.),,,,,,',strRackName,Rdata)];
   end
   
   % Start End Mag, Perp Mag titles
   strHeader1 = sprintf('%s\nStart,End,',strHeader1);
   for i = 1:length(casData)
      strHeader1 = [strHeader1 'Magnitude(ug),,,Perpendicular Component(ug),,,'];
   end
   
   % Min Mean Maxes
   strHeader1 = sprintf('%s\n,,',strHeader1);
   for i = 1:length(casData)
      strHeader1 = sprintf('%smin,mean,max,',strHeader1);
   end
   
   filerow = fprintf(fid,'%s\n',strHeader1)
   fclose(fid);
   
   %Recall the Report and enter first line
   loc_WriteQSCompReport(strFileName,casData);
   
else
   % File exist, need to append a line
   fid = fopen(strFileName,'r+');
   
   for i = 1:length(casData)
      strRackName = casData{i}{1};
      mag = casData{i}{3}*1e6;
      perpmag = casData{i}{4}*1e6;
      orbavg = casData{i}{5}*1e6;
      Uavg = casData{i}{6};
      
      strStartTime = strrep(popdatestr(sHeader.sdnDataStart,-1),',',' ');
      strEndTime = strrep(popdatestr(sHeader.sdnDataStart+orbitlength,-1),',',' ');
      
      strLine = sprintf('%s,%s,%7.2f,%7.2f,%7.2f,%7.2f,%7.2f,%7.2f',strRackName,mag,perpmag);
      
   end
   filerow = fprintf(fid,'%s\n',strLine); 
   fclose(fid);
end





