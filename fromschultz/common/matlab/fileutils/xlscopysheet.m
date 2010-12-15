function blnSuccess = xlscopysheet(strSheetFrom,strFileFrom,strSheetTo,strFileTo)

% EXAMPLE
% strSheetFrom = 'dc3';
% strFileFrom = 'c:\temp\AMAT-s1604hand.xls';
% strSheetTo = 'dc1';
% strFileTo = 'c:\temp\trash\AMAT-s1806bcis.xls';
% blnSuccess = xlscopysheet(strSheetFrom,strFileFrom,strSheetTo,strFileTo);

[numeric,txt,raw] = xlsread(strFileFrom,strSheetFrom);
blnSuccess = xlswrite(strFileTo,raw,strSheetTo);