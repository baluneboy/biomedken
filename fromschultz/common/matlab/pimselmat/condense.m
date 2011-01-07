function out = condense(in)

% in is Nx2 matrix
% out is is Mx2 "condensed" matrix (if any overlap exists M<N); otherwise out = in;
%
% NOTE: this assumes monotonically increasing first column and each row of
% input has column 2 entry greater than or equal to column 1 entry

% dbstack, size(in), pause(1)

%% Initialize output
out = in;

%% Check for any (rows) range overlaps
if ~anyrangeoverlap(out)
    return
end

%% Condense top 2 rows (if needed)
out = condensetworows(out,1);
out = condensetworows(out,2);

%% Return top row & recursion on rows 2:end
out = [out(1,:); condense(out(2:end,:))];