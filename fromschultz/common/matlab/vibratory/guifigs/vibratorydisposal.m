function varargout=vibratorydisposal(action,varargin);

%vibratorydisposal - switchyard for gui that is initialized with the
%                    following objects (from offline front-end):
%
%        type  tag             usage
% ---------------------------------------------------------------------
%     listbox  ListboxData     UserData gets data matrix
%                              and listbox string gets load notes
%     listbox  ListboxHeader   UserData gets structure of header info
%        edit  EditTextComment UserData gets structure of search criteria
%
%varargout=vibratorydisposal(action,varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Front-End Makes Following Calls                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Call from front-end code for displaying load notes:
%
%h=vibratorydisposal('GetHandles'); %Output: h - structure of gui handles
%
%Call from front-end for transferring data matrix, header structure & other info:
%
%vibratorydisposal('Initialize',hFig,data,sHeader,casNotes,sSearchCriteria);
%
%Inputs: action - string for switchyard
%        hFig - scalar handle of disposal gui
%        data - matrix of data
%        sHeader - structure of header info
%        casNotes - cell array of strings for notes from load process
%        sSearchCriteria - structure of search criteria
%
%Outputs: << implicit: gui figure for modifying disposition parameters, then
%                      calling output routines >>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Front-End Makes Previous Calls                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% written by: Ken Hrovat on 12/27/2000
% $Id: vibratorydisposal.m 4160 2009-12-11 19:10:14Z khrovat $
% 1/1/2001 - Hrovat added pilot logic to 'Initialize' case

switch action
   
case 'GetHandles'
   
   % ERIC, THE CODE FROM HERE TO ... (SEE END OF SWITCH)
   % Call GUI figure
   strRelease=matlabrelease;
   switch strRelease
   case {'(R11)','(R11.1)'}
      fig=getguihandle(mfilename);
      h=guihandles(fig); % this works on Ken's PC because "borrowed" demo code, so for now, Eric might have to use next line
      %h=locGuihandles(fig); % adjust this local function for your disposal gui
   case '(R12)'
      warnmodal('Hey Ken','You can simplify popload.m "handles handling" now in (R12).');
      % FOR (R12), JUST NEXT SET OF LINES NEEDED INSTEAD OF THE SWITCH strRelease CODE
      fig=openfig([mfilename 'fig' pophostname],'reuse');
      % Generate a structure of handles to pass to callbacks, and store it. 
      h=guihandles(fig); %Return structure of gui handles
      guidata(fig,h);    %Store handles in the figure's application data
      % FOR (R12), JUST PREVIOUS SET OF LINES NEEDED INSTEAD OF THE SWITCH strRelease CODE
   otherwise
      error('unaccounted for MATLAB release');
   end %switch strRelease
   % ... HERE WILL SOON BE UPDATED TO EXPLOIT NEW FUNCTIONS IN R12
   
   % Verify output argument for handles
   if nargout==1
      varargout{1}=h;
   else
      error('wrong nargout')
   end
   
case 'Initialize'
   
   % Deal inputs
   if nargin==7 % count includes 1st "action" argument
      [fig,data,sHeader,casNotes,sSearchCriteria,sTail]=deal(varargin{1:6});
   else
      error('wrong nargin')
   end
   
   % Get gui handles
   h=guihandles(fig);
   
   % Set gui figure name
   [strDataType,strLocation,strCutoff,strSampleRate,strStart,strEnd]=dispofigname(fig,sHeader,sSearchCriteria);
   strFigName=sprintf('VD, %s to %s, %s, %s (%s), %s',strStart,strEnd,strLocation,strCutoff,strSampleRate,strDataType);
   set(fig,'Name',strFigName);
   
   % Pretty print header to listbox
   cPretty=prettyprocess(sHeader);
   set(h.ListboxHeader,'str',cPretty);
   
   % Insert default comment
   strComment=sprintf('%s, %s, %s, %s (%s)',upper(strrep(strDataType,'_accel','')),sHeader.SensorID,strLocation,strCutoff,strSampleRate);
   set(h.EditTextComment,'str',strComment);
   
   % Call function to get strings for this DataType's PopupMenus
   [casPlotTypes,casOutputTypes,casSpliceMethods]=popdatatypes(sHeader.DataType);
   
   % Load Output SELF Controls
   set(h.PopupMenuOutputType,'str',casOutputTypes); % populate menu
   pumsetstate(h.PopupMenuOutputType,casOutputTypes{1}); % for reset
   [sOutput,casPretty]=selfchangecontrols('Output',casOutputTypes{1},h,data,sHeader); % load 1st output type
   
   % Load Plot SELF Controls
   set(h.PopupMenuPlotType,'str',casPlotTypes); % populate menu
   pumsetstate(h.PopupMenuPlotType,casPlotTypes{1}); % for reset
   [sPlot,casPretty]=selfchangecontrols('Plot',casPlotTypes{1},h,data,sHeader); % load 1st plot type
   
   %------------Added by EK--------------%   
   % Load DisplayCoordSys SELF Controls
   [sCoordMenu,strFileMessage] = readcoordfile; % read the coord file
   if ~isempty(strFileMessage)%file not loaded 
      sCoordMenu = defaultcsmenu('CoordSys',sHeader);
      warnmodal('Transformations Disabled',strFileMessage);
      set(h.PopupMenuDispCoordSysType,'Enable','off');
   end
   set(h.FrameDispCoordSys,'UserData',sCoordMenu); % store all CS info in Frame
   set(h.PopupMenuDispCoordSysType,'str',sCoordMenu.Name);  % populate menu
   [index] = findsamecoord(sHeader,sCoordMenu,'data'); % default to current CS.
   if isempty(index) %file loaded but no match
      strCoordMessage = 'Could not find DataCoordinateSystem in database file, Transformation Disabled';
      warnmodal('Coordinate System Warning - Unknown Coordinate System',strCoordMessage);
      sCoordMenu = defaultcsmenu('CoordSys',sHeader);
      set(h.FrameDispCoordSys,'UserData',sCoordMenu); % store all CS info in Frame
      set(h.PopupMenuDispCoordSysType,'str',sCoordMenu.Name);  % populate menu
      set(h.PopupMenuDispCoordSysType,'Enable','off');
      index =1;
   else
      %---------------------------- JWST Work Around Cut N Paste  --------------------------%
      warnmodal('Coordinate System Warning - Work Around in Effect For JWST',...
         'We are overwriting coordinate system with values from coord.txt');
      aaa = sCoordMenu.Name(index);
      [sHeader.DataCoordinateSystemName] = deal(aaa{:});
      aaa = sCoordMenu.Comment(index);
      [sHeader.DataCoordinateSystemComment]= deal(aaa{:});
      aaa = sCoordMenu.Time(index);
      [sHeader.DataCoordinateSystemTime]= deal(aaa{:});
      aaa= sCoordMenu.XYZ(index);
      [sHeader.DataCoordinateSystemXYZ]= deal(aaa{:});
      aaa=sCoordMenu.RPY(index);
      [sHeader.DataCoordinateSystemRPY]= deal(aaa{:});
      %---------------------------- JWST Work Around Cut N Paste --------------------------%
   end  
   set(h.PopupMenuDispCoordSysType,'value',index);
   [sCoord,casPretty]=selfchangecs('DispCoordSys',index,h);
   %------------Added by EK--------------%
   
   % Configure run mode controls
   strMode=sSearchCriteria.ModeDur.strMode;
   if strcmp('normal',strMode)
      delete(h.StaticTextPilotNumber);
      delete(h.EditTextPilotNumber);
      casRunMode={'auto';'single'};
   elseif strcmp('batch',strMode)
      set(fig,'Color',[0.9 0.9 0]);
      casRunMode={'pilot';'batch'};
      h.numPilot=1;
      set(h.EditTextPilotNumber,'str',h.numPilot);
      h.strFill=casSpliceMethods{1};
   else
      strWarn=sprintf('unaccounted mode: %s',strMode);
      warnmodal('Disposal Init Problem',strWarn);
   end
   % Populate run mode popup menu
   set(h.PopupMenuRunMode,'str',casRunMode);
   
   % Empty disposition list box, value is valid
   set([h.PushbuttonRemove h.PushbuttonRun h.PushbuttonView],'Enable','off')
   set(h.ListboxDisposition,'Value',1,'str',[])
   
   % Get initial results for initial plot/output types
   strPlotType=popupstr(h.PopupMenuPlotType);
   
   % Initialize guidata
   h.data=data;
   h.sHeader=sHeader;
   h.casNotes=casNotes;
   h.sTail=sTail;
   h.sSearchCriteria=sSearchCriteria;
   h.sDispositions=[];
   h.sDone=[];
   guidata(fig,h);
   
   % Hide gui figure handle
   set(fig,'handlevisibility','off');
   
case {'PopupMenuPlotType','PopupMenuOutputType'}
   
   dispochangetype(action,gcbf,gcbo);
   
   %------------Added by EK--------------%    
case {'PopupMenuDispCoordSysType'}
   if nargin==2 % count includes 1st "action" argument
      [fig]=deal(varargin{1});
   else
      error('wrong nargin')
   end
   
   % Get gui handles
   h=guihandles(fig);
   
   % Set to new choice
   [strNew,index]=popupstrval(h.PopupMenuDispCoordSysType);
   set(h.PopupMenuDispCoordSysType,'value',index);
   [sCoord,casPretty]=selfchangecs('DispCoordSys',index,h);  
   
case {'PushbuttonDispCoordSys'}
   % Get guidata
   h=guidata(gcbf);
   sCoordMenu = get(h.FrameDispCoordSys,'UserData'); % retrieve all CS info from Frame
   
   % Generate Default Custom parameters, find any names with custom in it
   index = strmatch('Custom',sCoordMenu.Name);
   if isempty(index)
      sCoordDefault.Name = 'Custom';
   else
      sCoordDefault.Name = [sCoordMenu.Name{index(end)} '1'];
   end
   sCoordDefault.Comment= 'Lab,Rack,Location';
   sCoordDefault.RPY =[0 0 0];
   sCoordDefault.XYZ = [0 0 0];
   sCoordDefault.Time = popdatestr(now,-3.1);
   
   editcoordsys('Initialize',h,sCoordDefault,sCoordMenu.Name,gcbo);  
   
case 'PushbuttonTransformInPlace'
   % Get guidata
   h=guidata(gcbf);
   
   % Get coordinate system parameters
   sCoord=get(h.ListboxDispCoordSysParams,'UserData');
   
   % Check to make sure coordinate systems are different and do transformation
   if ~(strcmp(h.sHeader.DataCoordinateSystemName,sCoord.Name)...
         & strcmp(h.sHeader.DataCoordinateSystemComment,sCoord.Comment))
      [h.data,h.sHeader] = transformcoord(h.data,h.sHeader,sCoord);
   end
   
   % Pretty print header to listbox
   cPretty=prettyprocess(h.sHeader);
   set(h.ListboxHeader,'str',cPretty);
   
   % Store the data in the figure again
   guidata(gcbf,h);
   
   %------------Added by EK--------------%  
   
   
case 'PushbuttonEditOutputParameters'
   
   % Get guidata
   h=guidata(gcbf);
   
   % Establish nested parameters structure
   comment=get(h.EditTextComment,'str');
   sHeader=h.sHeader;
   sPlotParameters=get(h.ListboxPlotParameters,'UserData');
   sOutputParameters=get(h.ListboxOutputParameters,'UserData');
   parameters=[];
   parameters=setfield(parameters,'plot',sPlotParameters);
   parameters=setfield(parameters,'output',sOutputParameters);
   
   % Call editor based on output type string
   strEditor=popupstr(h.PopupMenuOutputType);
   strHost=pophostname;
   strProg=['edit' strEditor];
   strFig=[strProg 'fig' strHost];
   if exist(strFig)==2
      hParent=gcbf;
      eval([strProg '(''Initialize'',''' strFig ''',hParent,sHeader,parameters,comment);']);      
   else
      error(sprintf('editor GUI: %s not found on path',strFig));
   end
   
case 'PushbuttonEditPlotParameters'
   
   % Get guidata
   h=guidata(gcbf);
   
   % Establish nested parameters structure
   comment=get(h.EditTextComment,'str');
   sHeader=h.sHeader;
   sPlotParameters=get(h.ListboxPlotParameters,'UserData');
   sOutputParameters=get(h.ListboxOutputParameters,'UserData');
   parameters=[];
   parameters=setfield(parameters,'plot',sPlotParameters);
   parameters=setfield(parameters,'output',sOutputParameters);
   
   % Call editor based on plot type string
   strEditor=popupstr(h.PopupMenuPlotType);
   strHost=pophostname;
   strProg=['edit' strEditor];
   strFig=[strProg 'fig' strHost];
   if exist(strFig)==2
      hParent=gcbf;
      eval([strProg '(''Initialize'',''' strFig ''',hParent,sHeader,parameters,comment);']);      
   else
      error(sprintf('editor GUI: %s not found on path',strFig));
   end
   
case 'PushbuttonAdd' 
   
   % Get guidata
   h=guidata(gcbo);
   
   % Build command and pretty string
   strPlotType=popupstr(h.PopupMenuPlotType);
   strOutputType=popupstr(h.PopupMenuOutputType);
   strDisplayCoordinateSystem=popupstr(h.PopupMenuDispCoordSysType);
   strComment=get(h.EditTextComment,'str');
   strCommand=['sHandles=' strPlotType '(' num2str(gcbf) ',sDisposition);'];
   strPrettyCommand=[strPlotType ' to ' strOutputType ' in ' strDisplayCoordinateSystem ', ' strComment(1:min([50 length(strComment)]))];
   
   % Get plot parameters
   sPlot=get(h.ListboxPlotParameters,'UserData');
   
   % Get output parameters
   sOutput=get(h.ListboxOutputParameters,'UserData');
   
   %------------Added by EK--------------% 
   % Get coordinate system parameters
   sCoord=get(h.ListboxDispCoordSysParams,'UserData');
   %------------Added by EK--------------%    
   
   % Retrieve old disposition structure
   if isfield(h,'sDispositions') & ~isempty(h.sDispositions)
      sDispositions = h.sDispositions;
      % Determine the maximum run number currently used.
      maxNum=sDispositions(length(sDispositions)).RunNumber;
      NextNumber=maxNum+1;
   else 
      % Set up the disposal structure
      sDispositions=[];
      NextNumber=1;
   end
   if NextNumber==1
      % Enable the Remove button
      set([h.PushbuttonRemove h.PushbuttonRun h.PushbuttonView],'Enable','on')
   end
   
   % Set up the disposal structure
   sDispositions(NextNumber).RunNumber=NextNumber;
   sDispositions(NextNumber).strPrettyCommand=[num2str(NextNumber) '. ' strPrettyCommand];
   sDispositions(NextNumber).strCommand=strCommand;
   sDispositions(NextNumber).strComment=strComment;
   sDispositions(NextNumber).sPlot=sPlot;
   sDispositions(NextNumber).sOutput=sOutput;
   [strLogPath,strResultsPath,strUnique]=logresultspath(sOutput,h.sHeader,strPlotType,strComment);
   sDispositions(NextNumber).LogPath=strLogPath;
   sDispositions(NextNumber).ResultsPath=strResultsPath;
   sDispositions(NextNumber).UniqueString=strUnique;
   sDispositions(NextNumber).sCoord=sCoord;
   
   % Build the new list string for the listbox
   append2listbox(h.ListboxDisposition,sDispositions(NextNumber).strPrettyCommand);
   
   % Store the new sDispositions
   h.sDispositions = sDispositions;
   guidata(gcbf,h)
   
case 'PushbuttonRemove' %function varargout = PushbuttonRemove_Callback(h, eventdata, handles, varargin)
   
   h=guidata(gcbo);
   
   % Get disposition list info
   val = get(h.ListboxDisposition,'value');
   casDispositionList = get(h.ListboxDisposition,'str');
   
   % Remove the data and list entry for the selected value
   casDispositionList(val) =[];
   sDispositions=h.sDispositions(val);
   h.sDispositions(val)=[];
   if nargout==2
      varargout{1}=h;
      varargout{2}=sDispositions;
   end
   
   % If there are no other entries, then reset & disable the remove button
   if isempty(h.sDispositions)
      set(h.ListboxDisposition,'value',1,'str',[])
      set([h.PushbuttonRemove h.PushbuttonRun h.PushbuttonView],'Enable','off')
   else % Ensure that list box Value is valid, then reset Value and String
      num = size(casDispositionList,1);
      val = min(val,num);
      set(h.ListboxDisposition,'Value',val,'String',casDispositionList)
   end
   
   % Store the new disposition list
   guidata(gcbf,h)
   
case 'PushbuttonView'
   
   h=guidata(gcbo);
   
   % Get disposition list info
   val = get(h.ListboxDisposition,'value');
   casDispositionList = get(h.ListboxDisposition,'str');
   
   % IMPROVE THIS: Message box for the selected value
   sDisposition=h.sDispositions(val);
   casFields=fieldnames(sDisposition);
   for i=1:length(casFields)
      strField=casFields{i};
      strValue=getfield(sDisposition,strField);
      if isstruct(strValue)
         strValue=strField;
      elseif ~isstr(strValue)
         strValue=num2str(strValue);
      elseif length(strValue)>55
         strValue=strValue(1:55);
      end
      casDispo{i,1}=sprintf('%s: %s',strField,strValue);
   end
   %casDispo=prettyprocess(sDisposition);
   hMsg=msgbox(casDispo,'View Disposition');
   
case 'EditTextPilotNumber'
   
   % Get handles
   h=guidata(gcbf);
   
   % Coerce value to integer
   strPilotNumber=get(h.EditTextPilotNumber,'str');
   numPilot=str2num(strPilotNumber);
   numPilot=round(abs(numPilot));
   set(h.EditTextPilotNumber,'str',numPilot)
   
   % Store the new info
   h.numPilot=numPilot;
   guidata(gcbf,h)
   
case 'PopupMenuRunMode'
   
   % Get handles
   h=guidata(gcbf);
   
   strRunMode=popupstr(h.PopupMenuRunMode);
   
   switch strRunMode
      
   case {'single','auto'} % non-batch
      % nothing to do here
   case 'pilot'
      vibratorydisposal('EditTextPilotNumber');
   case 'batch'
      h.numPilot=0;
      set(h.EditTextPilotNumber,'str','0');
   otherwise
      strMsg=sprintf('unknown run mode %s',strRunMode);
      error(strMsg)
   end % switch strRunMode
   
   % Store the new info
   guidata(gcbf,h)
   
case 'PushbuttonRun'
   
   % Get handles
   hDisposalFig=gcbf;
   h=guidata(gcbo);
   
   strRunMode=popupstr(h.PopupMenuRunMode);
   
   switch strRunMode
      
   case 'single' % non-batch
      
      h=locSingleRun(h);
      
   case 'auto' % non-batch
      
      % Position at top of list
      set(h.ListboxDisposition,'val',1);
      
      % Auto step through disposition list
      while ~isempty(h.sDispositions)
         h=locSingleRun(h);
      end
      
   case {'pilot','batch'} % pilot/batch loop
      
      batchloop(gcbf);
      
      if strcmp(strRunMode,'batch')
         % Close diposal figure
         close(gcbf)
         return
      end
      
   otherwise
      strMsg=sprintf('unknown run mode %s',strRunMode);
      error(strMsg)
   end % switch strRunMode
   
   % Store the new disposition list
   guidata(gcbf,h)
   
case 'PushbuttonRunOld'
   
   warnmodal('OLD PLOT ROUTINES','SEE MATLAB COMMAND WINDOW');
   
   vibratorydisposal('PushbuttonAdd');
   
   h=guidata(gcbo);
   
   sDispositions=h.sDispositions(1);
   
   strComment=sDispositions.strComment;
   data=h.data;
   sHeader=h.sHeader;
   sSearch=h.sSearchCriteria;
   t=data(:,1);x=data(:,2);y=data(:,3);z=data(:,4);clear data
   t=86400*(t-t(1));
   fcstr=num2str(sHeader.CutoffFreq);
   fsstr=num2str(sHeader.SampleRate);
   sdnStart=sSearch.PathQualifiers.sdnStart;
   sdnEnd=sSearch.PathQualifiers.sdnEnd;
   strStart=['GMT ' popdatestr(sdnStart,0)];
   timename=strrep(strrep(strStart,':','_'),',','-');
   head=strrep(sHeader.SensorID,'_','\_');
   mission='mission';
   coord='Sensor Coordinates';
   ttl='ttl';
   timechoice='s';
   origmeanxstr=sprintf('%.4e',mean(x));
   origmeanystr=sprintf('%.4e',mean(y));
   origmeanzstr=sprintf('%.4e',mean(z));
   rmsxstr=sprintf('%.4e',rms(x));
   rmsystr=sprintf('%.4e',rms(y));
   rmszstr=sprintf('%.4e',rms(z));
   dg=0;
   
   ButtonName=questdlg('Want to demean?', ...
      'Demean Question', ...
      'Yes','No','Yes');
   
   switch ButtonName,
   case 'Yes', 
      
      plotdata(t,x-mean(x),y-mean(y),z-mean(z),dg,head,fcstr,fsstr,ttl,strStart,...
         origmeanxstr,origmeanystr,origmeanzstr,...
         rmsxstr,rmsystr,rmszstr,coord,mission);   
      
   case 'No',
      
      plotdata(t,x,y,z,dg,head,fcstr,fsstr,ttl,strStart,...
         origmeanxstr,origmeanystr,origmeanzstr,...
         rmsxstr,rmsystr,rmszstr,coord,mission);   
      
   end % switch ButtonName
   
   
   return
   
   save(['sams2-' head sprintf('_%.0f_%.0f',fix(header.TimeZero*1e9),fix(header.TimeEnd*1e9))]);
   
   % temp for sams2 looks here
   fs=header.SampleRate;
   strType='Signal';
   sX=sptool('create',strType,x,fs,'x');
   sX.lineinfo.color=[1 0 0];sX.lineinfo.linestyle='-';sX.lineinfo.columns=1;
   sptool('load',sX);
   sY=sptool('create',strType,y,fs,'y');
   sY.lineinfo.color=[0 0.5 0];sY.lineinfo.linestyle='-';sY.lineinfo.columns=1;
   sptool('load',sY);
   sZ=sptool('create',strType,z,fs,'z');
   sZ.lineinfo.color=[0 0 1];sZ.lineinfo.linestyle='-';sZ.lineinfo.columns=1;
   sptool('load',sZ);
   
   return
   
   nfft=flogtwo(length(x));
   window=nfft;
   noverlap=0;
   [pxx,f]=psdpims(x,nfft,fs,window,noverlap);
   pyy=psdpims(y,nfft,fs,window,noverlap);
   pzz=psdpims(z,nfft,fs,window,noverlap);
   
   clear sX sY sZ
   
   strType='Spectrum';
   sX=sptool('create',strType,pxx,f,'pxx');
   sX.lineinfo.color=[1 0 0];sX.lineinfo.linestyle='-';sX.lineinfo.columns=1;
   sptool('load',sX);
   sY=sptool('create',strType,pyy,f,'pyy');
   sY.lineinfo.color=[0 0.5 0];sY.lineinfo.linestyle='-';sY.lineinfo.columns=1;
   sptool('load',sY);
   sZ=sptool('create',strType,pzz,f,'pzz');
   sZ.lineinfo.color=[0 0 1];sZ.lineinfo.linestyle='-';sZ.lineinfo.columns=1;
   sptool('load',sZ);
   
   return
   
otherwise
   
   error('invalid action');
   
end %switch action

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locSingleRun(h);

% Remove the data and list entry for the selected value
[h,sDisposition]=vibratorydisposal('PushbuttonRemove');

% Perform disposition
%fprintf('\n%s\n',sDisposition.strCommand)
eval(sDisposition.strCommand)

% Copy to end of done list
h.sDone(end+1)=sDisposition;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locBatchDisposition(sDisposition);

% Perform disposition
fprintf('\n%s -%s-> %s\n',sDisposition.strPrettyCommand,sDisposition.sPlot.Colormap,sDisposition.strCommand)
%eval(sDispositions.strCommand)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locGuihandles(fig);
% NOTE: This should go away with (R12)'s guihandles.m function
h.EditTextComment=findobj(fig,'tag','EditTextComment');
h.FrameDispCoordSysType=findobj(fig,'tag','FrameDispCoordSys');
h.FrameOutputType=findobj(fig,'tag','FrameOutputType');
h.FramePlotType=findobj(fig,'tag','FramePlotType');
h.FrameDisposition=findobj(fig,'tag','FrameDisposition');
h.ListboxHeader=findobj(fig,'tag','ListboxHeader');
h.ListboxData=findobj(fig,'tag','ListboxData');
h.ListboxOutputParameters=findobj(fig,'tag','ListboxOutputParameters');
h.ListboxPlotParameters=findobj(fig,'tag','ListboxPlotParameters');
h.ListboxDisposition=findobj(fig,'tag','ListboxDisposition');
h.PopupMenuOutputType=findobj(fig,'tag','PopupMenuOutputType');
h.PopupMenuPlotType=findobj(fig,'tag','PopupMenuPlotType');
h.PopupMenuRunMode=findobj(fig,'tag','PopupMenuRunMode');
h.PushbuttonAdd=findobj(fig,'tag','PushbuttonAdd');
h.PushbuttonEditPlotParameters=findobj(fig,'tag','PushbuttonEditPlotParameters');
h.PushbuttonRemove=findobj(fig,'tag','PushbuttonRemove');
h.PushbuttonRun=findobj(fig,'tag','PushbuttonRun');
h.PushbuttonUpload=findobj(fig,'tag','PushbuttonUpload');
h.StaticTextComment=findobj(fig,'tag','StaticTextComment');
h.StaticTextHeader=findobj(fig,'tag','StaticTextHeader');
h.StaticTextData=findobj(fig,'tag','StaticTextData');
h.StaticTextOutputType=findobj(fig,'tag','StaticTextOutputType');
h.StaticTextPlotType=findobj(fig,'tag','StaticTextPlotType');
h.StaticTextRunMode=findobj(fig,'tag','StaticTextRunMode');
h.StaticTextDisposition=findobj(fig,'tag','StaticTextDisposition');

%within disposal gui, there should an "Edit" pushbutton tied to editing plot and output
%parameters, so callback to switchyard for editor gui that gets executed when this button
%is pushed should be named:
%
%editPlotType.m
%
%where PlotType is, for example, spectrogram (editspectrogram.m); this handles logic for
%allowable parameter ranges (min, max, saturation, fullness, and so on)
%
%ultimately, when an entry in disposition list is "Run", these should be the routines to
%transform and further process the acceleration data to produce output of some form.
%This function should be named:
%
%PlotType.m
%
%so for the previous example, spectrogram.m will do any necessary transformations and
%produce the output as specified by the output parameters
%
%[hFig,hAx,hText]=spectrogram([],hDisposalFig,sParameters); % Underlying disposition list call from disposal gui
%                                                           % which gets "pretty printed" like this:
%                                                           % spectrogram TO screen IN coordinates, comment
%                                                           % PlotType TO OutputType IN CoordinateSystem, casComments{1}
%
%or
%
%[hFig,hAx,hText]=spectrogram(data,sHeader,sParameters,varargin); % command line usage; data and header should comply 
%                                                                 % with PAD system
%
%sParameters
% 	.sPlot
% 		.plotparameter1
% 		.plotparameter2
%     :
% 	.sOutput
% 		.outputparameter1
% 		.outputparameter2
%     :
% 	.casComments
