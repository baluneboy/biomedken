function varargout = findandreplace(varargin)
% FINDANDREPLACE M-file for findandreplace.fig
%      FINDANDREPLACE, by itself, creates a new FINDANDREPLACE or raises
%      the existing
%      singleton*.
%      FINDANDREPLACE creates a graphical interface for the RFINDREPLACE function.
%
%      H = FINDANDREPLACE returns the handle to a new FINDANDREPLACE or the handle to
%      the existing singleton*.
%
%      FINDANDREPLACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDANDREPLACE.M with the given input arguments.
%
%      FINDANDREPLACE('Property','Value',...) creates a new FINDANDREPLACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findandreplace_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findandreplace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findandreplace

% Last Modified by GUIDE v2.5 08-Mar-2007 16:06:46

% Auth Matthias Beebe

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findandreplace_OpeningFcn, ...
                   'gui_OutputFcn',  @findandreplace_OutputFcn, ...
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


% --- Executes just before findandreplace is made visible.
function findandreplace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findandreplace (see VARARGIN)

% Choose default command line output for findandreplace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes findandreplace wait for user response (see UIRESUME)
% uiwait(handles.figure1);


initial_dir = pwd;
% Populate the listbox
load_listbox(initial_dir,handles)

 

% --- Outputs from this function are returned to the command line.
function varargout = findandreplace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Edit_SearchTxt_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_SearchTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_SearchTxt as text
%        str2double(get(hObject,'String')) returns contents of Edit_SearchTxt as a double


% --- Executes during object creation, after setting all properties.
function Edit_SearchTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_SearchTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_ReplaceTxt_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_ReplaceTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_ReplaceTxt as text
%        str2double(get(hObject,'String')) returns contents of Edit_ReplaceTxt as a double


% --- Executes during object creation, after setting all properties.
function Edit_ReplaceTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_ReplaceTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Btn_FindRepl.
function Btn_FindRepl_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_FindRepl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index = get(handles.ListBox_Directory,'Value');
filestrs = get(handles.ListBox_Directory,'String');
file_selected = filestrs{index};

searchtxt = get(handles.Edit_SearchTxt,'String');
replacetxt = get(handles.Edit_ReplaceTxt,'String');
filetypes = get(handles.Edit_FileTypes,'String');

if(~isempty(filetypes))
    file_types = textscan(filetypes, '%s', 'delimiter', ',');    
    file_exts = strvcat(file_types{1}(:));
else
    file_exts = [];
end

brecurse = get(handles.Checkbox_Recursive, 'Value');

if(~isempty(searchtxt))    
    if(~isempty(replacetxt))
        if(isdir(file_selected))
            if(brecurse)
                results = rfindreplace(file_selected, searchtxt, replacetxt, 1, {}, file_exts);
            else
                results = rfindreplace(file_selected, searchtxt, replacetxt, -1, {}, file_exts);
            end
        else
            results = rfindreplace(searchtxt, replacetxt, file_selected);
        end
        set(handles.ListBox_Output, 'String', results);
    else
        if(isdir(file_selected))
            if(brecurse)
                results = rfindreplace(file_selected, searchtxt, -1, 1, {}, file_exts);
            else
                results = rfindreplace(file_selected, searchtxt, -1, -1, {}, file_exts);
            end
        else
            results = rfindreplace(file_selected, searchtxt);
        end
        set(handles.ListBox_Output, 'String', results);
    end
else
    msgbox('No search term specified.  Enter a search term in the ''Find What'' field.', 'Search text missing', 'error');
    return;
end


% --- Executes on button press in Btn_Cancel.
function Btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
return;



% --- Executes on selection change in ListBox_Output.
function ListBox_Output_Callback(hObject, eventdata, handles)
% hObject    handle to ListBox_Output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListBox_Output contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBox_Output


% --- Executes during object creation, after setting all properties.
function ListBox_Output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListBox_Output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on selection change in ListBox_Directory.
function ListBox_Directory_Callback(hObject, eventdata, handles)
% hObject    handle to ListBox_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListBox_Directory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBox_Directory
get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
    index_selected = get(handles.ListBox_Directory,'Value');
    file_list = get(handles.ListBox_Directory,'String');
    filename = file_list{index_selected};
    if  handles.is_dir(handles.sorted_index(index_selected))
        cd (filename)
        load_listbox(pwd,handles)
    else
        [path,name,ext,ver] = fileparts(filename);
        switch ext
            case '.fig'
                guide (filename)
            otherwise
                try
                    open(filename)
                catch
                    errordlg(lasterr,'File Type Error','modal')
                end
        end
    end
elseif strcmp(get(handles.figure1, 'SelectionType'), 'normal')
    index = get(handles.ListBox_Directory,'Value');
    filestr = get(handles.ListBox_Directory,'String');
    set(handles.text5,'String', [pwd filesep filestr{index}]);
end


% --- Executes during object creation, after setting all properties.
function ListBox_Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListBox_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% loads the directory browser list box
function load_listbox(dir_path, handles)
% dir_path  path of directory to load into the list
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
for i = 1:length(handles.file_names) % put fileseparator on dirnames
    if(handles.is_dir(i) == 1)
        handles.file_names{i} = [handles.file_names{i} filesep];
    end
end
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.ListBox_Directory,'String',handles.file_names,'Value',1)
set(handles.text5,'String',pwd)



% --- Executes on button press in Checkbox_Recursive.
function Checkbox_Recursive_Callback(hObject, eventdata, handles)
% hObject    handle to Checkbox_Recursive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Checkbox_Recursive




% --- Executes on button press in Button_ClearResults.
function Button_ClearResults_Callback(hObject, eventdata, handles)
% hObject    handle to Button_ClearResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 set(handles.ListBox_Output, 'String', []);





function Edit_FileTypes_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_FileTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_FileTypes as text
%        str2double(get(hObject,'String')) returns contents of Edit_FileTypes as a double


% --- Executes during object creation, after setting all properties.
function Edit_FileTypes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_FileTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


