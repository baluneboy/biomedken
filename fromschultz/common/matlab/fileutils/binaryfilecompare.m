function blnSame = binaryfilecompare(fname1,fname2)
% EXAMPLE
% fname1 = 'c:\temp\trash1';
% fname2 = 'c:\temp\trash2';
%  blnSame = binaryfilecompare(fname1,fname2)

% See if files exist
if ~exist(fname1, 'file')
    error('daly:fileutils:filenotexist','"%s" does not exist',fname1);
end
if ~exist(fname2, 'file')
    error('daly:fileutils:filenotexist','"%s" does not exist',fname2);
end

if ~isunix
    
    % Compare
    c = com.mathworks.mde.difftool.BinaryFileComparison;
    identical = c.compareFiles(fname1, fname2);
    if identical
        message = c.getFilesIdenticalMessage();
        blnSame = 1;
    else
        message = c.getFilesDifferentMessage();
        blnSame = 0;
    end
    
else
    
    strCmd = ['/usr/bin/diff ' fname1 ' ' fname2];
    [status,result] = unix(strCmd);
    
    if isempty(result)
        blnSame = 1;
    else
        blnSame = 0;
    end
    
end