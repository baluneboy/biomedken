function xls_join(strFileXLSA,strFileXLSB,numCommonCols,indColsToDelete,strFileOut)

% xls_join compare Excel files as strings; if same, then paste 2nd on 1st
%
% EXAMPLE:
% strFileXLSA = 'C:\cygwin\tmp\query_involved_shoulder_control_4688_db_top.xls';
% strFileXLSB = 'C:\cygwin\tmp\query_involved_shoulder_control_4688_db_bottom.xls';
% numCommonCols = 8;
% indColsToDelete = 2;
% strFileOut = 'C:\cygwin\tmp\trashC.xls';
% xls_join(strFileXLSA,strFileXLSB,numCommonCols,strFileOut);

% Undesirable results possibly if output file already exists, so abort
if exist(strFileOut,'file')
    error('daly:common:fileConflict','output file exists %s',strFileOut)
end

% Read data
[trash,foo,A] = xlsread(strFileXLSA);
[trash,foo,B] = xlsread(strFileXLSB);
casHeaderA = A(1,:);
casHeaderB = B(1,:);

% Get hybrid header row
[casNewCols,iDiff] = setdiff(casHeaderB,casHeaderA);
casHeader = cat(2,casHeaderA,casHeaderB(sort(iDiff)));

% Trim off original header rows
A(1,:) = [];
B(1,:) = [];

% Determine number of columns for padding
[rA,cA] = size(A);
[rB,cB] = size(B);
cAcB = [cA cB];
numColsToAdd = cAcB - numCommonCols;

% Make room for "beyond numCommonCols" in each
A = insertcols(A,cell(size(A(:,1:numColsToAdd(2)))),cA+1);
B = insertcols(B,cell(size(B(:,1:numColsToAdd(1)))),numCommonCols);

% Join rows (possibly excluding some header rows)
C = cat(1,casHeader,cat(1,A,B));

% Toss columns to delete
C(:,indColsToDelete) = [];

% Get diffs for post minus pre
inv_pre = cell2mat(C(2:end,6));
uninv_pre = cell2mat(C(2:end,7));
inv_post = cell2mat(C(2:end,8));
uninv_post = cell2mat(C(2:end,9));
[diffInv,diffUninv] = actvoxprepostdiff(inv_pre,uninv_pre,inv_post,uninv_post);

% Right paste these 2 new columns
C{1,nCols(C)+1} = 'inv_post-pre';
C{1,nCols(C)+1} = 'uninv_post-pre';
C(2:end,end-1:end) = deal({[diffInv diffUninv]);

% Write output file
xlswrite(strFileOut,C);
pause(2); % to allow for proper file closing (darn Winblows)
fprintf('\nWrote joined output file\n%s\n',strFileOut);
