function strOut = padzeros(strNum,numDigits)
% padzeros.m - pads strings containing digits with leading zeros
% 
% INPUTS
% strNum - string containing only numbers, like '12' or '012' 
% numDigits - double, total number of characters desired in strOut 
% 
% OUTPUTS
% strOut - string containing same digits as strNum but with prepending zeros
% 
% EXAMPLE
% str = '1';
% lenDesired = 3;
% strOut = padzeros(str,lenDesired)

lengthOld = length(strNum);
numZeros = numDigits - lengthOld;
strZeros = repmat('0',1,numZeros);
strOut = [strZeros strNum];