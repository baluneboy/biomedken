function varargout = powergui(varargin)
% POWERGUI M-file for powergui.fig
%      POWERGUI, by itself, creates a new POWERGUI or raises the existing
%      singleton*.
%
%      H = POWERGUI returns the handle to a new POWERGUI or the handle to
%      the existing singleton*.
%
%      POWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POWERGUI.M with the given input arguments.
%
%      POWERGUI('Property','Value',...) creates a new POWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before powergui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to powergui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help powergui

% Last Modified by GUIDE v2.5 14-Dec-2010 18:56:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @powergui_OpeningFcn, ...
    'gui_OutputFcn',  @powergui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before powergui is made visible.
function powergui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to powergui (see VARARGIN)

% Choose default command line output for powergui
handles.output = hObject;
handles.fig = hObject;

%% Init

% Deal with checkbox for synchronizing numMove & numRest (of The FEW)
set(handles.checkboxShowNumRest,'Value',0); % unchecked -> not visible
set(handles.editNumRest,'vis','off');

% This sets up the initial plot - only do when we are invisible
% so window can get raised using powergui.
if strcmp(get(hObject,'Visible'),'off')
    pushbutton1_Callback(hObject,eventdata,handles)
end
% UIWAIT makes powergui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Update handles structure
guidata(hObject, handles);


%% Next
% --- Outputs from this function are returned to the command line.
function varargout = powergui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s = locGather(handles);

% Populate sliders/text
hax = [handles.axPowerFew handles.axPowerMany];
for ihax = 1:length(hax)
    hi = hax(ihax);
    axes(hi); cla
    set(gca,'box','on');
    xCushion = 0.9*[-1 1];
    yLim = [-0.02 1.02];
    set(gca,'DataAspectRatio',[3 2 1],'XLim',[1 2]+xCushion,'YLim',yLim);
    set(gca,'xtick',[1 2]); set(gca,'xticklabel',{'MOVE','REST'});
    hVertMove = line([1 1],yLim);
    hVertRest = line([2 2],yLim);
    set([hVertMove hVertRest],'color',0.8*[1 1 1]);
    hold on;
%     pos = get(gca,'pos');
%     set(gca,'pos',[0.01*pos(1) pos(2) 2*pos(3) pos(4)]);
    
    % move
    colorMove = rgb('Green'); % greenish
    handles.hSliderMove = locCreateSlider(colorMove,[-1 4],s.muMove*[1 1],'move');
    set(handles.textMeanMove,'string',sprintf('%0.2f',s.muMove));
    [handles.hPlotMove,yMove,fiveptsMove] = generate_power_points(gca,1,s.muMove,s.sigmaMove,s.numMove,'move');
    set(handles.hPlotMove,'color',colorMove);
    linkmeans(handles.hSliderMove,handles.hPlotMove,handles.textMeanMove);
    set(handles.textMeanMove,'string',sprintf('%.3f',mean(yMove)));
    set(handles.editSigmaMove,'string',sprintf('%.3f',std(yMove)));
    
    % rest
    colorRest = rgb('Red'); % redish
    handles.hSliderRest = locCreateSlider(colorRest,[-1 4],s.muRest*[1 1],'rest');
    set(handles.textMeanRest,'string',sprintf('%0.2f',s.muRest));
    [handles.hPlotRest,yRest,fiveptsRest] = generate_power_points(gca,2,s.muRest,s.sigmaRest,s.numRest,'rest');
    set(handles.hPlotRest,'color',colorRest);
    linkmeans(handles.hSliderRest,handles.hPlotRest,handles.textMeanRest);
    set(handles.textMeanRest,'string',sprintf('%.3f',mean(yRest)));
    set(handles.editSigmaRest,'string',sprintf('%.3f',std(yRest)));
    
end

% update handles
guidata(handles.fig,handles);
set(handles.textMsg,'vis','off');

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Set gui pos
set(hObject,'pos',[24 6 211 66]);

%-------------------------------------------------
function hLine = locCreateSlider(thecolor,X,Y,str)
hLine = line(X,Y);
set(hLine,'Color',thecolor,'LineWidth',2,'LineStyle',':');
set(hLine,'tag',['lineMean_' str]);
% set(hLine,'userdata',hText);
% draggable(hLine,'v',[0 1],@moveline);

% --------------------------------------------
function moveline(h)
ydataLine = get(h,'YData');
hText = get(h,'userdata');
set(hText,'string',sprintf('%.2f',ydataLine(1)));



function editSigmaMove_Callback(hObject, eventdata, handles)
% hObject    handle to editSigmaMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigmaMove as text
%        str2double(get(hObject,'String')) returns contents of editSigmaMove as a double
locSetLimboState(handles);


% --- Executes during object creation, after setting all properties.
function editSigmaMove_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigmaMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigmaRest_Callback(hObject, eventdata, handles)
% hObject    handle to editSigmaRest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigmaRest as text
%        str2double(get(hObject,'String')) returns contents of editSigmaRest as a double
%SET(handles.textMsg,'vis','on');
locSetLimboState(handles);;


% --- Executes during object creation, after setting all properties.
function editSigmaRest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigmaRest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------
function s = locGather(h)
s.muMove = str2double(get(h.textMeanMove,'string'));
s.sigmaMove = str2double(get(h.editSigmaMove,'string'));
s.numMove = str2double(get(h.editNumMove,'string'));
s.muRest = str2double(get(h.textMeanRest,'string'));
s.sigmaRest = str2double(get(h.editSigmaRest,'string'));
if ~get(h.checkboxShowNumRest,'value')
   set(h.editNumRest,'string',get(h.editNumMove,'string'))
end
s.numRest = str2double(get(h.editNumRest,'string'));


function editNumMove_Callback(hObject, eventdata, handles)
% hObject    handle to editNumMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumMove as text
%        str2double(get(hObject,'String')) returns contents of editNumMove as a double
locSetLimboState(handles);


% --- Executes during object creation, after setting all properties.
function editNumMove_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumRest_Callback(hObject, eventdata, handles)
% hObject    handle to editNumRest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumRest as text
%        str2double(get(hObject,'String')) returns contents of editNumRest as a double
locSetLimboState(handles);


% --- Executes during object creation, after setting all properties.
function editNumRest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumRest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function locSetLimboState(h)
set(h.textMsg,'vis','on');

%% FIXME:
% any event/condition that would result in negative power points should be detected/corrected with msg to user (changes to: std,mean,randn,others?)

% instead of power pts, do 5-number summary objects instead




% --- Executes on button press in checkboxShowNumRest.
function checkboxShowNumRest_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowNumRest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowNumRest
if get(hObject,'Value')
    set(handles.editNumRest,'vis','on');
else
    set(handles.editNumRest,'vis','off');
end
locSetLimboState(handles);
