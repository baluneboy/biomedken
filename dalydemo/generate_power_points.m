function [hPlot,y,fivepts] = generate_power_points(hax,xval,mu,sigma,num,str)
strTag = get(hax,'tag');
if strcmpi(strTag(end-3:end),'many')
    num = num*15;
end
axes(hax);
hold on;
y = mu + sigma.*randn(num,1);
tol = 1e-6;
ymin = 0+tol;
ymax = 1-tol;
y = locClip(y,ymin,ymax);
fivepts = prctile(y,[2.5 25 50 75 97.5]);
x = xval*ones(size(y));
hPlot = plot(x,y,'.');
set(hPlot,'markersize',22);
set(hPlot,'tag',['linePoints_' str]);

%---------------------------------
function cy = locClip(y,ymin,ymax)
cy = y;
iLo = find(cy<ymin);
iHi = find(cy>ymax);
if ~isempty(iLo), cy(iLo) = randbetween(ymin,ymax,length(iLo)); end
if ~isempty(iHi), cy(iHi) = randbetween(ymin,ymax,length(iHi)); end
