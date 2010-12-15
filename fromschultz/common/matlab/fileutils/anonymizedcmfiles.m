function anonymizedcmfiles(strPath,strBad,strGood)

% anonymizedcmfiles - function to anonymize dcm (dicom) files
%
% anonymizedcmfiles(strPath,'BURDSALL^RICHARD','riburcont');
%
%
strPath = fixpath(strPath);
values.StudyInstanceUID = dicomuid;
values.SeriesInstanceseriesUID = dicomuid;
d = dir([strPath filesep '*.dcm']);
cd(strPath)
for p = 1:numel(d)
    strOld = d(p).name;
    sOld = dir(strOld);
    strNew = strrep(strOld,strBad,strGood);
    dicomanon(strOld,strNew,'update',values);
    sNew = dir(strNew);
    if sNew.bytes < 0.95*sOld.bytes
        warning('size new: %s (%d), old: %s (%d)\n',strOld,sOld.bytes,strNew,sNew.bytes)
    else
        delete(strOld)
    end
    fprintf('anonymized %s\n',strNew)
end