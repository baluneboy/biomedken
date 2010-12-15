function varargout = guigetfiles(varargin)
% GUIGETFILES M-file for guigetfiles.fig
%      GUIGETFILES, by itself, creates a new GUIGETFILES or raises the existing
%      singleton*.
%
%      H = GUIGETFILES returns the handle to a new GUIGETFILES or the handle to
%      the existing singleton*.
%
%      GUIGETFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGETFILES.M with the given input arguments.
%
%      GUIGETFILES('Property','Value',...) creates a new GUIGETFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guigetfiles_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guigetfiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Author: Ken Hrovat

% Edit the above text to modify the response to help guigetfiles

% Last Modified by GUIDE v2.5 05-Apr-2007 08:41:40

% For test/debug
global BOOLEAN_DEBUG SECONDS_STATUS
if BOOLEAN_DEBUG
    SECONDS_STATUS = 1;
else
    SECONDS_STATUS = 0;
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guigetfiles_OpeningFcn, ...
    'gui_OutputFcn',  @guigetfiles_OutputFcn, ...
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

% --- Executes just before guigetfiles is made visible.
function guigetfiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guigetfiles (see VARARGIN)

% Decrypt or complain
fprintf('\nAttempting to decrypt...')
strEncrypted = 'deidentify_encrypted.mat';
strWhich = which(strEncrypted);
if isempty(strWhich)
    strMessage = sprintf('PATH PROBABLY NOT SET ... could not find %s',strEncrypted);
else
    strDecrypted = decrypt(strWhich,'.m');
    strMessage = sprintf('found and decrypted coded info.');
end
fprintf('%s',strMessage)

% Copy prt files
strPRTs = which('guigetfiles');
[strPRTsPath,strJUNKNAME,strJUNKEXT,strJUNKVER] = fileparts(which(mfilename));
[casPRTs,detayles]=dirdeal([strPRTsPath filesep '*.prt']);
if isempty(casPRTs)
    strMessage = sprintf('COULD NOT FIND .prt FILES IN %s',strPRTsPath);
else
    if isunix
        tmp = '/tmp/';
    else
        tmp = 'c:/temp/';
    end
    numPRTs = length(casPRTs);
    for jj = 1:length(casPRTs)
        strFile = [strPRTsPath filesep casPRTs{jj}];
        [blnSTATUS,MESSAGE,MESSAGEID] = copyfile(strFile,tmp,'f');
        if ~blnSTATUS
            error(sprintf('got msg %s when trying to copyfile(%s,%s)',MESSAGE,strFile,tmp))
        end
    end
    strMessage = sprintf('..found and copied %d ".prt" files',numPRTs);
end
fprintf('%s',strMessage)

% Choose default command line output for guigetfiles
handles.hFig = hObject;
handles.countRenamed = 0;
handles.countAnonymized = 0;
handles.blnDir = 0;
strDir = pwd;

% Deal with extra inputs
if nargin > 3
    for i = 1:2:length(varargin)
        strP = lower(varargin{i});
        switch strP
            case 'currentdirectory'
                strDir = varargin{i+1};
                if exist(strDir) ~= 7
                    warning('%s not dir, so use pwd',strDir)
                    strDir = pwd;
                end
            otherwise
                error('unknown property %s',strP)
        end
    end
end

% Starter directory
strFrom = locChdir(handles,strDir);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guigetfiles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guigetfiles_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.hFig;

function edCurrDir_Callback(hObject, eventdata, handles)
% hObject    handle to edCurrDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edCurrDir as text
%        str2double(get(hObject,'String')) returns contents of edCurrDir as a double
locUpdateList(handles);

% --- Executes during object creation, after setting all properties.
function edCurrDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edCurrDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%
function locUpdateList(handles)
set(handles.lbToFiles,'str',[],'val',[]);
strPath = [fixpath(get(handles.edCurrDir,'str')) filesep];
[cas,details] = dirdeal(strPath);
if handles.blnDir
    iFiles = find([details.isdir]);
else
    iFiles = find(~[details.isdir]);
end
casFiles = cas(iFiles);
set(handles.lbFromFiles,'str',casFiles);
set(handles.txtCount,'str',sprintf('%d Objects:',length(casFiles)));

% --- Executes on button press in pbBrowse.
function pbBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pbBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strCurrDir = get(handles.edCurrDir,'str');
if exist(strCurrDir) ~= 7, strCurrDir = pwd; end
strNew = uigetdir(strCurrDir,'Please select a folder');
if strNew == 0
    strNew = strCurrDir;
