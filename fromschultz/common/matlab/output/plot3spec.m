function [textt,hmetstart,anch,ax1,ax2,ax3,cax1,cax2,cax3]=plot_3spec(...
			t,x,y,z,fcstr,fsstr,timechoice,timestartstr,head,mission,...
			coord,ttl,windchoice,wstr,nfft,noverlap,cmstr,maxf,clim,fig)
			
% Setup axes	
	[ax1,ax2,ax3]=plot_setupaxes_3tall(fig);

% Set fc and fs
	fc=str2num(fcstr);
	fs=str2num(fsstr);
	
% Set timechoice
	if timechoice=='m'
		t=t/60;
		timelabel='minutes';
	elseif timechoice=='h'
		t=t/3600;
		timelabel='hours';
	else
		timelabel='seconds';
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
		ind=find(F<=maxf);
		themin=min(min([Bx(ind,:) By(ind,:) Bz(ind,:)]));
		themax=max(max([Bx(ind,:) By(ind,:) Bz(ind,:)]));
		clim=log10([themin themax]);
	end
	
% Determine number of spectral averages
	navgs=num2str(fix((length(x)-noverlap)/(length(window)-noverlap)));
	
% Fix the times
	dT=T(2)-T(1);
	if timechoice=='m'
		T=T/60;
	elseif timechoice=='h'
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
	axis([0 max(T) 0 maxf])
	
	axes(ax2),imagesc(T,F,log10(By),clim),axis xy
	cax2=colorbarpims;
	ht2=text(5.75+4/64,1.325,'Y-Axis PSD Magnitude [log_{10}(g^2/Hz)]',...
		'unit','inch','fontsize',9,'rotation',90,'horiz','center',...
		'vert','mid','fontname','times');
	set(ax2,'xticklabel',[])
	ylabel('Frequency (Hz)');
	axis([0 max(T) 0 maxf])

	axes(ax3),imagesc(T,F,log10(Bz),clim),axis xy
	cax3=colorbarpims;
	ht3=text(5.75+4/64,1.325,'Z-Axis PSD Magnitude [log_{10}(g^2/Hz)]',...
		'unit','inch','fontsize',9,'rotation',90,'horiz','center',...
		'vert','mid','fontname','times');
	ylabel('Frequency (Hz)')
	xlabel(['Time (' timelabel ')'])
	axis([0 max(T) 0 maxf])
	
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
	textt=text(4.25,10.25,ttl,'horiz','center','vertical','middle',...
			'fontname','times','unit','inch');
			
	hmetstart=text(4.25,10.08,[timestartstr ' (' wstr ', k=' navgs ')'],...
				'horiz','center','vertical','middle',...
				'fontname','times','unit','inch');
	
% Fix to normalized and outside ticks
	set([ax1 ax2 ax3],'tickdir','out');
	set([ax1 ax2 ax3 cax1 cax2 cax3 axt textt...
		ht1 ht2 ht3 hmetstart],'unit','normalized')

% The ancillary headers
	totalT=sprintf('%0.1f %s',t(end)-t(1),timelabel);
	dF=sprintf('df=%0.4f Hz',F(2)-F(1));
	dT=sprintf('dT=%0.4f seconds',dT);
	anch=ancillarytext('t',head,fcstr,fsstr,dF,dT,mission,coord,totalT,'');