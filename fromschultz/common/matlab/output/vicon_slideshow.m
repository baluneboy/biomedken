function vicon_slideshow(strJpgDir)

% INPUTS: strJpgDir = string that shows path to image directory

figure('KeyPressFcn',@showfig);

    function showfig(src,evnt)

        % strJpgDir = C:\Documents and Settings\All Users\Documents\My
        % Pictures\Sample Pictures
        s = load('imgwkspace');
        i = 1;

        while i < 13
            switch evnt.Character
                case 'q'
                    % strImg1 = fullfile(strJpgDir, 'HPIM0162.jpg');
                    imshow(s.img1mat)
                case 'w'
                    % strImg2 = fullfile(strJpgDir, 'HPIM0177.jpg');
                    imshow(s.img2mat)
            end
            i = i + 1;
        end

    end

end