end
set(handles.edCurrDir,'str',strNew);
locUpdateList(handles);

% --- Executes on selection change in lbFromFiles.
function lbFromFiles_Callback(hObject, eventdata, handles)
% hObject    handle to lbFromFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbFromFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbFromFiles


% --- Executes during object creation, after setting all properties.
function lbFromFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbFromFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lbToFiles.
function lbToFiles_Callback(hObject, eventdata, handles)
% hObject    handle to lbToFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbToFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbToFiles


% --- Executes during object creation, after setting all properties.
function lbToFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbToFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pbAdd.
function pbAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pbAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
locAdd(hObject, eventdata, handles);

%
function locAdd(hObject, eventdata, handles)
hFrom = handles.lbFromFiles;
hTo = handles.lbToFiles;
try
    locAddRemove(hFrom,hTo);
catch
    strDir = get(handles.edCurrDir,'str');
    warning(sprintf('could not do add in %s directory',strDir))
end

% --- Executes on button press in pbRemove.
function pbRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFrom = handles.lbToFiles;
hTo = handles.lbFromFiles;
try
    locAddRemove(hFrom,hTo);
catch
    warning('could not do remove')
end

%
function bln = locIsDCM(strFile)
bln = 0;
if strcmp(lower(strFile(end-3:end)),'.dcm')
    bln = 1;
end

%
function strFrom = locChdir(handles,strTo)
strFrom = get(handles.edCurrDir,'str');
set(handles.edCurrDir,'str',strTo);
locUpdateList(handles);

% --- Executes on button press in pbDrill.
function pbDrill_Callback(hObject, eventdata, handles)
% hObject    handle to pbDrill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SECONDS_STATUS
blnSure = areyousuredlg('Sure you want to drill?','This is your chance to turn back.');
if ~blnSure
    msgbox('Phew ... that was a close one.','Nothing Done')
    return
end
tzeroDrill = clock;
strOldMsg = get(handles.txtStatus,'str');
strTopDir = get(handles.edCurrDir,'str');
locStatus(handles,['Drilling down from ' strTopDir],SECONDS_STATUS)

% Find and replace fmr info
[strTRASH,strJUNK,casMap] = deidentify;
t0 = clock;
for kk = 1:2:length(casMap)
    strOld = casMap{kk};
    strNew = casMap{kk+1};
    locStatus(handles,sprintf('doing ".fmr" rfindreplace in %s of %s with %s',strTopDir,strOld,strNew),SECONDS_STATUS)
    rfindreplace(strTopDir,strOld,strNew,get(0,'RecursionLimit'),{},{'.fmr'});
end
secElapsed = etime(clock,t0);
locStatus(handles,sprintf('Took %.2fs to rfindreplace in %s',secElapsed,strTopDir),SECONDS_STATUS)

% Now rename dirs
casDirs = dirdeidentify(strTopDir);
numDirs = length(casDirs);
numRen = 0;
numAnon = 0;
for i = 1:numDirs
    strDir = casDirs{i};
    strFrom = locChdir(handles,strDir);
    lenFrom = length(get(handles.lbFromFiles,'str'));
    locStatus(handles,sprintf('... now doing %s (%d files)',strDir,lenFrom),SECONDS_STATUS)
    set(handles.lbFromFiles,'value',1:lenFrom)
    locAdd(hObject, eventdata, handles);
    %fprintf('\nvisit %s',strDir)
    locRenameAnonymize(handles);
    numRen = numRen + handles.countRenamed;
    numAnon = numAnon + handles.countAnonymized;
end
strFrom = locChdir(handles,strTopDir);
locStatus(handles,sprintf('done drilling.'),SECONDS_STATUS)
locStatus(handles,strOldMsg,SECONDS_STATUS)
secDrill = etime(clock,tzeroDrill);
fprintf('\nIT TOOK %.1f SEC.\n',secDrill)

function locIncrementCounts(handles,numRen,numAnon)
if isempty(numRen) % empty implies reset
    handles.countRenamed = 0;
else
    handles.countRenamed = handles.countRenamed + numRen;
end
if isempty(numAnon) % empty implies reset
    handles.countAnonymized = 0;
else
    handles.countAnonymized = handles.countAnonymized + numAnon;
end
fprintf('\n%s, renamed = %d, anonymized = %d',get(handles.edCurrDir,'str'),handles.countRenamed,handles.countAnonymized)
guidata(handles.hFig,handles);

