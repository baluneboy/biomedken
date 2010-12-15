function [raddata] = getraddata(data,sHeader,sSearch)

% GETRADDATA will retrieve rates and angles and center of mass data used in quasi-steady
% mapping.  It will retrieve data corresponding to the quasisteady acceleration data header
% and return a 1 to 1 correspondence of rates and angles data to acceleration data.
%
%
% Inputs:   sHeader - header structure for QS acceleration data
%           sSearch - search criteria structure from acceleration data
%       
% Author: Eric Kelly
% $Id: getraddata.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Change sSearch to reflect rates and angles data
% Add and subtract some time to assure bounds are good for
% interpolation later
sSearch.PathQualifiers.cSearchDirs ={'iss_rad_radgse'};
numHours = 1;
sSearch.PathQualifiers.sdnStart = sSearch.PathQualifiers.sdnStart - (numHours/24);
sSearch.PathQualifiers.sdnStop  = sSearch.PathQualifiers.sdnStop  + (numHours/24);

%Find relevant rates and angles files
sFiles = metagetfiles(sSearch);

if ~isempty(sFiles)
   
   % load and merge the files
   raddata = [];
   starttime = 0;
   endtime = 0;  
   for i = 1:length(sFiles.pad_iss_rad_radgse);
      
      % hfn is the header to the datafile, need to remove ".header" for data file
      hfn = sFiles.pad_iss_rad_radgse{i};   
      sFileHeader = padreadheader(sFiles.pad_iss_rad_radgse{i});
      
      % get the starttime of the file in Serial Date Number
      sdnTimeZero = popdatenum(convert1970time(sFileHeader.TimeZero));
           
      % the data filename
      fn = hfn(1:end-7); 
      
      % read in the entire data file
      fid = fopen(fn,'r');
      tempdata = fread(fid,[14,inf],'float');
      fclose(fid);
      tempdata = tempdata';      
      
      % Put rad data into absolute time in days
      tempdata(:,1) = tempdata(:,1)/86400 + sdnTimeZero;
      
      % append to raddata
      raddata = [raddata; tempdata];
      clear tempdata;
   end
end
