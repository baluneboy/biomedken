function [t,sts] = spm_select_wrapper(varargin)
% File selector
% FORMAT [t,sts] = spm_select_wrapper(n,typ,mesg,sel,wd,filt,frames)
%     n    - Number of files
%            A single value or a range.  e.g.
%            1       - Select one file
%            Inf     - Select any number of files
%            [1 Inf] - Select 1 to Inf files
%            [0 1]   - select 0 or 1 files
%            [10 12] - select from 10 to 12 files
%     typ  - file type
%           'any'   - all files
%           'image' - Image files (".img" and ".nii")
%                     Note that it gives the option to select
%                     individual volumes of the images.
%           'xml'   - XML files
%           'mat'   - Matlab .mat files
%           'batch' - SPM batch files (.mat and XML)
%           'dir'   - select a directory
%           Other strings act as a filter to regexp.  This means
%           that e.g. DCM*.mat files should have a typ of '^DCM.*\.mat$'
%      mesg - a prompt (default 'Select files...')
%      sel  - list of already selected files
%      wd   - Directory to start off in
%      filt - value for user-editable filter (default '.*')
%      frames - Image frame numbers to include (default '1')
%
%      t    - selected files
%      sts  - status (1 means OK, 0 means window quit)
%
% Files can be selected from disk, but "virtual" files can also be selected.
% Virtual filenames are passed by
%     spm_select_wrapper('addvfiles',list)
%         where list is a cell array of filenames
% The list can be cleared by
%     spm_select_wrapper('clearvfiles')
%
% FORMAT [t,sts] = spm_select_wrapper('Filter',files,typ,filt,frames)
% filter the list of files (cell or char array) in the same way as the GUI would do.
% There is an additional typ 'extimage' which will match images with
% frame specifications, too. Also, there is a typ 'extdir', which will
% match canonicalised directory names.
%
% FORMAT cpath = spm_select_wrapper('CPath',path,cwd)
% function to canonicalise paths: Prepends cwd to relative paths, processes
% '..' & '.' directories embedded in path.
% path     - string matrix containing path name
% cwd      - current working directory [defaut '.']
% cpath    - conditioned paths, in same format as input path argument
%
% FORMAT [files,dirs]=spm_select_wrapper('List',direc,filt,frames)
% Returns files matching the filter (filt) and directories within dire
% direc    - directory to search
% filt     - filter to select files with (see regexp) e.g. '^w.*\.img$'
% frames   - vector of frames to select (defaults to [], if not specified)
% files    - files matching 'filt' in directory 'direc'
% dirs     - subdirectories of 'direc'
%
% EXAMPLES:
% %--------------------------------
% numberFiles = 2;
% strTypeFile = 'any'; % builtins: 'any','image','xml','mat','batch','dir'
%               % Other strings act as a filter to regexp.  This means
%               % that e.g. DCM*.mat files should have a typ of '^DCM.*\.mat$'
% strPrompt = 'Select files...';
% casAlreadySelected = {'c:\temp\temp\wiggles.txt','ClickHere'};
% strStartDir = 'c:\temp\temp';
% strFilterRegexp = '^w.*\.img$'; % default is '.*'
% [t,sts] = spm_select_wrapper(numberFiles,strTypeFile,strPrompt,casAlreadySelected,strStartDir,strFilterRegexp);
% %--------------------------------
% strDirectoryToSearch = 'c:\temp\temp';
% strFilterRegexp = '^w.*\.img$';
% [files,dirs] = spm_select_wrapper('List',strDirectoryToSearch,strFilterRegexp);

% Author: Ken Hrovat
% $Id: spm_select_wrapper.m 4160 2009-12-11 19:10:14Z khrovat $

[t,sts] = spm_select(varargin{:});
t = cellstr(t);
iCommas = find(find_str_cell(t,','));
if isempty(iCommas), return, end
for i = 1:length(iCommas)
    ind = iCommas(i);
    str = t{ind};
    iStart = findstr(str,',');
    if isempty(iStart), continue, end
    t{ind} = str(1:iStart-1);
end