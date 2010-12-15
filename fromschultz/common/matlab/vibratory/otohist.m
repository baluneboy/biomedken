function [otohist,otomean,bincen,otomatrix]=otohist(pth,start,stop,arg2)

% OTOHIST -  Function that loads desired 1/3 octave (oto*.mat) files
%            created by gsboto.m batch processing program and computes
%            histogram(s) for the desired bins.
%
%[otohist,otomean,bincen,otomatrix]=otohist(pth,start,stop,arg2);
%
% Inputs: pth - string for path to where oto*.mat input files are; for example
%         pth='/home/hrovat/programs/matlab/tempdir/onethird/iml2/headc'
%         start - vector for [day hour minute second] of start
%         stop - vector for [day hour minute second] of stop
%         arg2 - SEE HIST HELP FOR 2nd ARGUMENT DESCRIPTION
%
% Outputs: otohist - matrix of histogram(s); column-by-column (band-by-band)
%          otomean - vector of means (band-by-band)
%          bincen - bin centers (SEE HIST HELP FOR X OUTPUT DESCRIPTION)
%          otomatrix - matrix of RMS accel. values; column-by-column (band-by-band)
          
% written by: Ken Hrovat on 2/3/98
% $Id: otohist.m 4160 2009-12-11 19:10:14Z khrovat $

% Summary:
% 1. Get list of filenames matching pth
% 2. Pare list of files down to those that are in desired start/stop range
% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row
% 4. Calculate histogram(s) on a column-by-column basis (band-by-band)


% 1. Get list of filenames matching pth

if ( pth(end)~='/' )
	pth=[pth '/'];
end
filenames=filelist([pth 'oto*.mat']);

% 2. Pare list of files down to those that are in desired start/stop range:
 
startnum=str2num(sprintf('%d%02d%02d%02d',start(1),start(2),start(3),start(4)));
stopnum=str2num(sprintf('%d%02d%02d%02d',stop(1),stop(2),stop(3),stop(4)));

fnums=[];
for r=1:size(filenames,1)
	fn=filenames(r,size(filenames,2)-12:size(filenames,2)-4);
	fnums=[fnums; str2num(fn)];
end

ind=find(fnums>=startnum & fnums<=stopnum);
filenames=filenames(ind,:);

% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row

otomatrix=[];
for f=1:size(filenames,1)

	eval(['load ' filenames(f,:)]);
	otomatrix=[otomatrix; rms_accel(:)'];

end

% 4. Calculate histogram(s) on a column-by-column basis (band-by-band)

otomean=mean(otomatrix);
otohist=[];
bincen=[];
for c=1:nCols(otomatrix)
	y=otomatrix(:,c);
	[n,x]=hist(y,arg2);
	otohist=[otohist n(:)];
	bincen=[bincen x(:)];
end
	
	

