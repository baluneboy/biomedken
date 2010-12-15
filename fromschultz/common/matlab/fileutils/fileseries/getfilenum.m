function num=getfilenum(f,pat)
%GETFILENUM  Get the index of a series of files.
%   NUM = GETFILENUM (NAME, P) returns an array of integers indexing
%   the filenames (or directory names) matching NAME from the current
%   directory. The integers are searched in the strings following the
%   substring P. Wildcards (*) and brackets ([], see EXPANDSTR) may be used
%   in NAME, including in intermediate pathnames.
%
%   Examples:
%
%     If the files 'B01_t12.vec','B02_t18.vec', 'B03_t24.vec' are present
%     in the current directory,
%     getfilenum ('*.vec', '_t') returns [12 18 24].
%
%     n=getfilenum('*/*.JPG','DSC') returns the indices of JPG-files.
%
%   See also EXPANDSTR, RDIR, RENUMBERFILE.


%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.10,  Date: 2006/09/06


% History:
% 2005/10/04: v1.00, first version.
% 2005/10/06: v1.01, works also with directory names.
% 2005/10/14: v1.02, help text changed.
% 2006/09/08: v1.10, bug fixed (use str2num, NOT str2double!!)

error(nargchk(2,2,nargin));

filename=rdir(f,'filedir'); % changed v1.01

num=[];
nnum=0; % number of file numbers found

for i=1:length(filename),
    fname=filename{i};
    p=findstr(fname,pat);
    if length(p),
        p=p(1)+length(pat); % position of the first digit
        if length(str2num(fname(p))), % if it is indeed a digit
            nnum=nnum+1;
            strn='';
            % builds the string of the number as long as digits are found:
            while length(str2num(fname(p))),
                strn=[strn fname(p)];
                p=p+1;
                if p>length(fname), break; end; % exit the while loop
            end;
            num(nnum)=str2num(strn);
        end;
    end;
end;
