function [data,sHeader] = qsmapping(data,sHeader,sParameters,sSearch,varargin)


% Retrieve rates and angles data.  Return vector should match up with a 1:1 correspondance
% with the trimmed mean filtered data.  

% Written by Eric Kelly
% $Id: qsmapping.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin==5
   flagRackCenters=deal(varargin{:});
else
   flagRackCenters=0;
end

if (sParameters.sMap.ODRC==0) % Use PAD file rates and angles
   
   % Get the rates and angles data raddata = [t q0 q1 q2 q3 wx wy wz cmx cmy cmz]
   [raddata] = getraddata(data,sHeader,sSearch);
      
   if isempty(~raddata)
      display ('No RADGSE Files found for time period selected');
      return;
   end
     
else % Use MEWS data   
   if ~isfield(sParameters.sMap,'strCSVFile');
      [strFileName,strPathName] = uigetfile('*.csv','Find RAD data');
      strCSVFile = fullfile(strPathName,strFileName);
   else
      strCSVFile = sParameters.sMap.strCSVFile;
   end
   % read in the RAD data
   raddata = readmewscsv(strCSVFile); 
end

% Do the mapping
[osstemp,loctemp] = qsmap(raddata,sHeader,sParameters);

% make a 1 to 1 correspondance for acceleration data and gg,rot components
trad = (raddata(:,1)-sHeader.sdnDataStart)*86400;
clear raddata;

% OSS components
osscomp.gg(:,1) = linterp(trad,osstemp.gg(:,1),data(:,1));
osscomp.gg(:,2) = linterp(trad,osstemp.gg(:,2),data(:,1));
osscomp.gg(:,3) = linterp(trad,osstemp.gg(:,3),data(:,1));
osscomp.rot(:,1) = linterp(trad,osstemp.rot(:,1),data(:,1));
osscomp.rot(:,2) = linterp(trad,osstemp.rot(:,2),data(:,1));
osscomp.rot(:,3) = linterp(trad,osstemp.rot(:,3),data(:,1));
clear osstemp;

%Location components
loccomp.gg(:,1) = linterp(trad,loctemp.gg(:,1),data(:,1));
loccomp.gg(:,2) = linterp(trad,loctemp.gg(:,2),data(:,1));
loccomp.gg(:,3) = linterp(trad,loctemp.gg(:,3),data(:,1));
loccomp.rot(:,1) = linterp(trad,loctemp.rot(:,1),data(:,1));
loccomp.rot(:,2) = linterp(trad,loctemp.rot(:,2),data(:,1));
loccomp.rot(:,3) = linterp(trad,loctemp.rot(:,3),data(:,1));
clear loctemp; 

% This is to interpolate gg and components
if (sParameters.sMap.Interp==1)
   osscomp.gg = multispline([data(:,1) osscomp.gg],5,'spline');
   osscomp.rot = multispline([data(:,1) osscomp.rot],5,'linear');
   loccomp.gg = multispline([data(:,1) loccomp.gg],5,'spline');
   loccomp.rot = multispline([data(:,1) loccomp.rot],5,'linear');
end

% convert the osscomp and location components to data coordinate system found in sHeader
% compare the Name and Time, if they are different, do transformation.  This assumes
% transformation of acceleration data is done before mapping.
if ~(isequal(sHeader.DataCoordinateSystemRPY,[0 0 0]))
   sTemp.DataCoordinateSystemRPY = [0 0 0];
   
   [osscomp.gg,trash] = transformcoord(osscomp.gg,sTemp,sParameters.sCoord);
   [osscomp.rot,trash] = transformcoord(osscomp.rot,sTemp,sParameters.sCoord);
   [loccomp.gg,trash] = transformcoord(loccomp.gg,sTemp,sParameters.sCoord);
   [loccomp.rot,trash] = transformcoord(loccomp.rot,sTemp,sParameters.sCoord);
   
end

% Subtract oss components from data and add LOCATION components
% X-Axis components
data(:,2) = data(:,2) - osscomp.gg(:,1) - osscomp.rot(:,1) + loccomp.gg(:,1) + loccomp.rot(:,1);
% Y-Axis components
data(:,3) = data(:,3) - osscomp.gg(:,2) - osscomp.rot(:,2) + loccomp.gg(:,2) + loccomp.rot(:,2);
% Z-Axis components
data(:,4) = data(:,4) - osscomp.gg(:,3) - osscomp.rot(:,3) + loccomp.gg(:,3) + loccomp.rot(:,3);

% Update the new header
sHeader.SensorCoordinateSystemName = sParameters.sMap.Name;
sHeader.SensorCoordinateSystemXYZ = sParameters.sMap.XYZ;
sHeader.SensorCoordinateSystemComment = sParameters.sMap.Comment;
%end



