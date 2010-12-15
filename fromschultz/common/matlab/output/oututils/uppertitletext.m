function h=uppertitletext(h,hAxes,sTextPosition,sFigure,sText);

%uppertitletext - add upper and title text to uppermost axes
%
%h=uppertitletext(h,hAxes,sTextPosition,sFigure,sText);
%
%Inputs: h - structure of handles to add text handles to
%        hAxes - scalar handle of axes to add text objects to
%        sTextPosition - structure of text positions
%        sFigure - structure of figure properties
%        sText - structure of text strings with (at least) fields of:
%             .strTitle - string for type of xdata (like 'Acceleration')
%             .strComment - string for units of xdata (like 'g')
%             .casUL - cell array of upper left strings
%             .casUR - cell array of upper right strings
%
%Outputs: h - structure of handles with new text handles included

%Author: Ken Hrovat, 2/27/2001
% $Id: uppertitletext.m 4160 2009-12-11 19:10:14Z khrovat $

% If top axes, then add Title & Upper text
% Title
h.TextTitle=title(sText.strTitle); set(h.TextTitle,'tag','TextTitle','FontName','Helvetica');
% Comment
if ~isempty(sText.strComment)
   h.TextComment = text(...
      'Parent',hAxes, ...
      'Units','normalized', ...
      'FontName','Helvetica', ...
      'HorizontalAlignment','center', ...
      'Position',sTextPosition.xyzComment, ...
      'String',sText.strComment, ...
      'Tag','TextComment');
end
% Note: right then left & last to first for property inspector top to bottom
if ~isempty(sText.casUR)
   % TextUR (Upper Right)
   for i=length(sText.casUR):-1:1
      h=locTextUpper(hAxes,i,h,sTextPosition.xUR,sTextPosition,sText.casUR);
   end
end
% TextUL (Upper Left)
if ~isempty(sText.casUL)
   for i=length(sText.casUL):-1:1
      h=locTextUpper(hAxes,i,h,sTextPosition.xUL,sTextPosition,sText.casUL);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locTextUpper(hAxes,i,h,posX,sTextPosition,casUpper);

yUtop=sTextPosition.yUtop;
yDelta=sTextPosition.yDelta;

posY=yUtop+(1-i)*yDelta;
if posX<0.5
   strSide='Left';
else
   strSide='Right';
end

% Row identifier
strTextTag=sprintf('TextUpper%s%d',strSide,i);

hText=text(...
   'Parent',hAxes, ...
   'Units','normalized', ...
   'FontName','Helvetica', ...
   'FontSize',7, ...
   'HorizontalAlignment',strSide, ...
   'Position',[posX posY 0], ...
   'String',casUpper{i}, ...
   'Tag',strTextTag);
h=setfield(h,strTextTag,hText);

if isfield(h,'TextALLUpper')
   hOld=getfield(h,'TextALLUpper');
else
   hOld=[];
end
h.TextALLUpper=[hOld; hText];
