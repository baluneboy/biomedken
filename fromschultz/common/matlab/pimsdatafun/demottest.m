function [h,p,ci,s] = demottest(numSubjects,pctMu,pctSigma)

% for mu = 99:1e-3:100,[h,p,ci,s] = demottest(199,mu,100); end

% create fictional measure pre values
% with (numSubjects*5) rows for 5 trials
numRows = numSubjects * 5;
muPre = 2.3;
sigmaPre = 0.8;
fictMeasurePre = normrnd(muPre, sigmaPre, numRows, 1); % first arg = mean, 2nd = std

% let post "improve" by getting smaller (on average) & less-spread post values
muPost = (pctMu/100)*muPre; % post mean is some % of pre value
sigmaPost = (pctSigma/100)*sigmaPre; % post std is some % of pre value
fictMeasurePost = normrnd(muPost, sigmaPost, numRows, 1); % first arg = mean, 2nd = std

% have a comparison look at distributions pre vs. post
binLo = min([fictMeasurePre(:); fictMeasurePost(:)]);
binHi = max([fictMeasurePre(:); fictMeasurePost(:)]);
numBins = 20;
binStep = (binHi - binLo)/(numBins-1);
bins = binLo:binStep:binHi;
[nPre,xBins] = hist(fictMeasurePre,bins);
nPost = hist(fictMeasurePost,bins);
% quick kludge aimed at movie loop
figure(1234),clf
axis([-2 6 0 1.1*numSubjects]), hold on
hPre = plot(xBins,nPre,'r');
hold on
hPost = plot(xBins,nPost,'b');
xlabel('Fictional Measure(putUnitsHere)')
ylabel('Number of Occurrences')

% vertical lines at mean values
xLines = repmat([mean(fictMeasurePre) mean(fictMeasurePost)],2,1);
yLims = get(gca,'ylim'); yMin = yLims(1); yMax = yLims(2);
yLines = repmat([yMin; yMax],1,2);
hLines = line(xLines,yLines);
set(hLines(1),'color','r'); % red is pre color
set(hLines(2),'color','b'); % blue is post color
hold off

[h,p,ci,s] = ttest2(fictMeasurePre,fictMeasurePost,[],[],'unequal');
[ph,pp,pci,ps] = ttest(fictMeasurePre,fictMeasurePost);
fprintf('\npaired = %.4e, ttest2 = %.4e',pp,p)
if h == 1
    strH = 'YES Significant Mean Diff. (Reject Null Hypothesis)';
else
    strH = 'NO Significant Mean Diff. (Accept Null Hypothesis)';
end
casTitle = {strH, sprintf('h=%d, p=%.4f, t=%.4f',h,p,s.tstat)};
title(casTitle)

