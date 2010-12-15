function grms=rvtfromspecgram(f,b,fc,franges);

% rvtfromspecgram - compute RMS acceleration for bands from PSD or b matrix of PSDs (fancy indexing)
%
%grms=rvtfromspecgram(f,b,fc,franges);
%
% Inputs: f - vector of frequencies for PSD matrix, b (evenly spaced at deltaf)
%         b - F-by-T-by-numAx matrix of PSD values (like that for a spectrogram)
%         fc - scalar cutoff frequency (if not empty, then put NaN for f > fc)
%         franges - 2-column matrix of franges [f1 f2; f3 f4;...]
%
%Outputs: grms - B-by-T-by-numAx matrix of RMS values for frequency ranges of input

%Author: Ken Hrovat, 4/11/2001
%$Id: rvtfromspecgram.m 4160 2009-12-11 19:10:14Z khrovat $

% Gather some info
deltaf=f(2)-f(1);

% Need these frequency values
fupper=franges(:,2); % 2nd column is upper limits
ftemp=[franges(:,1) mean(franges,2) franges(:,2)];

load trashbft
franges=[0 0.5; 0.5 1];

% Verify that franges do not overlap
blnOverlap=0;
if blnOverlap
   error('franges cannot overlap')
end


numBands=nRows(franges);
ff=[f(:) f(:)];
frTrans=franges';
ffranges=[frTrans(:) frTrans(:)];
freqStack=[ffranges; ff];
[fSorted,iSorted]=sortrows(freqStack);
i2=iSorted-(2*numBands);
i5=(iSorted+1)/2;

%[i5 i2]

% Delete any rows of i2 and i5 before i2==1 row
i21=find(i2==1);
if ( ~isempty(i21) & i2(1)> 0 )
   i2(1:i21)=[];
   i5(1:i21)=[];
   istep=2;
else
   istep=1;
end

% Delete any rows of i2 and i5 after i2==0
i20=find(i2==0);
if ( ~isempty(i20) & i20<length(i2) )
   i2(i20+1:end)=[];
   i5(i20+1:end)=[];
end

% Delete any rows of i2 and i5 after i2==length(f)
i22=find(i2==length(f));
if ( ~isempty(i22) & i22<length(i2) )
   i2(i22+1:end)=[];
   i5(i22+1:end)=[];
end

%[i5 i2]

% Find contiguous runs of positive values
ind=find(i2>0);
[starts,durations]=contig(i2,ind);

%[starts durations]

% Keep just odd ones
starts=starts(1:istep:end);
durations=durations(1:istep:end);

%[starts durations]

% Indices for rows in b matrix over which to integrate
indM=[i5(starts-1) i2(starts) i2(starts+durations-1)];

for r=1:nRows(indM)
   [franges(indM(r,1),:) f(indM(r,2):indM(r,3))]
end


% Collapse input spectrogram, b, matrix of PSDs to sum
bsums=NaN*ones(numBands,nCols(b),size(b,3));
numBandsUsed=nRows(indM);
for i=1:numBandsUsed
   bandNumber=indM(i,1);
   ind=indM(i,2):indM(i,3); % rows of b matrix for this band
   if length(ind)==1
      bsums(bandNumber,:,:)=b(ind,:,:); % no sum for just one row
   else
      bsums(bandNumber,:,:)=sum(b(ind,:,:)); % sum of rows of b matrix for this band
   end
end

% Replace incomplete bands with NaN
if isempty(fc)
   fc=f(end);
end
iOmit=find(fupper>fc);
if ~isempty(iOmit)
   bsums(iOmit,:)=NaN;
end

% Calculate RMS value from integration [sum] bands
grms=sqrt(bsums*deltaf);

% Debug print info
%locDebugPrint(numBandsUsed,indM,myOTO,f,b);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locDebugPrint(numBandsUsed,indM,myOTO,f,b);
fprintf('\n   OTO Band #      LB         f1         fend       UB')
for i=1:numBandsUsed
   bandNumber=indM(i,1);
   ind=indM(i,2):indM(i,3); % rows of b matrix for this band
   oto12=myOTO(bandNumber,[1 3]);
   fvalue=f(indM(i,2):indM(i,3));
   fprintf('\n           %2d: %7.3f <= %7.3f ... %7.3f < %7.3f',bandNumber,oto12(1),fvalue(1),fvalue(end),oto12(2))
end
indM
fprintf('\n\n          ------ b ------')
fprintf('\n   f      1      2      3') 
fprintf('\n%6.2f %6.2e %6.2e %6.2e',[f(1:5,:) b(1:5,1:3)]')
fprintf('\n\n________________________________')