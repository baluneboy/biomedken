function [textt,hmetstart,cblabel,anch,ax1,cax1]=plot1spec(t,f,data,fc,fs,...
			timechoice,timestartstr,head,mission,coord,ttl,...
			strWhichAx,window,strWin,Nfft,No,strColormap,maxf,clim,fig);

% Setup axes	
	ax1=plotsetupaxes1land(fig);
	
% Set timechoice
	if timechoice=='minutes'
		t=t/60;
	elseif timechoice=='hours'
      t=t/3600;
   end
   timelabel=timechoice;
   
% Determine the clim to use
	if isempty(clim)
		ind=find(f<=maxf);
		themin=min(min(data(ind,:)));
		themax=max(max(data(ind,:)));
		clim=log10([themin themax]);
	end

% Determine number of spectral averages
	numPSDs='numPSDs';%num2str(fix((length(x)-No)/(length(window)-No)));
	
% Fix the times
	dT=t(2)-t(1);
	if timechoice=='m'
		t=t/60;
	elseif timechoice=='h'
		t=t/3600;
	end

% Do the plot
	axes(ax1)
	him=imagesc(t,f,log10(data),clim);axis xy
	set(him,'tag',['PIMS_plot1spec_' ttl])
	cax1=colorbarpims;
	axis([0 max(t) 0 maxf])
	xlabel(['Time (' timelabel ')'])
	ylabel('Frequency (Hz)')
	set(ax1,'tickdir','out')
	
% Fix the axes sizes
	set(ax1,'unit','inch','position',[0.75 0.65 8.6225 7.00]);
	set(cax1,'unit','inch','position',[9.8475 0.65 0.4625 7.00]);
	
% Set the colorbar scheme
	colormap(strColormap)

% Put on the colorbar label
	axes(ax1)
	cblabel=text(8.9,3.5,[strWhichAx ' PSD Magnitude [log_{10}(g^2/Hz)]'],...
		'fontname','times','fontsize',12,'unit','inch','rotation',...
		90,'horiz','center','verti','mid');
		
% Put on the title
	axttl=axes;
	set(axttl,'unit','inch','position',[0 0 11 8.5],'fontname','times')
	axis off
	textt=text(5.5,8,ttl,'unit','inch','horiz','center','vert','bottom','fontname','times');
	metstartstr=[timestartstr ' (' strWin ', k=' numPSDs ')'];
	hmetstart=text(5.5,7.83,metstartstr,'unit','inch','horiz','center','vert',...
			'bottom','fontname','times');
	set([textt hmetstart axttl ax1 cax1 cblabel],'unit','norm')
	
% The ancillary headers
	totalT=sprintf('%0.1f %s',t(end)-t(1),timelabel);
	dF=sprintf('df=%0.4f Hz',f(2)-f(1));
	dT=sprintf('dT=%0.4f seconds',dT);
	anch=ancillarytext('l',head,num2str(fc),num2str(fs),dF,dT,mission,coord,totalT,'');

% Fix the axes back to the data
axes(ax1)
