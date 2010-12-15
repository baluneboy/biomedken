function casSubs = getfmrisubs(strBase,strFolder)

%strBase = 'E:\data\UEdata\fMRI_fromJing_03_14_2007\VASTROKE_BKUP';
%strFolder = 'patients_new'; %'control_new'
%casSubs = getfmrisubs(strBase,strFolder)

strKid = fullfile(fixpath(strBase),strFolder);
[cas,det] = dirdeal([strKid filesep]);
casSubs = {};
for j = 1:length(cas)
    str = cas{j};
    if det(j).isdir
        casSubs = cappend(casSubs,[fixpath(det(j).pathstr) filesep cas{j}]);
    end
end