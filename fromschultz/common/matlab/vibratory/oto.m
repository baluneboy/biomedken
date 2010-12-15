function [fiss,grms,deltaf,k,giss]=oto(x,fs,fc,strWindow,varargin);

% oto - Compute 1/3 octave band RMS acceleration levels
%
% [fiss,grms,deltaf,k,giss]=oto(x,fs,fc,strWindow);
% [fiss,grms,deltaf,k,giss]=oto(x,fs,fc,strWindow,mode); % mode: { '100sec' | 'pow2' }
% [fiss,grms,deltaf,k,giss]=oto(x,fs,fc,strWindow,'manual',Nfft);
% [fiss,grms,deltaf,k,giss]=oto(x,fs,fc,strWindow,'manual',Nfft,No);
%
%   Inputs: x is accel vector (for one axis)
%           fs is scalar for sampling rate;
%           fc is scalar corresponding to lowpass filter cutoff frequency
%           strWindow - string for window function ('hanning' if empty)
%           mode - string for OTO Nfft mode '100sec', 'pow2', 'manual'
%           Nfft - scalar for number of points to calculate PSD
%           No - scalar for number of overlap points in PSD
%
%   Outputs: fiss - vector of OTO frequency band edges (use stairs output for loglog)
%            grms - vector of RMS accelerations for OTO freq. bands
%            deltaf - scalar frequency resolution (Hz)
%            k - scalar number of spectral average sections
%            giss - vector of RMS accelerations for ISS requirements
%
% ASSUMPTION: x represents the [100 second] time record of interest
%             if mode equals 'pow2', then slice pow2 points so that T>=100
%             if mode equals '100sec' or is empty, then choose T just over 100 seconds
%             if mode equals 'manual', then don't care what T is
%
% NOTE: if the lowpass filter cutoff frequency is not 362.04 Hz or greater,
%       then an incomplete profile relative to the space station system
%       combined vibratory acceleration limits is returned
%
% see otoissreq.m for lookup table

% written by:  Ken Hrovat on 6/23/95
% $Id: oto.m 4160 2009-12-11 19:10:14Z khrovat $

% SYNOPSIS:
% Check number of input/output arguments
% Verify number of samples in x for mode
% Compute PSD (use psdpims)
% Compute gRMS levels in OTO bands from PSD

% Check number of input/output arguments
switch nargin
case 4
   mode='100sec';
case 5
   mode=varargin{1};
   if strcmp(mode,'manual')
      error('oto manual mode requires Nfft input')
   end
case 6
   [mode,Nfft]=deal(varargin{:});
case 7
   [mode,Nfft,No]=deal(varargin{:});
otherwise
   error('wrong nargin')
end %switch nargin
if isempty(mode), mode='100sec'; end

% Verify number of samples in x for mode
switch mode
case '100sec'
   Nfft=ceil(fs*100);
case 'pow2'
   Nfft=clogtwo(fs*100);
case 'manual'
   % Nfft should have been an input
otherwise
   error(sprintf('unexpected oto mode: %s',mode))
end % switch mode

if exist('No')~=1
   No=Nfft/2;
end

if length(x)<Nfft
   error(sprintf('skip this period because for oto mode: %s, number of pts, %d, is less than needed, %d',mode,length(x),Nfft))
   %[fiss,grms,deltaf,k,giss]=deal(NaN);
   %return
end

% Compute PSD (use psdpims)
deltaf=fs/Nfft;
if isempty(strWindow)
   strWindow='hanning';
end
eval(['window=' strWindow '(' num2str(Nfft) ');']);
[pxx,f,k]=psdpims(x,Nfft,fs,window,No);

% Compute gRMS levels in OTO bands from PSD
[fcent,grms,fiss,giss]=otofrompsd(f,pxx,fc);
if nargout==6
   varargout{1}=fiss; % these outputs: fiss &
   varargout{2}=giss; % giss are stairstepped vectors
end

% Condition vectors for stairsteps
grms=repmat(grms(:)',2,1);
grms=grms(:);

%fprintf('\nOTO mode: %s',mode)
%fprintf('\npsdpims: Nfft = %d, fs = %.2f Hz, %s window, No = %d',Nfft,fs,strWindow,No)
%fprintf('\ndeltaf = %g Hz, k = %d',deltaf,k)
%fprintf('\nfc = %.2f Hz so highest band used was [%g %g %g]\n',fc,moto(maxband,1:3))
