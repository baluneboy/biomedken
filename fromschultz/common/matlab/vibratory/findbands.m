function ind=findbands(f,franges);

%findbands - use fancy indexing to find indexes into f bounded by
%             each band (row) of franges
%
%ind=findbands(f,franges);
%
%Inputs: f - vector of monotonically increasing values
%        franges - Bx2 matrix of non-overlapping, increasing ranges to consider,
%                  like [f1 f2; f3 f4], so that the ranges here would be
%                  f1 <= f < f2  note how lower bounds are included, but
%                  f3 <= f < f4  upper bounds are excluded, so f2 could be same as f3
%
%Output: ind - Bx3 matrix of indexes into f vector that demark begin/end inclusion in franges,
%              that is, row k of output, ind, gives [k iBeginning iEnding]; where 2nd and 3rd
%              columns give indices of f for band #k

%Author: Ken Hrovat, 5/15/2001
%$Id: findbands.m 4160 2009-12-11 19:10:14Z khrovat $

% Reshape freq. ranges for convenience
numBands=nRows(franges);
franges=franges';

% Check monotonicity (increasing f & non-overlapping, increasing franges)
blnNotMono=any(find(diff(f)<=0)); % 1 if not monotonically increasing f
if blnNotMono
   error('input vector is not monotonically increasing')
end
fdiff=diff(franges(:));
blnBadRanges=any(find(fdiff<0)); % 1 if franges overlap or are not in increasing order
if blnBadRanges
   error('input franges overlap or are not in increasing order')
end

% Build special stack: franges on top of f (special indexing in 1st column)
negInd=(-1*transpose(1:2*numBands)-1)/2;
specialStack=[negInd franges(:); transpose(1:length(f)) f(:)];

% Sort rows of special stack based on 2nd column (of values) ascending
[sortedStack,iSorted]=sortrows(specialStack,2);

% Find contiguous runs of positive values in 1st column of sorted (special) stack
indCol=sortedStack(:,1);
iPos=find(indCol>0);
[starts,durations]=contig(indCol,iPos);

% Keep only positive starts
begins=starts-1;
iPosBegins=find(begins>0);
begins=begins(iPosBegins);
durations=durations(iPosBegins);
ends=begins+durations-1;

% Untreated band number vector
rawBand=-indCol(begins);

% Get only integer band numbers (non-integers are placeholders)
indBand=find(rawBand==fix(rawBand));

% Construct blank index matrix
ind=NaN*ones(numBands,3);

% Fill in using nested indexes
ind(:,1)=(1:numBands)';
ind(rawBand(indBand),2:3)=[indCol(begins(indBand)+1) indCol(ends(indBand)+1)];