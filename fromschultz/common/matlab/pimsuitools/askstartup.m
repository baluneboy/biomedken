function strDirBci = askstartup

% please put good help here.

strHost = lower(unix('hostname'));
switch strHost
    case 'outlaw'
        strDirWork = 'c:\_workcopy';
    case 'schultz'
        strDirWork = '\home\Uber\_workcopy';
    otherwise % this is bad form, check with Ken if interested
        strDirWork = 'c:\_workcopy';
end

strButtonName = questdlg('Which bci_analysis basepath?', ...
    'Startup/path Question', ...
    'trunk', 'branches\development\20081124_someopenissues', 'trunk');

strDirBci = strrep(fullfile(strDirWork,'bci_analysis',strButtonName),'\',filesep);
if ~exist(strDirBci,'dir')
    error('daly:bci:exist','%s does not exist',strDirBci)
end