%
function locStatus(handles,strMessage,varargin)
set(handles.txtStatus,'str',strMessage)
if nargin == 3
    d = varargin{1};
    pause(d)
end

%
function locRenameAnonymize(handles)
global SECONDS_STATUS
hFreeze = [handles.edCurrDir handles.lbFromFiles handles.pbAdd handles.pbRemove handles.pbBrowse];
set(hFreeze,'enable','off')
strOld = get(handles.txtSelection,'string');
strDir = get(handles.edCurrDir,'str');
casFiles = get(handles.lbToFiles,'String');
if isempty(casFiles)
    fprintf('\nIn %s, but nothing to do because no files in "Selection:" list.',strDir)
end
numFiles = length(casFiles);
numANONadd = 0;
numRENadd = 0;
for i = 1:numFiles
    set(handles.txtSelection,'string',sprintf('Working on %d of %d',i,numFiles));
    strName = casFiles{i};
    set(handles.lbToFiles,'Value',i);
    % Rename file or directory
    [strOut,strMessage,casMap] = deidentify(strDir,strName);
    strFile = fullfile(strDir,strOut);
    locStatus(handles,strMessage,SECONDS_STATUS);
    if ~strcmp(strOut,strName)
        numRENadd = numRENadd + 1;
    end
    % Anonymize DCM files
    if locIsDCM(strFile)
        t0 = clock;
        dicomanon(strFile,strFile);
        secElapsed = etime(clock,t0);
        locStatus(handles,sprintf('Took %.2fs to anonymize %s ...',secElapsed,strFile),SECONDS_STATUS)
        numANONadd = numANONadd + 1;
    else
        locStatus(handles,sprintf('Ignoring %s ...',strFile),SECONDS_STATUS)
    end
end
locIncrementCounts(handles,numRENadd,numANONadd);
set(handles.txtSelection,'string',strOld);
set(hFreeze,'enable','on')
set(handles.lbToFiles,'Value',[]);
%locStatus(handles,sprintf('done; countRenamed = %d, countAnonymized = %d',handles.countRenamed,handles.countAnonymized),SECONDS_STATUS)
locStatus(handles,sprintf('done working on %d files in %s.',numFiles,strDir),SECONDS_STATUS)
locUpdateList(handles);

% --- Executes on button press in pbQuit.
function pbQuit_Callback(hObject, eventdata, handles)
% hObject    handle to pbQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcbf)

% FROM Fabrice.Pabois@ncl.ac.uk - University of Newcastle - 2000
function ListNames = locGetFiles(handles)
% Here you could add your filters if you want to return certain types of files
strCurrDir = get(handles.edCurrDir,'str');
DirRes = dir([fixpath(strCurrDir) filesep '*.*']);

% Get the files + directories names
[ListNames{1:length(DirRes),1}] = deal(DirRes.name);

% Get directories only
[DirOnly{1:length(DirRes),1}] = deal(DirRes.isdir);

% Turn into logical vector and take complement to get indexes of files
FilesOnly = ~cat(1, DirOnly{:});
if handles.blnDir
    ListNames = ListName(DirOnly);
else
    ListNames = ListNames(FilesOnly);
end

% FROM Fabrice.Pabois@ncl.ac.uk - University of Newcastle - 2000
function locAddRemove(hFrom,hTo)
NewSelection = get(hFrom,'Value');
if isempty(NewSelection), return; end
FromList = get(hFrom,'String');
ToList = get(hTo,'String');
if isempty(ToList)
    NewToList = FromList(NewSelection);
else
    NewToList = union(ToList, FromList(NewSelection));
end
set(hTo, 'String', NewToList);
FromList(NewSelection) = [];
set(hFrom,'str',FromList);
set(hFrom,'val',1);

% --- Executes on button press in cbDir.
function cbDir_Callback(hObject, eventdata, handles)
% hObject    handle to cbDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDir
handles.blnDir = get(hObject,'Value');
guidata(gcbf,handles);
locUpdateList(handles);

% --- Executes on button press in pbAnonymize.
function pbAnonymize_Callback(hObject, eventdata, handles)
% hObject    handle to pbAnonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
locRenameAnonymize(handles);
locIncrementCounts(handles,[],[]); % zero counts

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
locQuit(hObject, eventdata, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
locQuit(hObject, eventdata, handles);

%
function locQuit(hObject, eventdata, handles);
strDI = which('deidentify');
if ~isempty(strDI)
    delete(strDI)
    msgbox('Found & deleted deidentify.m')
end
delete(hObject);