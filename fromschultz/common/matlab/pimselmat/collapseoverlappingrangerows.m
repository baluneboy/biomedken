function out = collapseoverlappingrangerows(in)

% in is Nx2 matrix
% out is is Mx2 "condensed" matrix (if any overlap exists M<N); otherwise out = in;
%
% NOTE: this assumes monotonically increasing first column and each row of
% input has column 2 entry greater than or equal to column 1 entry

%% Initialize output
out = in;

%% Check if anything needs to be done
[blnOverlap,indOverlap] = anyrangeoverlap(out);

%% Check for any (rows) range overlaps, collapse as needed
if ~blnOverlap, return, end

%% Collapse overlapping rows
out = combinetheserows(out,indOverlap);

%% Recursively collapse rows as needed
out = collapseoverlappingrangerows(out);