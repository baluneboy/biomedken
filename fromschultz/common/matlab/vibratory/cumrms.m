function [cumulativef,cumulativeRMS]=cumrms(f,pxx,fc,franges,typestr);

% CUMRMS - Function to compute the cumulative RMS vs. frequency
%          for the indicated frequency ranges.
%
% [cumulativef,cumulativeRMS] = cumrms(f,pxx,fc,franges,typestr);
%
% Inputs: f - vector of frequencies for pxx (OUT TO NYQUIST)
%         pxx - pxx vector (OUT TO NYQUIST)
%         fc - scalar cutoff frequency in Hz
%         franges - 2 column matrix of frequency ranges as follows:
%
%         franges = [ minf1 maxf1;
%                     minf2 maxf2;
%                       :     :
%                     minfn maxfn ]; where n is # of ranges
%
%         typestr - string that is either 'table' or 'sections'; table
%                   for tabular output, sections for plot-type output
%
% Outputs: cumulativef - vector of frequencies corresponding to cum. RMS values
%          cumulativeRMS - vector of cumulative RMS values

% written by: Ken Hrovat on 9/26/95
% $Id: cumrms.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Ken Hrovat on 2/18/97
% modified by: Ken Hrovat on 5/19/2001 - incorporated findbands fancy indexing algorithm to improve performance

% Case for empty input freq ranges
if isempty(franges)
   franges=[0 max(f)];
end

% Error check inputs:
if ~( nargout==2 & nargin==5 )
   help cumrms
   error('CUMRMS REQUIRES 5 INPUT ARGs AND 2 OUTPUT ARGs')
end

% Error check frequency range
fmin=min(franges(:,1));
fmax=max(franges(:,2));
flow=min(f);
fhigh=max(f);
if (fmin<flow | fmax>fhigh)
   error('CUMRMS: ALL ROWS OF franges MUST BE COVERED BY INPUT FREQUENCY VECTOR')
end

deltaf=f(2)-f(1);

% Issue warning if we're using attenuated region of spectrum
if ( max(franges(:)) > fc )
   warning(sprintf('from cumrms: max(franges) > fc'))
end

% Compute RMS levels
if ( strcmp(typestr,'sections') )
   numRanges=size(franges,1);
   cumulativef=[];
   cumulativeRMS=[];
   for bin=1:numRanges
      ind=find(f>=franges(bin,1) & f<franges(bin,2));
      ind=ind(:);
      if ( length(ind)<=1 )
         warning(sprintf('\nfrom cumrms: NUMBER OF POINTS USED FOR FREQ RANGE #%d IS %d\n\n',bin,length(ind)))
      end
      subf=f(ind);
      subpxx=pxx(ind);
      cumulativef=[cumulativef; subf];
      cumulativeRMS=[cumulativeRMS; sqrt(cumsum(subpxx)*deltaf)];
   end
elseif ( strcmp(typestr,'table') ) 
   numRanges=size(franges,1);
   cumulativeRMS=zeros(numRanges,1);
   for bin=1:numRanges
      ind=find(f>=franges(bin,1) & f<franges(bin,2));
      ind=ind(:);
      if ( length(ind)<=1 )
         warning(sprintf('\nfrom cumrms: NUMBER OF POINTS USED FOR FREQ RANGE #%d IS %d\n\n',bin,length(ind)))
      end
      subf=f(ind);
      subpxx=pxx(ind);
      cumulativef=franges;
      cumulativeRMS(bin)=sqrt(sum(subpxx)*deltaf);
   end
else
   help cumrms
   error('CUMRMS: typestr MUST BE EITHER ''table'' or ''sections''')
end