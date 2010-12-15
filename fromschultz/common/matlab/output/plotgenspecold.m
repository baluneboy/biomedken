function sHandles=plotgenspecold(t,f,b,sText,sReport,strColormap,fmax,clim); %(t,f,b,sText,sReport,fc,fs,strWhichAx,Nfft,No,window,strWin,strColormap,fmax,clim);

%        t - vector of time
%        f - vector of frequency
%        b - matrix of PSD values (or matrices of PSDs)
%        sText - structure of text with fields 
%           .strXUnits - string for time units (like 'minutes')
%           .casYStub - cas for ylabel(s) (like {'Sum'}) or
%                 {'X-Axis','Y-Axis','Z-Axis'}
%           .casUL - cell array of strings for upper left text
%           .casUR - cell array of strings for upper right text
%           .strComment - string for comment
%           .strTitle - string for title of top axes
%           .strVersion - string for offline version control
%           .casRS - cell array of strings for rotated, rightside text
%        strOutType - string for output type
%        sReport - structure of report text with fields 
%           .strTitle - string for report title at top
%           .numPage - scalar for page number in caption at bottom
%           .numFig - scalar for figure number in caption
%           .strCaption - string for figure caption
%
%Outputs: sHandles - structure of handles

%Author: Ken Hrovat, 2/26/2001
% $Id: plotgenspecold.m 4160 2009-12-11 19:10:14Z khrovat $

strXUnits=sText.strXUnits;
strComment=sText.strComment;
casUL=sText.casUL;
casUR=sText.casUR;
strTitle=sText.strTitle;
strVersion=sText.strVersion;

fig=figure;

if ndims(b)==2
   numAx=1;
else
   numAx=size(b,3);
end

sReport=[];
[sTextPosition,sFigure]=figtextsettings(numAx,sReport);

if numAx==1
   
   strSuffix='11';
   
   % Setup axes	
   h.Axes=plotsetupaxes1land(fig);
   
   % Set strXUnits
   if strXUnits=='minutes'
      t=t/60;
   elseif strXUnits=='hours'
      t=t/3600;
   end
   strXUnits=strXUnits;
   
   % Determine the clim to use
   if isempty(clim)
      ind=find(f<=fmax);
      themin=min(min(b(ind,:)));
      themax=max(max(b(ind,:)));
      clim=log10([themin themax]);
   end
   
   % Fix the times
   dT=t(2)-t(1);
   if strcmp(strXUnits,'minutes')
      t=t/60;
   elseif strcmp(strXUnits,'hours')
      t=t/3600;
   end
   
   % Do the plot
   axes(h.Axes)
   him=imagesc(t,f,log10(b),clim);axis xy
   set(him,'tag',['PIMS_plot1spec_' strTitle])
   h.AxesColorbar=colorbarpims;
   axis([0 max(t) 0 fmax])
   %xlabel(['Time (' strXUnits ')'])
   %ylabel('Frequency (Hz)')
   set(h.Axes,'tickdir','out')
   
   % Fix the axes sizes
   set(h.Axes,'unit','inch','position',[0.75 0.65 8.6225 7.00]);
   set(h.AxesColorbar,'unit','inch','position',[9.8475 0.65 0.4625 7.00]);
   
   % Set the colorbar scheme
   colormap(strColormap)
   
   % Put on the colorbar label
   axes(h.Axes)
   cblabel=text(8.9,3.5,[sText.casYStub{1} ' PSD Magnitude [log_{  10}(g^2/Hz)]'],...
      'fontname','times','fontsize',12,'unit','inch','rotation',...
      90,'horiz','center','verti','mid');
   
   % If bottom axes, then add XLabel & Version
   h=bottomxlabtext(h,h.Axes,sTextPosition.xyzVersion,sText);
   
   % If top axes, then add Title & Upper text
   h=uppertitletext(h,h.Axes,sTextPosition,sFigure,sText);
   
   % Insert frequency YLabel
   hy=ylabel('Frequency (Hz)');
   strYLabelTag=['TextYLabel' strSuffix];
   h=setfield(h,strYLabelTag,hy);
   
   % Fix the axes back to the data
   axes(h.Axes)
   
