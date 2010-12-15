function strDir = getenvsdataupper
strDir = getenv('SDATAUPPER');
if ~isdir(strDir)
    warning('daly:filesys:dirNotFound','could not get env variable for schultz/data/upper')
end