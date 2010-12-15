function send2back(hObject)
% When passed a handle of an axes of figure object, SEND2BACK will place the object on the bottom
% layer so it is last to be selected.  Useful for hidden axes.  SEND2BACK works by loading and changing
% the children list of the parent figure.
%
%   send2back(handle)
%

%
% Author: Eric Kelly 8/10/200
% $Id: send2back.m,v 1.1.1.1 2001/03/02 18:21:53 hrovat Exp $
%


hParent = get(hObject,'Parent');
hChildren = get(hParent,'Children');

% Find where the object is in the list
index = find(hChildren == hObject);

% Place a copy of the object handle at the end of the list
hChildren(end+1) = hObject;

% Delete the original location of the object
hChildren(index) = [];

% Store in Parent Figure
set(hParent,'Children',hChildren);


