function spectrogrambat;

% Get results path
s=get(0,'UserData');
if isfield(s,'sUser')
   s=s.sUser;
   strResultsPath=s.ResultsPath;
else
   fprintf('\nno sUser in root''s UserData, so start at pwd')
   strResultsPath=pwd;
end

% Dialog for info filename to work from
[strInfoFilename,strPathName]=uigetfile([strResultsPath '*info.mat'], 'spectrogrambat');
strInfoFilename=[strPathName strInfoFilename];

% Load info mat-file
load(strInfoFilename);
strBasepath=sOutput.ResultsPath;
strComment=sText.strComment;

% Get list of filenames
[casFiles,sDetails]=dirdeal([strPathName '*.mat']);
if ~isempty(sDetails)
   strPath=sDetails(1).pathstr;
   casFiles=strcat(strPath,casFiles);
else
   error('details structure is empty?')
end

% Weed out info and hist files
ii=strmatch(strInfoFilename,casFiles);
if ~isempty(ii), casFiles(ii)=[]; sDetails(ii)=[]; end

strHistFilename=strrep(strInfoFilename,'info','hist');
ih=strmatch(strHistFilename,casFiles);
if ~isempty(ih), casFiles(ih)=[]; sDetails(ih)=[]; end

% Sort rest of list
casFiles=sort(casFiles);

% Loop for concatenate & plot
numPlot=1;
index=1:numCat;
for iPlot=1:length(casFiles)/numCat
   %fprintf('\nplot #%d will be with mat-files:',numPlot)
   B=[];
   T=[];
   for j=1:numCat
      strFilename=casFiles{index(j)};
      %fprintf('\n%d: %s',j,strFilename)
      load(strFilename)
      B=[B b];
      T=[T t];
   end
   if iPlot==1
      if ~exist([strTrunk 'hist.mat'])
         CLim=[-13 -5];
      else
         % Choose color limit
         CLim=selectcolorlim([strTrunk 'hist.mat']);
      end
   end
   % Make time relative seconds
   t=T-T(1); % days
   t=double(convert(t*units('days'),sPlot.TUnits));
   strSpan=sprintf('Span = %.2f %s',t(end),sPlot.TUnits);
   
   % Use start time for this image
   sdnPlotStart=T(1);
   strTimeFormat=sSearch.PathQualifiers.strTimeFormat;
   strTimeBase=sSearch.PathQualifiers.strTimeBase;
   sText.strTitle=[strTimeBase ' ' popdatestr(sdnPlotStart,sSearch.PathQualifiers.strTimeFormat)];
   clear T
   
   % Spectrogram-specific text
   numPSDs=nCols(B);
   strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
   sText.casUR{3}={sprintf('%s, k = %g',strWindow,numPSDs)};
   sText.casUR{4}={strSpan}; 
   
   % Plot this image
   sHandles=plotgenspec(t,f,B,sText,sOutput.Type,[],CLim);
   
   if iPlot==1
      % Choose time limit and ticks for all plots in batch
      oldTLim=get(gca,'xlim');
      oldTTicks=get(gca,'xtick');
      [TLim,tTicks]=limtickdlg(oldTLim,oldTTicks);
   end
   colormap(sPlot.Colormap);
   set(sHandles.AxesALL,'ylim',sPlot.FLim);
   set(sHandles.AxesALL,'xlim',TLim);
   set(sHandles.AxesALL,'xtick',tTicks);
   
   switch sPlot.TTickLabelMode
   case 'relative'
      % as-is should work?
   case 'dateaxis'
      sHeader.sdnDataStart=sdnPlotStart;
      batdateaxis(t,sHandles,sHeader,sPlot);
   otherwise
      error('unknown TTickLabelMode')
   end
   
   % Print Encapsulated PostScript file
   strExt='eps';
   strSubDir=[strExt filesep];
   strImageFilename=genimgfilename(strComment,sHeader.SensorID,'spg',sPlot.WhichAx,'c',iPlot,strExt);
   strPath=[strPathName strSubDir];
   if ~exist(strPath)
      [statusVal,strMsg]=pimsmkdir(strPath);
      if ~isempty(strMsg)
         fprintf('\npimsmkdir message for %s: %s\n',strPath,strMsg)
      end      
   end
   set(gcf,...
      'PaperPositionMode' , 'manual',...
      'PaperUnits','inches',...
      'PaperOrientation' , 'portrait',...
      'PaperPosition' , [0.25 2.40711 8 6.18577],...
      'PaperType' , 'usletter');
   print('-depsc','-tiff','-r600',[strPath strImageFilename])
   %close(gcf);
   
   index=index+numCat;
   
end