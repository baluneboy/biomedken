function checksyspath(casPatterns)
% CHECKSYSPATH quick check PATH (early) to avoid frustration later
%
% EXAMPLE
% casPatterns = {'spike5','neuroscan'};
% checksyspath(casPatterns)

p = getenv('PATH');
n = regexpi(p,casPatterns,'match');
ind = findemptycells(n);
if ~isempty(ind)
    error('daly:common:PATH','FAILED TO FIND THESE PATTERNS IN SYS PATH: %s',vec2str(casPatterns(ind)));
end
