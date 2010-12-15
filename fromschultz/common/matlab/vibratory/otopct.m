function [otomean,otosigma,otomin,otomax,otomatrix,otostarts]=otopct(subdir,start,stop)

% OTOPCT - Function that loads desired 1/3 octave (oto*.mat) files
%            created by gsboto.m batch processing program and derives
% 6. Calculate percentage of points above Naumann curve
% 7. Caclulate percentage of points above mean
%
% [otomean,otosigma,otomin,otomax,otomatrix,otostarts,panc,pam]=otopct(subdir,start,stop);
%
% Inputs: subdir - string for subdirectory where oto*.mat input files are
%                  under directory pointed to by bulkanchfile('onethird/'), for
%                  example, subdir = 'mir2/heada'
%         start - vector for [day hour minute second] of start
%         stop - vector for [day hour minute second] of stop
%
% Outputs: otomean - vector of means (band-by-band)
%          otosigma - vector of sigmas (band-by-band)
%          otomin - vector of mins (band-by-band)
%          otomax - vector of maxs (band-by-band)
%          otomatrix - matrix of RMS accel. values (each column is a band)
%          otostarts - matrix of start times for each 100 second period analyzed  
%          panc - percentage of points above Naumann curve (band-by-band)
%          pam - percentage of points above mean (band-by-band)        

% written by: Ken Hrovat on 5/18/96
% $Id: otopct.m 4160 2009-12-11 19:10:14Z khrovat $

% Summary:
% 1. Get list of filenames matching subdir
% 2. Pare list of files down to those that are in desired start/stop range:
% 3. Load oto*.mat files one-by-one and build otomatrix row-by-row and otostarts
% 4. Calculate statistics on a column-by-column basis (band-by-band)
% 5. Data for Naumann curve
% 6. Calculate percentage of points above Naumann curve
% 7. Caclulate percentage of points above mean


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

% 4. Calculate statistics on a column-by-column basis (band-by-band)

otomean=mean(otomatrix);
otosigma=std(otomatrix);
otomin=min(otomatrix);
otomax=max(otomatrix);


% 5. Data for Naumann curve

bands = [ 0.0891  0.10    0.1122;
          0.1122  0.125   0.1413;
          0.1413  0.16    0.1778;
          0.1778  0.20    0.2239;
          0.2239  0.25    0.2818;
          0.2818  0.315   0.3548;
          0.3548  0.40    0.4467;
          0.4467  0.50    0.5623;
          0.5623  0.63    0.7079;
          0.7079  0.80    0.8913;
          0.8913  1.00    1.1220;
          1.1220  1.25    1.4130;
          1.4130  1.6     1.7780;
          1.7780  2.00    2.2390;
          2.2390  2.5     2.8180;
          2.8180  3.15    3.5480;
          3.5480  4.0     4.4670;
          4.4670  5.0     5.6230;
          5.6230  6.3     7.0790;
          7.0790  8.0     8.9130;
          8.9130  10.0    11.220;
          11.220  12.5    14.130;
          14.130  16.0    17.780;
          17.780  20.0    22.390;
          22.390  25.0    28.180;
          28.180  31.5    35.480;
          35.480  40.0    44.670;
          44.670  50.0    56.230;         % this is last row of table they list
          56.230  64.0    71.838;         % so this row down was computed and 
          71.838  80.635  90.510];

issx=bands(:,2);
issy=reqx*16e-6;

% 6. Calculate percentage of points above Naumann curve
% 7. Caclulate percentage of points above mean

