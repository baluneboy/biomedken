function varargout = batch_process(strAction,casFiles)

if nargin == 1
    % get files
    casFiles = uipickfiles('out','cell');
end

% the main loop over files
for i = 1:length(casFiles)
    strFile = casFiles{i};
    %fprintf('\nWorking on file: %s ... ',strFile)
    if strcmpi('write_evt',strAction)
        movelen(i)=locSwitchYard(strFile,strAction);
    else
        locSwitchYard(strFile,strAction);
    end
    %fprintf(' %s done\n',strFile)

end
fprintf('\n')

if strcmpi('write_evt',strAction)
    varargout{2}=movelen;
end
varargout{1} = casFiles;

% ---------------------------------------
function varargout=locSwitchYard(strFile,strAction)
switch lower(strAction)
    case 'check_gaps'
        [ind,x,y,vx,vy,fx,fy,fz] = roboread(strFile);
        [numGaps,iBad,gapLengths] = gapdetector(strFile);
        fprintf(['\n%s,%d' repmat(',%d',1,length(gapLengths))],strFile,numGaps,gapLengths)
    case 'check_oneslot'
        [ind,x,y,vx,vy,fx,fy,fz] = roboread(strFile);
        [timeon, sampleon] = generalDelay(y, 0.02, 'one', 'yes', 200, 'no','high');
    case 'crago'
        [ind,x,y,vx,vy,fx,fy,fz] = roboldread(strFile);
        n = num_samples(ind,x,y,vx,vy,fx,fy,fz);
        a = dir(strFile);
        strDate = datestr(a.datenum);
        fprintf('\n%s,%s,%d,%d',strFile,strDate,n,a.bytes)
    case 'whim_amat'
        [strOut,strSubject,preTime,postTime] = getamatpreposttotaltime(strFile);
        fprintf('\n%s',strOut)
    case 'num_samples'
        [ind,x,y,vx,vy,fx,fy,fz] = roboread(strFile);
        n = num_samples(ind,x,y,vx,vy,fx,fy,fz);
        fprintf('<< num_samples = %d (pts) >>',n)
    case 'last_y'
        [ind,x,y,vx,vy,fx,fy,fz] = roboread(strFile);
        yLast = y(end);
        fprintf('<< last_y = %.4f (m) >>',yLast)
    case 'write_evt'
        varargout{1}=createeventcol(strFile);
    case 'moco' % motion correction measures
        [tra_mm,rot_deg] = moco(strFile);
        fprintf('<< RSS(tra) = %.2f (mm), RSS(rot) = %.2f (deg) >>',tra_mm,rot_deg)
    case 'getvoxels'
        xyz = [62 -28 10; -38 -28 40];
        v = getvoxels(strFile,xyz);
        T = locGetLabel(strFile);
        t = T*ones(size(v));
        m = [xyz v(:) t(:)]';
        for i = 1:length(v)
            thism = m(:,i);
            strOut = sprintf('_gotvoxels_%d_%d_%d.csv',xyz(i,1),xyz(i,2),xyz(i,3));
            fid = fopen(strOut,'a');
            fprintf(fid,'%.1f,%.1f,%.1f,%g,%g\n',thism)
            fclose(fid)
        end
    case 'assessgetmodifiedashworthprepostscores'
        [strSubject,preScore,postScore,strOut]=assessgetmodifiedashworthprepostscores(strFile);
        disp(strOut)
    otherwise
        warning('unknown action %s',strAction)
end

% ---------------------------------
function t = locGetLabel(strFile)
pat = '(?<Prefix>\w+)_(?<Time>\d{3}).img'; % 'snrfM00223_085.img';
n = regexpi(strFile, pat, 'names');
t = str2num(n.Time);

% ------------------------------------------------------------------------
% You may need to add some of these paths...
% addpath('c:\path\to\workcopy\common\matlab\serob\trunk')
% addpath('c:\path\to\workcopy\common\matlab\pimselmat\trunk')
% addpath('c:\path\to\workcopy\common\matlab\pimsdatafun\trunk')
% addpath('c:\path\to\workcopy\common\matlab\pimssignal\trunk')
% addpath('c:\path\to\workcopy\common\matlab\pimsstrfun\trunk')
% addpath('c:\path\to\workcopy\common\matlab\geometry\trunk')
% addpath('c:\path\to\workcopy\robo\trunk\outcome_measures')
% addpath('c:\path\to\workcopy\robo\trunk\chase')
% addpath('c:\path\to\workcopy\robo\trunk\gates')
% addpath('c:\path\to\workcopy\robo\trunk')
% addpath('c:\path\to\workcopy\smoothness\trunk')
% addpath('c:\path\to\workcopy\common\matlab\son\trunk')
% addpath('c:\path\to\workcopy\common\matlab\fileutils\trunk\fileseries')
% addpath('c:\path\to\workcopy\common\matlab\timeutils\trunk')
% addpath('c:\path\to\workcopy\common\matlab\fileutils\trunk')
% addpath('c:\path\to\workcopy\synchrob\trunk\mu_amp')
% addpath('c:\path\to\workcopy\synchrob\trunk\mrcp_onset')
% addpath('c:\path\to\workcopy\synchrob\trunk')