function casFiles = getexcelfiles(strWild)

% % EXAMPLE
% strWild = 'fugl';
% casFiles = getexcelfiles(strWild);

% Constants
strPath = 's:\data\upper\clinical_measures';

% Load housekeeping (cFiles)
load([strPath filesep 'housekeeping' filesep strWild '.mat']);
casFilesOld = cFiles(:,1);
blnKeepers = cell2mat(cFiles(:,2));
indKeepers = find(blnKeepers);
casFilesKeepers = casFilesOld(indKeepers);

% Load all files
casFilesAll = dirbs([strPath filesep '*' strWild '*.xls']);
casFilesNew = setdiff(casFilesAll,casFilesOld);

disp('Give SPM helper functions a little time to initialize...')
strMsg = sprintf('Deselect unwanted files from bottom list of %d newly found...',numel(casFilesNew));
[t,sts] = spm_select(inf,'any',strMsg,casFilesNew,strPath);
casFilesToAdd = cellstr(t);

casFiles = cappend(casFilesOld,casFilesToAdd);

blnNew = ones(numel(casFilesToAdd),1);
bln = [blnKeepers(:); blnNew(:)];

clear cFiles
cFiles = {};
[cFiles{1:length(casFiles),1}] = deal(casFiles);
[cFiles{1:length(casFiles),2}] = deal(bln);
save([strPath filesep 'housekeeping' filesep strWild '.mat'],'cFiles');