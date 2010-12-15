function fsearch(theString, varargin)

% string search in files.
%  fsearch (no argument) demonstrates itself by
%   searching for the word "demo" in its own
%   M-file.
%  fsearch('theString') searches the current directory for
%   'theString' (not case-sensitive), which may contain
%   asterisk (*) wildcards.
%  fsearch('theString', 'file1', 'file2', ...) searches
%   just the given files, as interpreted by the Matlab
%   "which" function.  Names wildcarded with asterisks (*)
%   are interpreted by the Matlab "dir" and "which" functions.
%  fsearch(..., 'option1', option2', ...) applies the given
%   options (must be at end of argument list).
%  Options: '-r' as final argument causes recursive
%   search, starting at the current directory.
% Also see help on: dir, findstr, which
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Jan-2000 11:27:57.
% Updated    04-Jan-2000 20:20:47.

persistent LEVEL
persistent FOUND

if nargin < 1
	help(mfilename)
	s = 'fsearch(''demo'', ''fsearch.m'')';
	disp(s)
	eval(s)
	return
end
if nargin < 2, varargin = {'*'}; end

if isempty(LEVEL), LEVEL = 0; end
if isempty(FOUND), FOUND = ~~0; end

CR = char(13);
LF = char(10);
CRLF = [CR LF];

isRecursive = ~~0;
if isequal(varargin{end}, '-r')
	isRecursive = ~~1;
	varargin(end) = [];
	if isempty(varargin), varargin = {'*'}; end
end

for k = 1:length(varargin)
	theFiles = varargin{k};
	isWildcard = any(theFiles == '*');
	if isWildcard
		d = dir(theFiles);   % Need to be careful here.
		f = [];
		for i = 1:length(d)
			if ~d(i).isdir
				f{end+1} = d(i).name;
			elseif isRecursive
			end
		end
		theFiles = f;
	else
		theFiles = varargin(k);
    end
	for j = 1:length(theFiles)
        nFirst{j} = [];
		theFileName = theFiles{j};
		if any(theFileName)
			theFilePath = which(theFileName);
			fp = fopen(theFileName, 'r');
			if fp >= 0
				t = char(fread(fp)).';
				fclose(fp);
				t = strrep(t, 'CRLF', 'CR');
				t = strrep(t, 'LF', 'CR');
				t(end+1) = CR;
				t = [CR t];
				s = lower(t);
				theStr = lower(theString);
				if any(theStr == '*')
					theStr = [theStr '*' CR];   % How to restrict this?
				end
				pos = findstr1(s, theStr);   % Note "findstr1".
				if any(pos)
					eol = findstr1(s, CR);
					before = eol(1:end-1);
					after = eol(2:end);
					thePrecision = ceil(log10(max(after)));
					prev = 0;
					for i = 1:length(pos)
						f = find(pos(i) > eol(1:end-1) & ...
									pos(i) < eol(2:end));
						if any(f) & f > prev
							prev = f;
							FOUND = ~~1;
							theLine = int2str(f);
							while length(theLine) < thePrecision
								theLine = [' ' theLine];
							end
							theText = t(before(f)+1:after(f)-1);
							f = find(theText > ' ');
							if any(f), theText = theText(f(1):f(end)); end
							disp([' ## File "' theFilePath '"; Line ' theLine ' ## ' theText])
                            nFirst{j} = [nFirst{j} theLine];
						end
					end
				end
			else
				disp([' ## Unable to open: ' theFileName])
			end
		end
	end
	if isRecursive
		d = dir;
		for i = 1:length(d)
			if d(i).isdir
				thePWD = pwd;
				LEVEL = LEVEL+1;
				try
					cd(d(i).name)
					feval(mfilename, theString, varargin{k}, '-r')
				catch
					disp([' ## Error while processing:'])
					disp(theFiles(:))
				end
				cd(thePWD)
				LEVEL = LEVEL-1;
			end
		end
	end
end

if LEVEL <= 0
	if ~FOUND, disp([' ## None found.']), end
	LEVEL = [];
	FOUND = [];
end


% ---------- findstr1 ---------- %


function theResult = findstr1(theText, theString)

% findstr1 -- Find string, using * wildcard.
%  findstr('demo') demonstrates itself.
%  findstr1('theText', 'theString') searches 'theText'
%   for all examples of 'theString', which may include
%   one or more asterisks '*' as wildcards, representing
%   zero or more characters.  The sought-after string may
%   also contain escaped characters, preceeded by backslash
%   '\', and followed by one of '\bfnrt'.  The routine
%   returns or displays the indices of the starts of all
%   qualifying strings.  Not case-sensitive.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Jan-2000 15:13:15.
% Updated    04-Jan-2000 21:34:49.

if nargout > 0, theResult = []; end

if nargin < 1, theText = 'demo'; end

if nargin < 2 & isequal(theText, 'demo')
	help(mfilename)
	theCommand = [mfilename '(''abracadabra'', ''a*b*a'')'];
	disp(theCommand)
	disp(mat2str(eval(theCommand)))
	return
end

if size(theText, 2) == 1, theText = theText.'; end
if size(theString, 2) == 1, theString = theString.'; end

special = '\bfnrt';
for i = 1:length(special)
	s = ['\' special(i)];
	theString = strrep(theString, s, sprintf(s));
end

while any(findstr(theString, '**'))
	theString = strrep(theString, '**', '*');
end

f = find(theString ~= '*');
if any(f)
	theString = theString(f(1):f(end));
end

theString = ['*' theString '*'];
stars = find(theString == '*');

result = [];
len = 0;

for i = 1:length(stars)-1
	s = theString(stars(i)+1:stars(i+1)-1);
	len = len + length(s);
	f = findstr(theText, s);
	if isempty(f)
		result = [];
	elseif i == 1
		result = f;
	elseif any(result)
		okay = find(result+len <= max(f)+length(s));   % Careful.
		result = result(okay);
	end
	if isempty(result), break, end
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
