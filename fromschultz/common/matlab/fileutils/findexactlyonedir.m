function strDir = findexactlyonedir(strPat,strDirParent)

%EXAMPLE
% strTask = 'shoulder';
% strPat = ['^series_\d{2}_' strTask '_.*'];
% strDirParent = 'C:\data\fmri\adat\c1367plas\preone\study_20090922';
% strDir = findexactlyonedir(strPat,strDirParent)

casDirs = getpatterndirs(strPat,strDirParent);
if numel(casDirs) ~= 1
    error('daly:fmri:getpatterndirsCount','expected exactly one match for "%s" in "%s", but found %d',strPat,strDirParent,numel(casDirs));
end
strDir = casDirs{1};