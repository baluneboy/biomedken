function strDir = getenvmritemp
strDir = getenv('MRITEMP');
if isempty(strDir)
    error('daly:env:varNotFound','could not get env variable value for MRITEMP, e.g. "c:\\temp\\fmri_data\\originals"')
end
if ~isdir(strDir)
    error('daly:filesys:dirNotFound','directory %s does not exist',strDir)
end