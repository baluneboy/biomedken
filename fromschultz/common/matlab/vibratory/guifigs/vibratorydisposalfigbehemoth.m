function fig = vibratorydisposalfigra()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

load vibratorydisposalfigra

h0 = figure('Units','characters', ...
	'Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'FileName','S:\develop\matlab\programs\vibratory\guifigs\vibratorydisposalfigra.m', ...
	'HandleVisibility','off', ...
	'Name','VD, start to end, location, fc Hz (fs s/sec), data type', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',[15.6 29.92307692307692 222.6 43], ...
	'Tag','vibratorydisposal', ...
	'ToolBar','none', ...
	'UserData','[ ]');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.415686274509804 0.709803921568627 0.709803921568627], ...
	'ListboxTop',0, ...
	'Position',mat1, ...
	'Style','frame', ...
	'Tag','FramePlotOutputParameters');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 0.501960784313725], ...
	'ListboxTop',0, ...
	'Position',mat2, ...
	'Style','frame', ...
	'Tag','FrameDispCoordSys');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',mat3, ...
	'Style','frame', ...
	'Tag','FrameDisposition');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[22.6 2.230769230769231 158.2 8], ...
	'Style','listbox', ...
	'Tag','ListboxDisposition', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[88 10.53846153846154 43.2 1.461538461538462], ...
	'String','Disposition', ...
	'Style','text', ...
	'Tag','StaticTextDisposition');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[39 31 162 5], ...
	'String','no header', ...
	'Style','listbox', ...
	'Tag','ListboxHeader', ...
	'UserData','[ ]', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonRemove'')', ...
	'ListboxTop',0, ...
	'Position',mat4, ...
	'String','Remove', ...
	'Tag','PushbuttonRemove');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','vibratorydisposal(''PopupMenuRunMode'')', ...
	'ListboxTop',0, ...
	'Position',[183.8 8.769230769230768 14.4 1.846153846153846], ...
	'String',mat5, ...
	'Style','popupmenu', ...
	'Tag','PopupMenuRunMode', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[39 29 162 2], ...
	'String','no comment', ...
	'Style','edit', ...
	'Tag','EditTextComment');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontWeight','bold', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[21.6 29.07692307692308 16 1.307692307692308], ...
	'String','COMMENT:', ...
	'Style','text', ...
	'Tag','StaticTextComment');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontWeight','bold', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[21.6 32.46153846153846 16 1.307692307692308], ...
	'String','HEADER:', ...
	'Style','text', ...
	'Tag','StaticTextHeader', ...
	'UserData','[ ]');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[183.8 10.76923076923077 14 1.307692307692308], ...
	'String','Run Mode:', ...
	'Style','text', ...
	'Tag','StaticTextRunMode');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonView'')', ...
	'ListboxTop',0, ...
	'Position',mat6, ...
	'String','View', ...
	'Tag','PushbuttonView');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonRun'')', ...
	'ListboxTop',0, ...
	'Position',mat7, ...
	'String','Run', ...
	'Tag','PushbuttonRun');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0.501960784313725], ...
	'ListboxTop',0, ...
	'Position',mat8, ...
	'Style','frame', ...
	'Tag','FramePlot');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.501960784313725 1 0.501960784313725], ...
	'ListboxTop',0, ...
	'Position',mat9, ...
	'Style','frame', ...
	'Tag','FrameOutput');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PopupMenuPlotType'')', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Position',mat10, ...
	'String',mat11, ...
	'Style','popupmenu', ...
	'Tag','PopupMenuPlotType', ...
	'Value',6);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[71.2 13.23076923076923 51.6 10.53846153846154], ...
	'Style','listbox', ...
	'Tag','ListboxPlotParameters', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0.501960784313725], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[73.8 26.38461538461539 29.6 1.461538461538462], ...
	'String','Plot Type', ...
	'Style','text', ...
	'Tag','StaticTextPlotType');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.501960784313725 1 0.501960784313725], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[32.2 26.23076923076923 29.6 1.461538461538462], ...
	'String','Output Type', ...
	'Style','text', ...
	'Tag','StaticTextOutputType');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[21.6 13.23076923076923 47 10.53846153846154], ...
	'Style','listbox', ...
	'Tag','ListboxOutputParameters', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PopupMenuOutputType'')', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Position',mat12, ...
	'String',mat13, ...
	'Style','popupmenu', ...
	'Tag','PopupMenuOutputType', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonEditPlotParameters'')', ...
	'ListboxTop',0, ...
	'Position',[113.2 26.38461538461539 9.800000000000001 1.461538461538462], ...
	'String','Edit', ...
	'Tag','PushbuttonEditPlotParams');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonAdd'')', ...
	'ListboxTop',0, ...
	'Position',mat14, ...
	'String','Add', ...
	'Tag','PushbuttonAdd');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontWeight','bold', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[21.4 37.69230769230769 16 1.307692307692308], ...
	'String','DATA:', ...
	'Style','text', ...
	'Tag','StaticTextData', ...
	'UserData','[ ]');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[39 36 162 5], ...
	'String','no data', ...
	'Style','listbox', ...
	'Tag','ListboxData', ...
	'UserData','[ ]', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PopupMenuDispCoordSysType'',gcbf)', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Position',mat15, ...
	'String','sample', ...
	'Style','popupmenu', ...
	'Tag','PopupMenuDispCoordSysType', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','courier', ...
	'FontSize',9, ...
	'Position',[143.8 13.2307692307692 47 10.5384615384615], ...
	'Style','listbox', ...
	'Tag','ListboxDispCoordSysParams', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 0.501960784313725], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[144.8 26.23076923076923 33 1.461538461538462], ...
	'String','Display Coordinate System', ...
	'Style','text', ...
	'Tag','StaticTextDispCoordSys');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 0.501960784313725 0], ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[185.4 4.307692307692308 12 1.538461538461538], ...
	'String','Pilot #', ...
	'Style','text', ...
	'Tag','StaticTextPilotNumber');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','vibratorydisposal(''EditTextPilotNumber'')', ...
	'ListboxTop',0, ...
	'Position',mat16, ...
	'String','5', ...
	'Style','edit', ...
	'Tag','EditTextPilotNumber');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonEditOutputParameters'')', ...
	'ListboxTop',0, ...
	'Position',[59 26.4615384615385 9.800000000000001 1.46153846153846], ...
	'String','Edit', ...
	'Tag','PushbuttonEditOutputParams');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonDispCoordSys'')', ...
	'ListboxTop',0, ...
	'Position',[179.2 26.30769230769231 9.800000000000001 1.461538461538462], ...
	'String','Edit', ...
	'Tag','PushbuttonDispCoordSys');
h1 = uicontrol('Parent',h0, ...
	'Units','characters', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','vibratorydisposal(''PushbuttonTransformInPlace'')', ...
	'ListboxTop',0, ...
	'Position',[179.2 24.46153846153846 9.800000000000001 1.461538461538462], ...
	'String','Transform', ...
	'Tag','PushbuttonTransInPlace');
if nargout > 0, fig = h0; end
