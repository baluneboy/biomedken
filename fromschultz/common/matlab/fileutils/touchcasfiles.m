function touchcasfiles(strDate,casFiles)

% EXAMPLE
% strDate = '1984-04-30';
% casFiles = {'C:\data\fmri\fromopticalmedia\temp4pre\s1374plas\13740000\dcm\68911178';'C:\data\fmri\fromopticalmedia\temp4pre\s1374plas\13740000\dcm\68911194'};
% touchcasfiles(strDate,casFiles)

casDates = cellstr(repmat(strDate,length(casFiles),1));
cellfun(@touch,casDates,casFiles);