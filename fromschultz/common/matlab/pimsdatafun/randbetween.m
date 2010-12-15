function r = randbetween(a,b,n)
% Generate uniform values from the interval [a, b] the size of n (or n # values).
% r = randbetween(27,29,magic(2))
if isscalar(n) && isnumeric(n)
    r = a + (b-a).*rand(n,1);
elseif isnumeric(n)
    r = a + (b-a).*rand(size(n));
else
   error('daly:pimsdatafun:unexpectedInputType','expected input for "n" to be scalar or numeric') 
end
