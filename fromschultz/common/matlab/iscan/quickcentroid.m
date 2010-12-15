function s = quickcentroid(strJPG)

%
% % see following URL:
% % http://blogs.mathworks.com/steve/2007/08/31/intensity-weighted-centroids/
%
% EXAMPLE
% strJPG = 'c:\temp\pt2pt_screenshot_after.jpg';
% s = quickcentroid(strJPG)

I = im2bw(imread(strJPG));
imshow(I);
L = bwlabel(I);
s = regionprops(L, 'Centroid', 'Area');
hold on
for k = 1:numel(s)
    plot(s(k).Centroid(1), s(k).Centroid(2), 'r*')
end
hold off
title('note red asterisk at centroid(s) -- see cmd window dump')