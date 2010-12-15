function [blnSame,A,B,casLabelsA,casLabelsB] = xls_same(strFileXLSA,strFileXLSB,casColumns)

% XLS_SAME read Excel files in string form and compare
%
% EXAMPLE:
% strFileXLSA = 'c:\temp\book1.xls';
% strFileXLSB = 'c:\temp\book2.xls';
% casColumns = {'one','three','four','five'};
% [blnSame,A,B,casLabelsA,casLabelsB] = xls_same(strFileXLSA,strFileXLSB,casColumns)

% There has to be at least one interesting column
if numel(casColumns) < 1
    error('daly:common:badInput','need at least 1 column label of interest')
end

% Read XLS files & toss uninteresting columns, then convert to big strings
[strA,casLabelsA,A] = locString(strFileXLSA,casColumns);
[strB,casLabelsB,B] = locString(strFileXLSB,casColumns);

% Compare files in string form
blnSame = strcmp(strA,strB);

%----------------------------------------------------
function [strA,casLabelsA,A] = locString(strFileXLSA,casColumns)
[trash,casLabelsA,A] = xlsread(strFileXLSA);
iKeep = ismember(casLabelsA(1,:),casColumns);
strA = vec2str(A(:,iKeep));