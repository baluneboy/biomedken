function pth = getdatapath

% you can add your case below

if isunix
    casPaths = {
        '/Volumes/GREEN/sampledata/',...
        '/media/GREEN/sampledata/'};
else % ispc
    casPaths = {...
        's:\data\',...
        'L:\sampledata\',...      
        'j:\sampledata\'};
end

for i = 1:length(casPaths)
    pth = casPaths{i};
    if isdir(pth)
        return
    end
end