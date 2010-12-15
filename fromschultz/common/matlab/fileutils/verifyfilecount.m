function bln = verifyfilecount(flist,strType,rng)

% EXAMPLE
% strPattern = '^a20.*bold.*\w+_(?<num>\d{1,2})3\.img$';
% rng = 11;
% strDir = pwd;
% strType = 'char'; % see getpatternfiles for strType(s)
% flist = getpatternfiles(strPattern,strDir,strType);
% bln = verifyfilecount(flist,strType,rng)

if isempty(flist)
    numFiles = 0;
else
    switch lower(strType)
        case 'char'
            numFiles = size(flist{1},1);
        case 'cas'
            numFiles = length(flist);
        otherwise
            error('wrong type for flist input')
    end
end

if ~isscalar(numFiles)
    error('numFiles not a scalar!?')
end

bln = ismember(numFiles,rng);

if ~bln
    fprintf('\nnumFiles = %d',numFiles)
    
end