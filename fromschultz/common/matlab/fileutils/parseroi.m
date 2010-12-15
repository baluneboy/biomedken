function [xt,yt,zt,r,p,iActive] = parseroi(strMask,rThreshold)

% parseroi - function to parse BV roi text file
%
% [xt,yt,zt,r,p,iActive] = parseroi(strMask,rThreshold);
%
% INPUTS:
% strMask - string of mask for input files to parse
% rThreshold (optional) - scalar threshold on r; default = 0.35
%
% OUTPUTS:
% xt,yt,zt - vectors for Talairach (normalized) x,y,z voxel coord's
% r - vector of statistic value (correlation)
% p - vector of p-values
% iActive - vector of indexes for active voxels
%
% %EXAMPLE:
% strMask = 'roi*.txt';
% rThreshold = 0.35;
% [xt,yt,zt,r,p,iActive] = parseroi(strMask,rThreshold);

% Get inputs
if ~exist('rThreshold')
    rThreshold = 0.35; % this can be a vector or range of values
end
if ~exist('strMask')
    strMask = 'roi*.txt';
end
disp(['Working on files like ' strMask]);

% Load file list
[casFiles,de] = dirdeal(fullfile(pwd,strMask));

fprintf('\nstrLabel,rThreshold,#Active\n')
for j = 1:length(casFiles)
    strFile = casFiles{j};
    fid = fopen(strFile);
    r = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        if char(regexpi(tline, '\w*details for voi\w*','match'))
            strLabel = strsplit('"',tline);
            strLabel = strrep(strLabel{2},' ','');
        end
        if ~isempty(tline) && strcmp(tline(1),'-')
            numSkipLines = r;
            break
        end
        r = r + 1;
    end
    fclose(fid);

    fid = fopen(strFile);
    C = textscan(fid,'%f %f %f %f %f','headerlines',numSkipLines,'MultipleDelimsAsOne',1);
    fclose(fid);
%     xt = 128 - C{1};
%     yt = 128 - C{2};
%     zt = 128 - C{3};
    xt = C{1};
    yt = C{2};
    zt = C{3};
    r = C{4};
    p = C{5};

    for i = 1:length(rThreshold)
        rt = rThreshold(i);
        %         iRight = find(xt > 0 & r >= rt);
        %         iLeft = find(xt <= 0 & r >= rt);
        iActive = find(r >= rt);
        fprintf('%s,%0.4f,%d\n',strLabel,rt,length(iActive))
    end
end
fprintf('\n')