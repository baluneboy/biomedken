function xls_paste(strFileXLSA,strFileXLSB,casColumnsComp,casBcolumnsToPaste,strFileOut)

% XLS_PASTE compare Excel files as strings; if same, then paste 2nd on 1st
%
% EXAMPLE:
% strFileXLSA = 'c:\temp\book1.xls';
% strFileXLSB = 'c:\temp\book3.xls';
% casColumnsComp = {'one','three','four','five'};
% casBcolumnsToPaste = {'two','this'};
% strFileOut = 'c:\temp\trashC.xls';
% xls_paste(strFileXLSA,strFileXLSB,casColumnsComp,casBcolumnsToPaste,strFileOut);

% Undesirable results possibly if output file already exists, so abort
if exist(strFileOut,'file')
    error('daly:common:fileConflict','output file exists %s',strFileOut)
end

% Check commonality in columns of concern
[blnSame,A,B,casLabelsA,casLabelsB] = xls_same(strFileXLSA,strFileXLSB,casColumnsComp);

if blnSame
    % Find columns in B of interest
    iKeep = ismember(casLabelsB(1,:),casBcolumnsToPaste);
    C = cat(2,A,B(:,iKeep));
    [pathstr,name,strExt,versn] = fileparts(strFileXLSA);
    xlswrite(strFileOut,C);
    pause(2); % to allow for proper file closing (darn Winblows)
    fprintf('\nWrote pasted output file\n%s\n',strFileOut);
else
    fprintf('\nNo columns of\n%s\nto paste on\n%s\n',strFileXLSA,strFileXLSB);
end