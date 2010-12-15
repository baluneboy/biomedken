function blnSuccess = setbgcolor(strColor)

% SETBGCOLOR change command window background color
%
% blnSuccess = setbgcolor(strColor)
%
% INPUTS:
% strColor - string for color (like yellow or white)
%
% OUTPUTS:
% blnSuccess - boolean; one if color change was success; otherwise zero
%
% EXAMPLE:
% setbgcolor('yellow'), pause(3), blnSuccess = setbgcolor('white')

% Author: Ken Hrovat (adapted from java post by Yair Altman)
% $Id: setbgcolor.m 4160 2009-12-11 19:10:14Z khrovat $

blnSuccess = 0;
listeners=com.mathworks.mde.cmdwin.CmdWinDocument.getInstance.getDocumentListeners;
for i = 1:length(listeners)
    strType = lower(get(listeners(i),'type'));
    if findstr(strType,'jtextarea')
        jTextArea = listeners(i);
        if strcmpi(strColor,'periwinkle')
            set(jTextArea,'Background',[204 204 255]/255);
            blnSuccess = 1;
            return
        end
        strCmd = ['jTextArea.setBackground(java.awt.Color.' lower(strColor) ');'];
        try
            eval(strCmd);
            blnSuccess = 1;
        catch
            warning('could not set bg color to %s',lower(strColor))
        end
    end
end