function rmsavst(t,x,y,z,ancillary,frange2log,typstr)

% rmsavst - RMS acceleration batch function which will generate RMS accel. vs. t
%            output files for each freq. range to log.  This function should 
%            be used before rmsacbat.m to gather some useful statistics for 
%            use by that function. 
%
% rmsavst(t,x,y,z,ancillary,frange2log,typstr);
%
% Inputs:         t - vector of times
%             x,y,z - component acceleration vectors
%         ancillary - info for unique filename generation     
%        frange2log - matrix of frequency ranges to log, like so
%                     frange2log=[flo1 fhi1;
%                                 flo2 fhi2;
%                                   :    : ;
%                                 flon fhin]
%            typstr - typstr for desired outputs; possibilities are:
%                     x,y,z,v, or any combination of these
% Implicit Outputs: RMS accel. vs. t files for user-specified freq. ranges
%
% NOTE: BEFORE ANY BATCH PROCESSING IS DONE WITH THIS FUNCTION, ANY .mat FILES
%       IN THE DIRECTORY POINTED TO BY anchfile FUNCTION THAT YOU DO NOT WANT TO
%       OVERWRITE, SHOULD BE MOVED

% 1. Verify data for this period.
% 2. Initialize output files (if non-existent)
% 3. Calculate RSS of PSDs
% For each frequency range to log
%   4. Use cumrms function on RSS of PSDs
%   5. Update output file according to results in step 4

% written by: Ken Hrovat on 2/16/95
% $Id: rmsavst.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Ken Hrovat on 4/5/96
% modified by: Ken Hrovat on 6/27/96


% 1. Verify data for this period.

if ( length(t)<2 )
	return;
end

if ( isempty(frange2log) )
	load(anchfile('frange2logfile'))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2. Initialize output files (if non-existent):        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fs=1/(t(2)-t(1));
fc=fs/5;
if ( hasstr(lower(ancillary),'usmp4gb') )
	fc=100;
elseif ( hasstr(lower(ancillary),'usmp4ga') )
	fc=5;
end

flagname=anchfile(['rat' ancillary '.mat']);
if ( ~exist(flagname) )
	disp([flagname ' did not exist, so initializing output files'])
	starttime=clock;
	eval(['save ' flagname ' starttime']);
	for count=1:size(frange2log,1)
		f1str = replastr(sprintf('%.2f',frange2log(count,1)),'.','p');
		f2str = replastr(sprintf('%.2f',frange2log(count,2)),'.','p');
		fstr = ['rat' ancillary f1str 't' f2str];
		at=[];
		if ( hasstr(typstr,'v') )
			armsv=[];
			logname = [anchfile('') fstr 'v.mat'];
			eval(['save ' logname ' at armsv']);
			disp('Initialized V file')
		end
		if ( hasstr(typstr,'x') )
			armsx=[];
			logname = [anchfile('') fstr 'x.mat'];
			eval(['save ' logname ' at armsx']);
			disp('Initialized X file')
		end
		if ( hasstr(typstr,'y') )
			armsy=[];
			logname = [anchfile('') fstr 'y.mat'];
			eval(['save ' logname ' at armsy']);
			disp('Initialized Y file')
		end
		if ( hasstr(typstr,'z') )
			armsz=[];
			logname = [anchfile('') fstr 'z.mat'];
			eval(['save ' logname ' at armsz']);
			disp('Initialized Z file')
		end
	end
	disp(sprintf('sampling rate is %.1f, so using cutoff of %.1f',fs,fc))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  3. Calculate PSDs:                     %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( (length(x)~=length(y)) | (length(y)~=length(z)) )
	error('rmsavst: LENGTH OF XYZ INPUT VECTORS NOT THE SAME')
end

n=floor(log2(length(x)));
nfft=2^n;

fs=1/(t(2)-t(1));
tempstr=typstr;
if ( hasstr(typstr,'v') )
	typstr='xyzv';
end
if ( hasstr(typstr,'x') )
	[pxx,f]=psdpims(x,nfft,fs,boxcar(nfft),0);
end
if ( hasstr(typstr,'y') )
	[pyy,f]=psdpims(y,nfft,fs,boxcar(nfft),0);
end
if ( hasstr(typstr,'z') )
	[pzz,f]=psdpims(z,nfft,fs,boxcar(nfft),0);
end
typstr=tempstr;


for fnum=1:size(frange2log,1)


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% 4. Use cumrms function on PSDs and update output files   %%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	f1str = replastr(sprintf('%.2f',frange2log(fnum,1)),'.','p');
	f2str = replastr(sprintf('%.2f',frange2log(fnum,2)),'.','p');
	fstr = ['rat' ancillary f1str 't' f2str];
	meant=mean(t);
	if ( hasstr(typstr,'x') )
		[cfx,crmsx] = cumrms(f,pxx,fc,frange2log(fnum,:),'table');
		logname = [anchfile('') fstr 'x.mat'];
		eval(['load ' logname]);
		at=[at meant];
		armsx=[armsx crmsx];
		eval(['save ' logname ' at armsx']);
	end
	if ( hasstr(typstr,'y') )
		[cfy,crmsy] = cumrms(f,pyy,fc,frange2log(fnum,:),'table');
		logname = [anchfile('') fstr 'y.mat'];
		eval(['load ' logname]);
		at=[at meant];
		armsy=[armsy crmsy];
		eval(['save ' logname ' at armsy']);
	end
	if ( hasstr(typstr,'z') )
		[cfz,crmsz] = cumrms(f,pzz,fc,frange2log(fnum,:),'table');
		logname = [anchfile('') fstr 'z.mat'];
		eval(['load ' logname]);
		at=[at meant];
		armsz=[armsz crmsz];
		eval(['save ' logname ' at armsz']);
	end

	if ( hasstr(typstr,'v') )
		crmsv=pimsrss(crmsx,crmsy,crmsz);
		logname = [anchfile('') fstr 'v.mat'];
		eval(['load ' logname]);
		at=[at meant];
		armsv=[armsv crmsv];
		eval(['save ' logname ' at armsv']);
	end
end

