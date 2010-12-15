function [y,Q1,Q3,LB,nor] = interquartilerangeoutlierremovalofloweronly(x,k)

% Let Q1 and Q3 be the lower and upper quartiles, respectively, then we
% declare an outlier to be any observation below: Q1 - 3(Q3-Q1)
%
% EXAMPLE
% y = interquartilerangeoutlierremovalofloweronly(x,2.75);

Q1 = prctile(x,25);
Q3 = prctile(x,75);
LB = Q1 - k*(Q3-Q1);
iOut = find(x<LB);
y = x;
nor = length(iOut);
y(iOut) = [];