function y3 = lesserabs(y1,y2)

% LESSERABS do not use this function i am guessing based on comments
%
% EXAMPLE
% x = 1:10;
% y1 = [ 1 2 3 2 1 -8 -8 -8 -8 -8 ];
% y2 = [ 0 1 4 4 5 -8 -7 -9 -9 -9 ];
% y3 = lesserabs(y1,y2);
% plot(x,y1,'r',x,y2,'g',x,y3,'b')
% hold on
% stem(x,y3)

% clumsily, quickly, brutely...
% author: Hrovat

% verify sizes
if all(size(y1)==size(y2))
    if min(size(y1)) ~= 1
        error('need vector inputs')
    end
else
    error('mismatch input arg sizes')
end

% cat magnitude
y12 = [ y1(:)'; y2(:)' ];
a = abs(y12);

% min(abs)
[LA,rowA] = min(a);

% for each column
colA = 1:length(rowA);

% lesser of the magnitudes with signage
y3 = diag(y12(rowA,colA));