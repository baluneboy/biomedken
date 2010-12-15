function strCommand=allaxlimdlg(hAxesALL,strXType,strYType,varargin);

%allaxlimdlg - generate axlimdlg command string (see axlimdlg)
%
%strCommand=allaxlimdlg(hAxesALL,strXType,strYType);
%or
%strCommand=allaxlimdlg(hAxesALL,strXType,strYType,optionFlags); % checkboxes for auto, log
%
%Inputs: hAxesALL - vector [or scalar] for handles of axes to control
%        strXType - string for abscissa type, like 'Time'
%        strYType - string for ordinate type, like 'Acceleration'
%        optionFlags - row vector of flags:
%                      1st column: Auto limits checkbox (1=yes, 0=no)
%                      2nd column: Log scaling checkbox (1=yes, 0=no)
%                      Default is [1 0]
%
%Output: strCommand - string for [menu callback] command

%Author: Ken Hrovat, 2/8/2001
% $Id: allaxlimdlg.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin==3
   optionFlags=[1 0];
end
hAxesALL=hAxesALL(:)';
strName='''ALL Axes Limit Dialog''';
strOptions=['[' num2str(optionFlags,22) ']'];
strPrompt=['str2mat(''' strXType ' Range:'',''' strYType ' Range:'')'];
strHAxes=['[' num2str([hAxesALL NaN hAxesALL],22) ']'];
str=num2str(hAxesALL(1),22);
DefLim = ['[get(' str ',''XLim''); get(' str ',''YLim'')]'];
strCommand=['pimsaxlimdlg(' strName ',' strOptions ',' strPrompt ',' strHAxes ',[''x'';''y''],' DefLim ');'];
