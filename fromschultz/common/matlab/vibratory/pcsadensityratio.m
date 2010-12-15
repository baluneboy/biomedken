function [image,ax1,ax2,colorbarax]=pcsadensityratio(x,y,i1,i2)

% This function is used to compute and plot the PCSA density ratio.
% The input image (i) matrices will be normalized by this function.  This
% normalization will be performed by dividing the i-matrices by the number
% of periods which were used to make each matrix.  (The program will prompt
% the user for this information).  Usage of this function is:
%		[image,ax1,ax2,colorbarax]=pcsadensityratio(x,y,i1,i2)

% User questions
	n1=input('Number of time slices used to make image matrix 1: ');
	n2=input('Number of time slices used to make image matirx 2: ');
	ttl=input('Title for the plot: ','s');
	ax=input('Axes limits ([xmin xmax ymin ymax]): ');
	global VER
	
% Normalize the matrices
	i1=i1./n1;
	i2=i2./n2;
	
% Cookie-cut out the zeros, and determine the image
	zerosnum=i1==0;
	zerosden=i2==0;
	zerosunion=zerosnum&zerosden;
	ind=find(zerosunion==1);
	i1(ind)=ones(size(ind));
	i2(ind)=ones(size(ind));
	image=i1./i2;
	
% Plot the picture
	imagesc(x,y,image,[0 2]);
	axis xy
	orient landscape
	colormap(greenred)
	set(gca,'visible','off');
	ax1=gca;
	axis([ax(1) ax(2) log10(ax(3)) log10(ax(4))])
	colorbarax=colorbarpims;
	ax2=axes;
	set(ax2,'fontname','times','box','on','tickdir','out','yscale','log',...
			'position',get(ax1,'position'));
	axis(ax)
	xlabel('Frequency (Hz)')
	if VER==4
		sylabel('\t PSD Value (g^2/Hz)')
	elseif VER==5
		ylabel('PSD Value (g^2/Hz)','fontname','times')
	end
	title(ttl)
	set(get(colorbarax,'ylabel'),'string','Ratio of normalized PCSA Density',...
			'fontname','times')
	
