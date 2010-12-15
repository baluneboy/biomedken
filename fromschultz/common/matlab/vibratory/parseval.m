function grms=parseval(f,b,fc,franges);

% parseval - grms from Parseval's Theorem for PSD input(s) using
%            fancy indexing
%
%grms=parseval(f,b,fc,franges);
%
%Inputs: f - vector of frequencies for PSDs in b; length must match number of rows in b matrix
%        b - [multi-page] F-by-T matrix of PSDs (like from pimsspecgram)
%        fc - scalar for cutoff frequency
%        franges - B-by-2 matrix of non-overlapping, increasing frequency ranges to consider,
%                  like [f1 f2; f3 f4], so that the ranges here would be
%                  f1 <= f < f2  note how lower bounds are included, but
%                  f3 <= f < f4  upper bounds are excluded
%
%Output: grms - [multi-page] B-by-T matrix of grms values from Parseval's theorem

%Author: Ken Hrovat, 4/11/2001
%$Id: parseval.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Ken Hrovat on 5/19/2001 - incorporated findbands fancy indexing algorithm to improve performance

% Indices for rows in b matrix over which to integrate
indM=findbands(f,franges);  %[  band#   ind(f(1st4band))   ind(f(last4band)) ]

% Get rid of empty bands (rows with NaN in 2nd col)
inan=find(isnan(indM(:,2)));
if ~isempty(inan)
   inan=inan(:);
end
indM(inan,:)=[];

% Calculated collapse of input spectrogram, b, matrix of PSDs to sum
[numF,numT,numAx]=size(b);
numUsed=nRows(indM);
numBands=nRows(franges);
bsums=NaN*ones(numBands,numT,numAx);
for i=1:numUsed
   bandNumber=indM(i,1);
   ind=indM(i,2):indM(i,3); % rows of b matrix for this band
   if length(ind)==1
      bsums(bandNumber,:,:)=b(ind,:,:); % no sum for just one row
   else
      bsums(bandNumber,:,:)=sum(b(ind,:,:)); % sum of rows of b matrix for this band
   end
end

% Replace incomplete bands with NaN
if isempty(fc), fc=f(end); end
fupper=franges(:,2);
iOmit=find(fupper>fc);
if ~isempty(iOmit)
   bsums(iOmit,:,:)=NaN;
end

% Calculate RMS value from integration [sum] bands
deltaf=f(2)-f(1);
grms=sqrt(bsums*deltaf);

% Debug print info
%locDebugPrint(indM,inan,franges,f);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locDebugPrint(indM,inan,franges,f);

fprintf('\n              Empty Bands                   ')
fprintf('\n  Band #    from           to\n')
fprintf('     %02d   %8.4f       %8.4f\n',[inan franges(inan,1:2)]')
fprintf('\n-----------------------------------------------')

fprintf('\n              Integrated Bands                   ')
fprintf('\n  Band #\n')
fprintf('     %02d   %8.4f <= ( f(%d:%d)=[%.4f to %.4f) ) < %.4f\n',[indM(:,1) franges(indM(:,1),1) indM(:,2) indM(:,3) f(indM(:,2:3)) franges(indM(:,1),2)]')
fprintf('\n\n')