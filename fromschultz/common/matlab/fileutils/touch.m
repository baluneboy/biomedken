function touch(strDate,strFile)

% EXAMPLE
% strDate = '1984-04-30';
% strFile = 'C:\data\fmri\fromopticalmedia\temp4pre\s1374plas\13740000\dcm\68911178';
% touch(strDate,strFile)

%% Like this !c:\cygwin\bin\touch.exe -d "1984-04-30" C:\data\fmri\fromopticalmedia\temp4pre\s1374plas\13740000\dcm\68911178
strCmdTouch = ['c:\cygwin\bin\touch.exe -d "' strDate '" '];

%% Anonymize dicoms
[status,strResult] = system([strCmdTouch strFile]);
if max(size(strResult)) > 1
    fprintf('%s\n',strResult)
end