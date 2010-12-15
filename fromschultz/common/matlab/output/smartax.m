function yLims = smartax(y,yLo,yHi,pctMargin)
y = y(:);
yMinTemp = min([yLo; y]);
yMaxTemp = max([yHi; y]);
yRange = yMaxTemp - yMinTemp;
if yRange == 0, yRange = 0.05*yMaxTemp; end
yMargin = 0.01*pctMargin*yRange;
yLims(1) = yMinTemp - yMargin;
yLims(2) = yMaxTemp + yMargin;