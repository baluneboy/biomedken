function h = createfigure_bcispectra(f,psdAmpTop1,psdAmpBot2,fbins,rsquared,strTitleTop,sText)

% createfigure_bcispectra - routine to create bci spectra subplots
%                           of PSD amplitude and r-squared values vs.
%                           frequency.
%
% INPUTS:
% f - vector of frequency values for PSD amplitude plots
% psdAmpTop1,psdAmpBot2 - vector of PSD values for top target 1 & bottom
%                         target 2, respectively
% fbins - vector of frequency bin values for r-squared plot
% rsquared - vector of r-squared values
% sText - structure for ancillary text with 2 fields:
%      .casUpperLeft - cell array of strings for upperleft text
%      .casUpperRight - cell array of strings for upperright text
%      .casLowerRight - cell array of strings for lowerright text
%      .casLowerLeft - cell array of strings for lowerleft text
%
% OUTPUTS:
% h - structure of handles (also stored in figure via guidata) with fields:
%  .hFig - scalar handle of figure
%  .hAxesPSDlog - scalar handle of top axes (log PSD vs. freq)
%  .hLinePSDlog - scalar handle of top line (log PSD vs. freq)
%  .hAxesPSDlinear - scalar handle of mid axes (linear PSD vs. freq)
%  .hLinePSDlinear - scalar handle of mid line (linear PSD vs. freq)
%  .hAxesRsquared - scalar handle of bot axes (r-squared vs. bins)
%  .hLineRsquared - scalar handle of bot line (r-squared vs. bins)
%  .hAxesAnchor - scalar handle of "anchor axes", which is relative
%                 position reference for ancillary annotations
%  .f - vector of frequencies for PSD
%  .fbins - vector of frequency bins for r-squared
%  .psdAmp - vector of PSD values
%  .rsquared - vector of r-squared values
%
% EXAMPLE
% strTitleTop = 'What goes here?';
% strSubject = 'subject';
% strSetting = 'setting';
% strTask = 'the_task_goes_here';
% strSession = 'sessionNN';
% strDateCollected = 'dateCollected';
% strId = 'SIdS';
% strFile = '/the/complete/path/to/the/file/goes/h.ere';
% sText = createfigure_ancillarytext(strSubject,strSetting,strTask,strSession,strDateCollected,strId,strFile);
% f = 0:30;
% fbins = 1.5:3:28.5;
% psdAmpTop1 = abs(randn(size(f)));
% psdAmpBot2 = psdAmpTop1*2;
% rsquared = abs(randn(size(fbins)));
% h = createfigure_bcispectra(f,psdAmpTop1,psdAmpBot2,fbins,rsquared,strTitleTop,sText);

% Author: Ken Hrovat
% $Id: createfigure_bcispectra.m 4160 2009-12-11 19:10:14Z khrovat $

% Get placeholder text (if needed)
if nargin == 4 || isempty(sText)
    sText = getdefaulttext;
end

% Prepend name of plot to upper right text
sText.casUpperRight = cappend('BCI Spectra',sText.casUpperRight);
sText.casUpperRight = cappend(sText.casUpperRight,strFilterSpatial);
sText.casUpperRight = cappend(sText.casUpperRight,strPSDroutine);

% Create figure
h.hFigureBCIspectra = figure('PaperUnits','inches','PaperOrientation','landscape','PaperPosition',[0.25 0.15 10.5 8]);
set(h.hFigureBCIspectra,'tag','FigureBCIspectra');

% Create top of 3 axes, the PSD [log] amplitude vs. frequency
[h.hAxesPSDlog,h.hLinePSDlogTop1,h.hLinePSDlogBot2,h.hLegendLog] = locCreateAxesPSD('PSDlog',h.hFigureBCIspectra,f,db(psdAmpTop1),db(psdAmpBot2),...
    {'','','','','','',''},...
    [0.14 0.70930 0.75 0.25],...
    [0 30],...
    'on',...
    strTitleTop,...
    [],...
    'PSD Amplitude (dB)',...
    'linear'); % linear because we call via db function

% Create middle of 3 axes, the PSD [linear] amplitude vs. frequency
[h.hAxesPSDlinear,h.hLinePSDlinearTop1,h.hLinePSDlinearBot2,h.hLegendLinear] = locCreateAxesPSD('PSDlinear',h.hFigureBCIspectra,f,psdAmpTop1,psdAmpBot2,...
    {'','','','','','',''},...
    [0.14 0.40380 0.75 0.25],...
    [0 30],...
    'on',...
    [],...
    [],...
    'PSD Amplitude (\muv_{RMS})',...
    'linear');

