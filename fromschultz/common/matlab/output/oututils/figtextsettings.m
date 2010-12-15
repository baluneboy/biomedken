function [sTextPosition,sFigure]=figtextsettings(numAx,sReport);

%figtextsettings - determine some figure and text settings
%
%[sTextPosition,sFigure]=figtextsettings(numAx,sReport);
%
%Inputs: numAx - integer number of axes (usually 1 or 3)
%        sReport - structure for report objects (TBD)
%
%Outputs: sTextPosition - structure of text positions
%         sFigure - structure of figure properties

%Author: Ken Hrovat, 2/27/2001
% $Id: figtextsettings.m 4160 2009-12-11 19:10:14Z khrovat $

% Determine if 1x1 or 3x1 plot
if ~(numAx==1 | numAx==3)
   strErr=sprintf('expected either 1 or 3 columns for ydata, not %d',numAx);
   error(strErr)
end

% Subplot-dependent settings
if numAx==1 %1x1
   % Figure settings
   sFigure.PaperOrientation='landscape';
   sFigure.PaperPosition=[0.25 0.25 10.5 8];
   % Upper text position settings
   sTextPosition.xUR=1.05;
   sTextPosition.xUL=-0.06;%was -0.05
   %sTextPosition.yUtop=1.08;
   sTextPosition.yUtop=1.09;%was 1.11
   sTextPosition.yDelta=0.02;
   % Comment and version
   sTextPosition.xyzComment=[0.5   1.06 0]; %[0.5   1.17 0];
   sTextPosition.xyzVersion=[1.05 -0.07 0];
else %3x1
   % Figure settings
   sFigure.PaperOrientation='portrait';
   sFigure.PaperPosition=[0.25 0.25 8 10.5];
   % Upper text position settings
   sTextPosition.xUR=1.05;
   sTextPosition.xUL=-0.08;
   %sTextPosition.yUtop=1.34;
   sTextPosition.yUtop=1.36;
   sTextPosition.yDelta=0.05;
   % Comment and version
   sTextPosition.xyzComment=[0.5   1.28 0]; %[0.5   1.17 0];
   %sTextPosition.xyzComment=[0.5   1.24 0]; %[0.5   1.17 0];
   sTextPosition.xyzVersion=[1.05 -0.10 0];
end

% Layout parameters for right side text (this for leftmost, rotated, axes-hugging text)
%sTextPosition.xyzRSbottom=[1.04 0 0];
sTextPosition.xyzRSbottom=[1.04 0 0];
sTextPosition.xRSdelta=0.025;
