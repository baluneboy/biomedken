function update_fmri_three_clinicalmeasures_table()

% Init
strDirBase = 's:\data\upper\clinical_measures';

casSubjects = {
    's1240moda',...
    's1241moda',...
    's1242moda',...
    's1301plas',...
    's1303plas',...
    's1306plas',...
    's1310plas',...
    's1311plas',...
    's1312plas',...
    's1314plas',...
    's1315plas',...
    's1328plas',...
    's1331plas',...
    's1332plas',...
    's1349plas',...
    's1351plas'};

% casMeasures = {
%     'MMT',...
%     'FuglMeyer',...
%     'AMAT'};

casMeasures = {'MMT'};

for i = 1:length(casSubjects)
    strSubject = casSubjects{i};
    strStudy = strSubject(end-3:end);
    strDirSub = fullfile(strDirBase,strStudy,strSubject);
    str = '';
    for j = 1:length(casMeasures)
        strMeasure = casMeasures{j};
        strFile = fullfile(strDirSub,[strMeasure '-' strSubject '.xls']);
        eval(['strOut = loc' strMeasure '(strFile);']);
        str = [str ',' strOut];
    end
    fprintf('\n%s%s',strSubject,str)
end

% ----------------------------------------
function strOut = locMMT(strFile)
if ~exist(strFile,'file')
    strOut = '';
    return
end
[strTemp,strSubject,preSEscore,postSEscore,preWHscore,postWHscore] = getmmtprepostscores(strFile);
strOut = sprintf('%.3f,%.3f,%.3f,%.3f',preSEscore,postSEscore,preWHscore,postWHscore);

% ----------------------------------------
function strOut = locFuglMeyer(strFile)
strFile = strrep(strFile,'FuglMeyer','Fugl-Meyer');
if ~exist(strFile,'file')
    strOut = '';
    return
end
[strTemp,strSubject,preSEscore,postSEscore,preWHscore,postWHscore,preCOORDscore,postCOORDscore] = getfuglmeyerprepostscores(strFile);
strOut = sprintf('%.3f,%.3f,%.3f,%.3f,%.3f,%.3f',preSEscore,postSEscore,preWHscore,postWHscore,preCOORDscore,postCOORDscore);

% ----------------------------------------
function strOut = locAMAT(strFile)
if ~exist(strFile,'file')
    strOut = '';
    return
end
[strTemp,strSubject,preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH] = getamatpreposttotaltime(strFile);
strOut = sprintf('%.3f,%.3f,%.3f,%.3f,%.3f,%.3f',preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH);
