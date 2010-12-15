function h=bottomxlabtext(h,hAxes,posRevision,sText);

%bottomxlabtext - add xlabel text to bottommost axes and revision string
%
%h=bottomxlabtext(h,hAxes,sTextPosition,sText);
%
%Inputs: h - structure of handles to add text handles to
%        hAxes - scalar handle of axes to add text objects to
%        posRevision - [x y z] position of revision string
%        sText - structure of text strings with (at least) fields of:
%             .strXType - string for type of xdata (like 'Acceleration')
%             .strXUnits - string for units of xdata (like 'g')
%
%Outputs: h - structure of handles with new text handles included

%Author: Ken Hrovat, 2/27/2001
% $Id: bottomxlabtext.m 4160 2009-12-11 19:10:14Z khrovat $

h.TextXLabel=xlabel(sprintf('%s (%s)',sText.strXType,sText.strXUnits));
set(h.TextXLabel,'Tag','TextXLabel');

if ( isfield(sText,'strVersion') & ~isempty(sText.strVersion) )
   h.TextVersion = text(...
      'Parent',hAxes, ...
      'Units','normalized', ...
      'Color',[0 0 0], ...
      'FontName','Helvetica', ...
      'FontSize',4, ...
      'HorizontalAlignment','right', ...
      'Position',posRevision,...
      'Interpreter','none',...
      'String',sText.strVersion, ...
      'Tag','TextVersion');
end
