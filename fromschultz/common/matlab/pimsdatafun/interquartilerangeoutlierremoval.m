function y = interquartilerangeoutlierremoval(x,k)

% Let Q1 and Q3 be the lower and upper quartiles, respectively, then we declare an outlier to be any observation outside the range:
% [ Q1 - k*(Q3-Q1), Q3 + k*(Q3-Q1) ]
%
% EXAMPLE
% k = 3;
% y = interquartilerangeoutlierremoval(x,k);

Q1 = prctile(x,25);
Q3 = prctile(x,75);
LBOUND = Q1 - k*(Q3-Q1);
UBOUND = Q3 + k*(Q3-Q1);
iOut = find(x<LBOUND | x>UBOUND);
y = x;
y(iOut) = [];