function setup_slideshow(strJpgDir)

% INPUTS: strJpgDir = string that shows path to image directory

[cellFiles, strpath] = uigetfile('*.jpg', 'Select set of images', 'MultiSelect', 'on');
imgindex = 1:1:length(cellFiles);
keyassign = {'q' 'w' 'e' 'r' 't' 'y' 'u' 'i' 'o' 'p'};


for n = 1:length(imgindex)

    picmat = sprintf('%s%d%s', 'img', n, 'mat');
    picmat = imread(cellFiles{n});
    sprintf('%s %s %s', cellFiles{n}, 'assigned to key', keyassign{n})



end

% save workspace
save('imgwkspace', keyassign, imgstruct)