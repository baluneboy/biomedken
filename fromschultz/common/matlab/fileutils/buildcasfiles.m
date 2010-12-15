function casFiles = buildcasfiles(strDir,casFileList)

% EXAMPLE
% strDir = 'c:\path\of\interest';
% casFileList = {'fileOne.txt','fileTwo.dat','fileThree.log'};
% casFiles = buildcasfiles(strDir,casFileList)

casFiles = strcat(fixpath(strDir),filesep,casFileList)