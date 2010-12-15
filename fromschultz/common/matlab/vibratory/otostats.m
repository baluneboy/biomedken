function [otomean,otosigma,otomin,otomax,otomatrix,otostarts,otopam]=otostats(pth,start,stop)

% OTOSTATS - Function that loads desired 1/3 octave (oto*.mat) files
%            created by gsboto.m batch processing program and derives
%            statistics (mean, sigma, min, and max) on a freq. band-by-
%            freq. band basis.
%
% [otomean,otosigma,otomin,otomax,otomatrix,otostarts,otopam]=otostats(pth,start,stop);
%
% Inputs: pth - string for path to where oto*.mat input files are; for example
%         pth='/home/hrovat/programs/matlab/tempdir/onethird/iml2/headc'
%         start - vector for [day hour minute second] of start
%         stop - vector for [day hour minute second] of stop
%
% Outputs: otomean - vector of means (band-by-band)
%          otosigma - vector of sigmas (band-by-band)
%          otomin - vector of mins (band-by-band)
%          otomax - vector of maxs (band-by-band)
%          otomatrix - matrix of RMS accel. values (each column is a band)
%          otostarts - matrix of start times for each 100 second period analyzed
%          otopam - percentage of points above mean (band-by-band)        
%          FEATURES NOT ADDED YET, ONLY 7 OUTPUT ARGs FOR NOW  
%          panc - percentage of points above Naumann curve (band-by-band)

% written by: Ken Hrovat on 5/18/96
% $Id: otostats.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Ken Hrovat on 6/17/96

% Summary:
% 1. Get list of filenames matching pth
% 2. Pare list of files down to those that are in desired start/stop range:
% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row and otostarts
% 4. Calculate statistics on a column-by-column basis (band-by-band)
% 5. Calculate percentage of points above mean, if desired.


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

% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row and otostarts

otomatrix=[];
otostarts=[];
for f=1:size(filenames,1)

	eval(['load ' filenames(f,:)]);
	otomatrix=[otomatrix; rms_accel(:)'];
	sd=filenames(f,size(filenames,2)-12:size(filenames,2)-10);
	sh= filenames(f,size(filenames,2)-9:size(filenames,2)-8);
	sm= filenames(f,size(filenames,2)-7:size(filenames,2)-6);
	ss= filenames(f,size(filenames,2)-5:size(filenames,2)-4);
	eval(['sdhms=[' sd ' ' sh ' ' sm ' ' ss '];']);
	otostarts=[otostarts; sdhms];

end

% 4. Calculate statistics on a column-by-column basis (band-by-band)

otomean=mean(otomatrix);
otosigma=std(otomatrix);
otomin=min(otomatrix);
otomax=max(otomatrix);


% 5. Calculate percentage of points above mean, if desired

if nargout>6
	otopam=[];
	for i=1:size(otomatrix,2)
		col=otomatrix(:,i);
		ind=find(col>otomean(i));
		otopam=[otopam length(ind)/size(otomatrix,1)*100];
	end
end

