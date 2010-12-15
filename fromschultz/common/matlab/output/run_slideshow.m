function run_slideshow

[cellFiles, strpath] = uigetfile('*.jpg', 'Select set of images', 'MultiSelect', 'on');
imgindex = 1:1:length(cellFiles);
keyassign = 'qwertyuiop';
cImg = {};
for img = 1:length(imgindex)
    strImgfile = sprintf('%s%s', strpath, cellFiles{img});
    cImg{img,1} = imread(strImgfile);
end

hFig = figure;
ud.cImages = cImg;
guidata(hFig, ud);
figure('KeyPressFcn',@showfig);
    function showfig(src,evnt)
        numKey = regexp(keyassign, evnt.Character);
        locRetrieveFromGUI(numKey, ud)
    end

    function locRetrieveFromGUI(numKey,ud)
        image2disp = ud.cImages{numKey};
        imagesc(image2disp);

    end
end