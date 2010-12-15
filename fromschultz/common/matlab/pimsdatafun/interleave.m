function col=interleave(c,d)

% INTERLEAVE interleave the 2 input vectors
% col=interleave(c,d);
%
% col=interleave([1 2 3],[11 22 33]);
% 
% Inputs: c,d - equal-length vectors to be interleaved
%
% Output: col - vector of interleaved values like this
%         col = [ c(1)
%                 d(1)
%                 c(2)
%                 d(2)
%                   :
%                 c(N)
%                 d(N) ];

% Author: Ken Hrovat
% $Id: interleave.m 4160 2009-12-11 19:10:14Z khrovat $

if length(c)~=length(d)
   error('input vectors must be same length')
end

% twoRows=[c(:)'; d(:)'];
% col=twoRows(:);

col=reshape([c(:)'; d(:)'],[],1);