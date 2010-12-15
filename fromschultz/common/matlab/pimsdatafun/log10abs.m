function [ L ] = log10abs( m )
% LOG10X -- Performs logarithm base 10 on a matrix with negative values
% (log of absolute and replace sign)

iZero = m==0;
s = sign(m);
L = log10(abs(m));
L(iZero) = 0;
L = s.*L;

end

