function [image,ax1,ax2,cbax]=cumpcsadensity(x,y,i)

% This function is used to produce cumulative PCSA density plots

% User inputs
	disp('Please choose a method for colorbar configuration:')
	option=textmenu('Color represents percentage at bin and BELOW',...
					'Color represents percentage at bin and ABOVE');
	cmstr=pscolormap;
	ax=input('Axis limits ([xmin xmax ymin ymax]): ');
	ttl=input('Plot title: ','s');
	global VER
					
% Computations
	cum=cumsum(i);
	sums=sum(i);
	image=(cum*diag(1./sums))*100;
	if option==2
		image=100-image;
	end
	
% Do the plot
	clf;
	imagesc(x,y,image,[0 100]);
	orient landscape
	set(gcf,'paperposition',[.25 .125 10.5 7.75]);
	ax1=gca;
	axis xy
	set(gca,'fontname','times');
	cbax=colorbarpims;
	eval(['colormap ' cmstr])
	if option==1
		set(get(cbax,'ylabel'),'string','Cumulative Detected Percentage (at bin and below)','fontname','times');
	elseif option==2
		set(get(cbax,'ylabel'),'string','Cumulative Detected Percentage (at bin and above)','fontname','times');	
	end
	set(ax1,'visible','off');
	axis([ax(1) ax(2) log10(ax(3)) log10(ax(4))]);
	pos=get(ax1,'position');
	ax2=axes;
	set(ax2,'yscale','log','box','on','tickdir','out');
	axis(ax);	
	set(ax2,'position',pos);
	set(gca,'fontname','times')
	xlabel('Frequency (Hz)')
	title(ttl);
	if VER==4
		sylabel('\t PSD Value (g^2/Hz)');
	elseif VER==5
		ylabel('PSD Value (g^2/Hz)','fontname','times');
	end	