else
   
   % Setup axes	
   [ax1,ax2,ax3]=plot_setupaxes_3tall(fig);
   
   % Set fc and fs
   fc=str2num(fcstr);
   fs=str2num(fsstr);
   
   % Set strXUnits
   if strXUnits=='m'
      t=t/60;
      strXUnits='minutes';
   elseif strXUnits=='h'
      t=t/3600;
      strXUnits='hours';
   else
      strXUnits='seconds';
   end
   
   % Zero-out the time
   t=t-t(1);
   
   % Generate the spectral window
   window=pswindowgen(windchoice,nfft);
   
   % Compute the Spectrograms
   disp('Calculating the Spectrograms...')
   [Bx,F,T]=specgrampims(x,nfft,fs,window,noverlap);
   By=specgrampims(y,nfft,fs,window,noverlap);
   Bz=specgrampims(z,nfft,fs,window,noverlap);
   
   % Determine the clim to use
   if isempty(clim)
      ind=find(F<=fmax);
      themin=min(min([Bx(ind,:) By(ind,:) Bz(ind,:)]));
      themax=max(max([Bx(ind,:) By(ind,:) Bz(ind,:)]));
      clim=log10([themin themax]);
   end
   
   % Determine number of spectral averages
   navgs=num2str(fix((length(x)-noverlap)/(length(window)-noverlap)));
   
   % Fix the times
   dT=T(2)-T(1);
   if strXUnits=='m'
      T=T/60;
   elseif strXUnits=='h'
      T=T/3600;
   end
   
   % Do the plots
   axes(ax1),imagesc(T,F,log10(Bx),clim),axis xy
   cax1=colorbarpims;
   ht1=text(5.75+4/64,1.325,'X-Axis PSD Magnitude [log_{10}(g^2/Hz)]',...
      'unit','inch','fontsize',9,'rotation',90,'horiz','center',...
      'vert','mid','fontname','times');
   set(ax1,'xticklabel',[])
   ylabel('Frequency (Hz)')
   axis([0 max(T) 0 fmax])
   
   axes(ax2),imagesc(T,F,log10(By),clim),axis xy
   cax2=colorbarpims;
   ht2=text(5.75+4/64,1.325,'Y-Axis PSD Magnitude [log_{10}(g^2/Hz)]',...
      'unit','inch','fontsize',9,'rotation',90,'horiz','center',...
      'vert','mid','fontname','times');
   set(ax2,'xticklabel',[])
   ylabel('Frequency (Hz)');
   axis([0 max(T) 0 fmax])
   
   axes(ax3),imagesc(T,F,log10(Bz),clim),axis xy
   cax3=colorbarpims;
   ht3=text(5.75+4/64,1.325,'Z-Axis PSD Magnitude [log_{10}(g^2/Hz)]',...
      'unit','inch','fontsize',9,'rotation',90,'horiz','center',...
      'vert','mid','fontname','times');
   ylabel('Frequency (Hz)')
   xlabel(['Time (' strXUnits ')'])
   axis([0 max(T) 0 fmax])
   
   % Fix the axes
   set([ax1 ax2 ax3],'fontname','times','box','on','unit','inch',...
      'tickdir','out')
   set([cax1 cax2 cax3],'unit','inch')
   set(ax1,'position',get(ax1,'position')+[-0.25 0 0.50 0])
   set(ax2,'position',get(ax2,'position')+[-0.25 0 0.50 0])
   set(ax3,'position',get(ax3,'position')+[-0.25 0 0.50 0])
   set(cax1,'position',get(cax1,'position')+[0.25 0 0 0])
   set(cax2,'position',get(cax2,'position')+[0.25 0 0 0])
   set(cax3,'position',get(cax3,'position')+[0.25 0 0 0])
   set(ht1,'position',get(ht1,'position')+[0.75 0 0])
   set(ht2,'position',get(ht2,'position')+[0.75 0 0])
   set(ht3,'position',get(ht3,'position')+[0.75 0 0])
   
   % Set the color scheme
   colormap(cmstr)
   
   % The plot labels
   axt=axes;
   set(axt,'unit','inches','position',[0 0 8.5 11])
   axis off
   textt=text(4.25,10.25,strTitle,'horiz','center','vertical','middle',...
      'fontname','times','unit','inch');
   
   hmetstart=text(4.25,10.08,[strTitle ' (' wstr ', k=' navgs ')'],...
      'horiz','center','vertical','middle',...
      'fontname','times','unit','inch');
   
   % Fix to normalized and outside ticks
   set([ax1 ax2 ax3],'tickdir','out');
   set([ax1 ax2 ax3 cax1 cax2 cax3 axt textt...
         ht1 ht2 ht3 hmetstart],'unit','normalized')
      
      % The ancillary headers
      totalT=sprintf('%0.1f %s',t(end)-t(1),strXUnits);
      dF=sprintf('df=%0.4f Hz',F(2)-F(1));
      dT=sprintf('dT=%0.4f seconds',dT);
      anch=ancillarytext('t',head,fcstr,fsstr,dF,dT,mission,coord,totalT,'');
      
      
   end
   