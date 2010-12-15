function c = veryspecialviconread(strFile)

%
% put good help/comments here, but quickly for now, just...
%
% EXAMPLES:
% strFile = 's:\data\upper\trial7_blank.txt';
% tic, c = veryspecialviconread(strFile); toc; c{1}(1:3,:), c{2}(1:3,:)
%
% strFile = 's:\data\upper\trial7';
% tic, d = veryspecialviconread(strFile); toc; c{1}(1:3,:), c{2}(1:3,:)
%
% % This program has some pretty stiff assumptions ( user beware )
% % you also need viconparse.pl on your path

% Author: Ken Hrovat
% $Id: veryspecialviconread.m 4160 2009-12-11 19:10:14Z khrovat $

% get 1st chunk
fid = fopen(strFile);
trash = fgetl(fid);
rows = [];
while 1
    c = fgetl(fid);
    if ~ischar(c) || isempty(c), break, end
    thisRow = sscanf(c,repmat('%f',1,62))';
    rows = [rows; thisRow];
end
fclose(fid);
c{1} = rows;

% get 2nd chunk
numBlank = str2num(perl('viconparse.pl',strFile));
fid = fopen(strFile);
a = textscan(fid,'%f%f','delimiter','\t','headerlines',numBlank+1,'collectoutput',1);
fclose(fid);
c{2} = a{1};