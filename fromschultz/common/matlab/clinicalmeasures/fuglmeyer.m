function s = fuglmeyer(strFile,strSheet)

% % EXAMPLE
% strFile = 's:\data\upper\clinical_measures\plas\s1303plas\Fugl Meyer-s1303plas2.xls';
% strSheet = 'DC 1';
% s = fuglmeyer(strFile,strSheet);

try
    [n,txt,raw] = xlsread(strFile,strSheet);
    s.n = n;
    s.txt = txt;
    s.raw = raw;
catch
    warning(lasterr);
    s = struct([]);
end