% Create bottom of 3 axes, the r-squared value vs. frequency
[h.hAxesRsquared,h.hLineRsquared] = locCreateAxesRSQ('Rsquared',h.hFigureBCIspectra,fbins,rsquared,...
    {},...
    [0.14 0.09832 0.75 0.25],...
    [0 30],...
    'on',...
    [],...
    'Frequency (Hz)',...
    'r^2',...
    'linear');

% Create ylabel
ylabel('r^2');

% Create upperleft textbox
h.hAnnotationUpperLeft = annotation(h.hFigureBCIspectra,'textbox',[0 0.9 0.1 0.1],...
    'String',sText.casUpperLeft,...
    'FontSize',8,...
    'LineStyle','none',...
    'Interpreter','none');
set(h.hAnnotationUpperLeft,'tag','AnnotationUpperLeft');

% Create upperright textbox
h.hAnnotationUpperRight = annotation(h.hFigureBCIspectra,'textbox',[0.89 0.9 0.1 0.1],...
    'String',sText.casUpperRight,...
    'FontSize',8,...
    'LineStyle','none');
set(h.hAnnotationUpperRight,'tag','AnnotationUpperRight');

% Create lowerright textbox
h.hAnnotationLowerRight = annotation(h.hFigureBCIspectra,'textbox',[0.8 0 0.2 0.05],...
    'String',sText.casLowerRight,...
    'FontSize',6,...
    'LineStyle','none');
set(h.hAnnotationLowerRight,'tag','AnnotationLowerRight');

% Create lowerleft textbox
h.hAnnotationLowerLeft = annotation(h.hFigureBCIspectra,'textbox',[0 0 0.2 0.05],...
    'String',sText.casLowerLeft,...
    'FontSize',6,...
    'LineStyle','none');
set(h.hAnnotationLowerLeft,'tag','AnnotationLowerLeft');

% Establish "anchor axes" and store data in figure
h.hAxesAnchor = h.hAxesPSDlinear;
h.f = f;
h.fbins = fbins;
h.psdAmpTop1 = psdAmpTop1;
h.psdAmpBot2 = psdAmpBot2;
h.rsquared = rsquared;
h.handles = guihandles(h.hFigureBCIspectra);
guidata(h.hFigureBCIspectra,h);

%--------------------------------------------------------------------------
function [hAx,hLineTop1,hLineBot2,hLegend] = locCreateAxesPSD(strTag,hParent,f,dataTop1,dataBot2,casXTickLabel,position,xLim,strBox,strTitle,strXlabel,strYlabel,strYscale)
hAx = axes('Parent',hParent,'Tag',strTag,'Position',position,'box',strBox);
hLineTop1 = plot(f,dataTop1,'b','lineWidth',2,'Parent',hAx); hold on;
hLineBot2 = plot(f,dataBot2,'r-.','lineWidth',2,'Parent',hAx); hold off;
locScaleAndLabels(hAx,xLim,strYscale,casXTickLabel,strXlabel,strYlabel,strTitle);
set(hAx,'tag',['Axes' strTag]);
set(hLineTop1,'tag',['Line' strTag 'TopTarget1']);
set(hLineBot2,'tag',['Line' strTag 'BottomTarget2']);
hLegend = legend('Top Target 1','Bottom Target 2','location','northeast');
legend boxoff;
set(hLegend,'fontsize',8);
set(hLegend,'fontweight','bold');
set(hLegend,'tag',['Legend' strTag]);

%--------------------------------------------------------------------------
function [hAx,hLine] = locCreateAxesRSQ(strTag,hParent,f,data,casXTickLabel,position,xLim,strBox,strTitle,strXlabel,strYlabel,strYscale)
hAx = axes('Parent',hParent,'Tag',strTag,'Position',position,'box',strBox);
hLine = plot(f,data,'b','lineWidth',2,'Parent',hAx);
locScaleAndLabels(hAx,xLim,strYscale,casXTickLabel,strXlabel,strYlabel,strTitle);
set(hAx,'tag',['Axes' strTag]);
set(hLine,'tag',['Line' strTag]);

% ---------------------------------------------------------------------------------------
function locScaleAndLabels(hAx,xLim,strYscale,casXTickLabel,strXlabel,strYlabel,strTitle)
set(hAx,'xlim',xLim,'yscale',strYscale);
if ~isempty(casXTickLabel)
    set(hAx,'xticklabel',casXTickLabel);
end
locLabel('x',strXlabel);
locLabel('y',strYlabel);
locLabel('t',strTitle);

%--------------------------------
function locLabel(strXY,strLabel)
if isempty(strLabel)
    return
end
switch lower(strXY)
    case 'x'
        xlabel(strLabel);
    case 'y'
        ylabel(strLabel);
    case 't'
        title(strLabel);
    otherwise
        error('unknown label specifier %s',strXY)
end