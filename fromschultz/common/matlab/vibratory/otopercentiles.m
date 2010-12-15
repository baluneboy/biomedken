function [otopctile,otomatrix,otostarts]=otopercentiles(p,subdir,start,stop)

% OTOPERCENTILES - Function that loads desired 1/3 octave (oto*.mat) files
%                  created by gsboto.m batch processing program and returns
%                  a value that is greater than p percent of the values in each
%                  oto band (column) of the otomatrix built from desired oto files.
%                  For example, if p = 50  otopctile gives the median of each band. 
%                  p may be either a scalar or a vector:
%                   - For scalar p, otopctile is a row vector containing the pth
%                     percentile of each oto band (column) from the desired oto files.
%                   - For vector p, the ith row of otopctile is the p(i) percentile of
%                     each oto band (column) from the desired oto files.
%
% [otopctile,otomatrix,otostarts]=otopercentiles(p,subdir,start,stop);
%
% Inputs:      p - percentile values to calculate
%         subdir - string for subdirectory where oto*.mat input files are
%                  under directory pointed to by bulkanchfile('onethird/'), for
%                  example, subdir = 'mir2/heada'
%          start - vector for [day hour minute second] of start
%           stop - vector for [day hour minute second] of stop
%
% Outputs: otopctile - matrix of p percentiles column-by-column (band-by-band)
%          otomatrix - matrix of RMS accel. values (each column is a band)
%          otostarts - matrix of start times for each 100 second period analyzed  

% written by: Ken Hrovat on 3/9/99
% $Id: otopercentiles.m 4160 2009-12-11 19:10:14Z khrovat $

% Summary:
% 1. Get list of filenames matching subdir
% 2. Pare list of files down to those that are in desired start/stop range:
% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row and otostarts
% 4. Calculate percentiles on a column-by-column basis (band-by-band)


% 1. Get list of filenames matching subdir

filenames=filelist(bulkanchfile(['onethird/' subdir]));

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

	eval(['load ' bulkanchfile(['onethird/' subdir '/' filenames(f,:)])]);
	otomatrix=[otomatrix; rms_accel(:)'];
	sd=filenames(f,size(filenames,2)-12:size(filenames,2)-10);
	sh= filenames(f,size(filenames,2)-9:size(filenames,2)-8);
	sm= filenames(f,size(filenames,2)-7:size(filenames,2)-6);
	ss= filenames(f,size(filenames,2)-5:size(filenames,2)-4);
	eval(['sdhms=[' sd ' ' sh ' ' sm ' ' ss '];']);
	otostarts=[otostarts; sdhms];

end

% 4. Calculate percentiles on a column-by-column basis (band-by-band)

otopctile=percentile(otomatrix,p);

