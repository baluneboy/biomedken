function cas = dosfind(strDir,strFind)

% EXAMPLE: cas = dosfind('c:\temp\fmri_testing','*post')

owd = pwd;
cd(strDir)
[s,w] = dos(['dir /B /S ' strFind]);
cas = strsplit(10,w);
cas(end) = [];
cd(owd);