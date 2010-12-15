function send2front(hObject)
% When passed a handle of an axes of figure object, SEND2FRONT will place the object on the top
% layer so it can be selected.  Useful for hidden axes.  SEND2FRONT works by loading and changing
% the children list of the parent figure.
%
%   send2front(handle)
%

%
% Author: Eric Kelly 8/10/2000
% $Id: send2front.m,v 1.1.1.1 2001/03/02 18:21:53 hrovat Exp $
%

hParent = get(hObject,'Parent');
hChildren = get(hParent,'Children');

% Find where the object is in the list
index = find(hChildren == hObject);

% Delete the original location of the object
hChildren(index) = [];

% Place a copy of the object handle at the beginning list
hChildren = [hObject;hChildren];

% Store in Parent Figure
set(hParent,'Children',hChildren);


