function out = normrows(m)

% Use arrayfun to return the 2-norm ("vector length") of each row
%
% EXAMPLE
% m = [magic(3); 10*magic(3); nan 2 inf]
% out = normrows(m)

out = arrayfun(@(idx) norm(m(idx,:)), 1:size(m,1))';