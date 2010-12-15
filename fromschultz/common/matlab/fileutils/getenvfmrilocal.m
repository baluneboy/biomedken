function strDir = getenvfmrilocal
strDir = getenv('FMRILOCAL');
if ~isdir(strDir)
    warning('daly:filesys:dirNotFound','could not get env variable for fmri_local')
end