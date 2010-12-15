function str = numtoword(n)
% numtoword.m - converts digit to string containing actual word
% 
% INPUTS
% n - number
% 
% OUTPUTS
% str - string, word
% 
% EXAMPLE
% str = numtoword(1)
% 
% NOTES
% Not too useful yet unless you're looking for digits 0-9.

% Author - Krisanne Litinas
% $Id$

casDigits = {'one'; 'two'; 'three'; 'four'; 'five'; 'six'; 'seven'; 'eight'; 'nine'};
casTens = {'ten'; 'twenty'; 'thirty'; 'forty'; 'fifty'; 'sixty'; 'seventy'; 'eighty'; 'ninety'};


if n == 0
    str = 'zero';
end

if n < 10
    str = casDigits{n};
elseif n > 9 && n < 100;
    
end

