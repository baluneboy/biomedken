function [strDate,sdn] = getfiledate(strFile,fmt)

% EXAMPLE:
% strDirDicom = getdicompath;
% casFilesDicom = getdicomfiles(strDirDicom);
% strFile = casFilesDicom{1};
% strDate = getfiledate(strFile)

if nargin == 1
    fmt = 29; % see datestr for fmt code
end
s = dir(strFile);
sdn = s.datenum;
strDate = datestr(sdn,fmt);
