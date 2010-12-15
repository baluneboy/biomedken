function [delta,c,lags,fsMax] = resampled_xcorr(t1,y1,t2,y2)

% RESAMPLED_XCORR resampled cross-correlation?
% EXAMPLE
% y1 = zeros(1,44); y1(5:7) = 5; t1 = 1:length(y1);
% t2 = 1:0.5:11; y2 = zeros(size(t2)); y2(10:15) = 3;
% [delta,c,lags,fsMax] = resampled_xcorr(t1,y1,t2,y2)

% Get sample rate info
fs1 = 1/median(diff(t1));
fs2 = 1/median(diff(t2));
fsMax = max([fs1 fs2]);

disp('to do this right, we would heed resample warning and somehow take care that y1 and y2 near ends are near zero & not use interp')

% figure
% h1=subplot(2,1,1);
% plot(t1,y1,'b',t1,y1,'b.');
% h2=subplot(2,1,2);
% plot(t2,y2,'b',t2,y2,'b.');
% linkaxes([h1 h2],'x')

% Resample
if fs2<fs1
   % upsample 2nd signal 
    y2 = interp(y2,round(fs1/fs2));
else
   % upsample 1st signal
    y1 = interp(y1,round(fs2/fs1));
end

% axes(h1), hold on
% plot(t,y1,'ro')
% axes(h2), hold on
% plot(t,y2,'ro')

[c,lags] = xcorr(y1,y2);
delta = lags(find(c == max(c),1))./fsMax;