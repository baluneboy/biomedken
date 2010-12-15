function v = expandranges(str)
%eval(['v= [' strrep(str, '-',':') '];']);

% Marginally better for debug is this:
strNew = strrep(str, '-',':');
v = eval(strNew);