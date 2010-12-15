function color = getbgcolor

% GETBGCOLOR query window background color
%
% color = getbgcolor
%
% OUTPUTS:
% color - vector of RGB color
%
% EXAMPLE:
% color = getbgcolor

% Author: Ken Hrovat (adapted from java post by Yair Altman)
% $Id: getbgcolor.m 4160 2009-12-11 19:10:14Z khrovat $

listeners=com.mathworks.mde.cmdwin.CmdWinDocument.getInstance.getDocumentListeners;
for i = 1:length(listeners)
    strType = lower(get(listeners(i),'type'));
    if findstr(strType,'jtextarea')
        jTextArea = listeners(i);
        try
            color = get(jTextArea,'Background');
        catch
            color = [];
            warning('could not get bg color')
        end
    end
end