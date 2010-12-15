function gvtbat;

% Incorporate info like approximate time span
% casRS to show breakdown for x,y,z
% casUR{1}=sprintf('Total: %d data points',inf);
% casUR{2}=sprintf('Time span: %g UNITS',inf);

% Dialog for info filename to work from
[strHistFilename,strPathName]=uigetfile('T:\offline\matlab\results\inc02\121f06\gvt\*hist.mat', 'dialogTitle');
strHistFilename=[strPathName strHistFilename];
strInfoFilename=strrep(strHistFilename,'hist','info');
strStatFilename=strrep(strHistFilename,'hist','stat');

% Load info mat-file
load(strInfoFilename);
strBasepath=sOutput.ResultsPath;
strComment=sText.strComment;

% Load hist mat-file
load(strHistFilename);

% Verify same totals for all columns of counts
if any(diff(sum(histN)))
   error('different totals for columns of counts')
end

% Calculate cumulative sum of counts
totalCount=sum(histN(:,1));
histPercent=100*histN/totalCount;
[mags,cumulativeSums]=histcumsum(histEdges,histPercent);
sText.casUR{3}=sprintf('Total: %d samples',totalCount);

% Plot histograms
numHist=nCols(histN);
sHandlesHist=plotgen2d(histEdges,histN(:,1),sText,sOutput.Type,[]); hold on
sHandlesHist.Line11c1=sHandlesHist.Line11;
sHandlesHist=rmfield(sHandlesHist,'Line11');
set(sHandlesHist.Line11c1,'color','r','tag','Line11c1');
for i=2:numHist
   lineColor=[0 0 0];lineColor(i)=1;
   hLine=plot(histEdges,histN(:,i)); hold on
   set(hLine,'color',lineColor);
   set(hLine,'tag',sprintf('Line11c%d',i));
   sHandlesHist=setfield(sHandlesHist,sprintf('Line11c%d',i),hLine);
end
strGUnits=texunits(sHeader.GUnits);
xlabel(sprintf('Acceleration (%s)',strGUnits))
ylabel('Number of Occurrences')
hText111=findobj(gcf,'tag','TextSide111');
hText112=findobj(gcf,'tag','TextSide112');
hold off

% Auto axes
countLim=1.1*max(histN(:));
axis([-50 50 0 countLim])

% Plot cumulative percentages
sHandlesPercent=plotgen2d(mags,cumulativeSums(:,1),sText,sOutput.Type,[]); hold on
ind=locGet95(cumulativeSums(:,1),95);
mag95(1,1)=mags(ind);
str95=sprintf('%0.2f',mag95(1,1));
sHandlesPercent.Line11c1=sHandlesPercent.Line11;
sHandlesPercent=rmfield(sHandlesPercent,'Line11');
set(sHandlesPercent.Line11c1,'color','r','tag','Line11c1');
for i=2:numHist
   lineColor=[0 0 0];lineColor(i)=1;
   hLine=plot(mags,cumulativeSums(:,i)); hold on
   set(hLine,'color',lineColor);
   set(hLine,'tag',sprintf('Line11c%d',i));
   sHandlesPercent=setfield(sHandlesPercent,sprintf('Line11c%d',i),hLine);
   ind=locGet95(cumulativeSums(:,i),95);
   mag95(1,i)=mags(ind);
   str95=strcat(str95,sprintf(', %0.2f',mag95(1,i)));
end
strGUnits=texunits(sHeader.GUnits);
xlabel(sprintf('Acceleration (%s)',strGUnits))
ylabel('Peak Percentage (%)')
hold off

% Axis limits
magLim=1.1*max(mag95);
axis([0 magLim 0 100])

% Load stat mat-file
load(strStatFilename);

% Verify same totals for all columns of intervalCount
if any(diff(sum(intervalCount)))
   error('different totals for columns of intervalCount')
end

% Calculate grand sum & overall mean
grandSum=sum(intervalCount.*intervalMean);
overallMean=grandSum/sum(intervalCount(:,1));

% Add side text stats
set([hText111 findobj(gcf,'tag','TextSide111')],'str',sprintf('95th Percentile: %s %s',str95,strGUnits))
strFormat=['Overall Original Mean: %0.2f' repmat(', %0.2f',1,nCols(overallMean)-1) ' %s'];
set([hText112 findobj(gcf,'tag','TextSide112')],'str',sprintf(strFormat,overallMean,strGUnits))

return

% Print Encapsulated PostScript file
strExt='eps';
strSubDir=[strExt filesep];
strImageFilename=genimgfilename(strComment,sHeader.SensorID,'his',sPlot.WhichAx,'c',iPlot,strExt);
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
close(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind=locGet95(cs,p);
ind=find(cs>=p);
ind=ind(1);
