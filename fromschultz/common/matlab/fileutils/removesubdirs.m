function removesubdirs(strDirTop,strPatternBasename)

% EXAMPLE
% strDirTop = 'c:\temp\fmri_data\originals\s1369plas\pretwo\study_20091203';
% strPatternBasename = '^dcm$';
% removesubdirs(strDirTop,strPatternBasename);

% Get all subdirs
casDirsSub = getsubdirs(strDirTop);

% Get basenames
casBases = cellfun(@basename,casDirsSub,'uni',false);

% Get subset of subdirs where basename matches pattern
indRemove = findnonemptycells(regexp(casBases,strPatternBasename));

% Remove matching subdirs
for i = 1:length(indRemove)
    ind = indRemove(i);
    strDirSub = casDirsSub{ind};
    [SUCCESS,MESSAGE,MESSAGEID] = rmdir(strDirSub,'s');
    if ~SUCCESS
       warning('daly:common:fileio','could not remove "%s"',strDirSub) 
    end
end