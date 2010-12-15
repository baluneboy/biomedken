function xlsinsertcolumn(strFileXLS,numCol,c)
% EXAMPLE
% strFileXLS = 'c:\temp\trash.xls';
% xlsinsertcolumn(strFileXLS,2,{'dos',22,44});

[foo,foo,R] = xlsread(strFileXLS); %#ok<ASGLU>
Rnew = cell(size(R,1),size(R,2)+1);
for i = 1:numCol-1
   Rnew(:,i) = R(:,i); 
end
Rnew(:,numCol) = c;
for i = numCol+1:size(Rnew,2)
   Rnew(:,i) = R(:,i-1); 
end
[s,m] = xlswrite(strFileXLS,Rnew);