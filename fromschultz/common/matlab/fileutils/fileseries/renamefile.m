function renamefile(f,pat1,pat2)
%RENAMEFILE  Rename a series of files.
%   RENAMEFILE(NAME, P1, P2) renames the files matching NAME, replacing
%   the substring P1 by P2. NAME may be a cell array of strings, and may
%   contain wildcards (*) and brackets (see EXPANDSTR).
%
%   Examples:
%      RENAMEFILE('DSC*.JPG','DSC','myphoto')
%      renames the files 'DSC00001.JPG','DSC00002.JPG',... as
%      'myphoto00001.JPG','myphoto00002.JPG',...
%
%      RENAMEFILE('*/DSC*.JPG','DSC','myphoto')
%      does the same in all the directories containing JPG files.
%
%      RENAMEFILE('B[1:100,3]*.VEC','B','PIV') renames the files
%      'B001*.VEC' to 'B100*.VEC' as 'PIV001*.VEC' to 'PIV100*.VEC'
%
%   See also RENUMBERFILE, MOVEFILE, EXPANDSTR, RDIR, GETFILENUM.


%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.10,  Date: 2006/09/08


% History:
% 2005/10/04: v1.00, first version.
% 2005/10/06: v1.01, details.
% 2006/09/08: v1.10, faster


error(nargchk(3,3,nargin));

if ~strcmp(pat1,pat2),
    oldfilename=rdir(f); % expands brackets ([]) and resolves wildcards (*)
    newfilename=strrep(oldfilename,pat1,pat2);
    for i=1:length(oldfilename),
        movefile(oldfilename{i},newfilename{i});
    end;
end;
