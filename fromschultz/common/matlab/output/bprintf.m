function bprintf(style,str)

% EXAMPLE:
% bprintf('red','Krisanne');
%
% See also sprintf, fprintf, cprintf

[foo,str] = dos(['c:\cygwin\bin\banner.exe -c "#" ' str]);
cprintf(style,str);