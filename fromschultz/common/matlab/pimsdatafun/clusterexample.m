echo('on')

% Load simple example data
load trash_clusterexample
whos

% Plot sample data in blue
hFig = figure('WindowStyle','docked');
hb = plot(t,z,'b',t,z,'b.');
shg
hold on
pause

[indLoClusts,indHiClusts] = getfourclusters(z);

% Plot lower two clusters with red circles
hr = plot(t(indLoClusts),z(indLoClusts),'ro','markersize',9);
shg
pause

% Plot higher two clusters with magenta circles
hk = plot(t(indHiClusts),z(indHiClusts),'mo','markersize',9);
shg
pause
disp('how about min cluster run size; if too small and both neighbors are in same, then coallesce')
echo('off')