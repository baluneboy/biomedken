function findextrema

% create array with maxima and minima
p = peaks(101);
x = 0:100; % x values
y = 0:100; % y values

% compute derivatives in x- and y-directions
[dp_dx,dp_dy] = gradient(p,x,y);

% compute second derivatives
[d2p_dx2,d2p_dy_dx] = gradient(dp_dx,x,y);
[d2p_dx_dy,d2p_dy2] = gradient(dp_dy,x,y);

% plot contour lines where the first derivatives are zero
cx = contour(x,y,dp_dx,[0 0],'r');
hold on
cy = contour(x,y,dp_dy,[0 0],'g');

% Wherever the red and green lines cross is a point where the derivatives
% are both zero and hence either a local extremum or a saddle point. To
% determine which, check the second derivatives at those intersections-- if
% d2p_dx2 and d2p_dy2 are the same sign and positive then you have a
% minimum, if they are the same sign and negative then you are at a minimum
% and if they have different signs then you are at a saddle point.

flag = zeros(101,101);
flag(d2p_dx2 > 0 & d2p_dy2 > 0) = 1; % minima
flag(sign(d2p_dx2) ~= sign(d2p_dy2)) = 2; % saddle
flag(d2p_dx2 < 0 & d2p_dy2 < 0) = 3; % maxima

% Let's plot those regions using yellow for maxima, gray for saddle points
% and cyan for minima and then overlay the contour lines from the first
% figure
figure
map = [0 1 1;0.5 0.5 0.5;1 1 0];
surf(x,y,flag)
colormap(map)
shading flat
view(2)
axes
contour(x,y,dp_dx,[0 0],'r')
hold on
contour(x,y,dp_dy,[0 0],'g')