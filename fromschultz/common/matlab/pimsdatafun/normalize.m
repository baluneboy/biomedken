function y = normalize(x)
% NORMALIZE normalize
if ~isvector(x)
    error('this code only intended to work on vector inputs (for now)')
end
x = x - min(x(:));
y = x / max(x(:));