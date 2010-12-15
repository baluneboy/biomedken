function [clim,fig1,fig2] = detclim(bins, bhist, thresh, whole, mode)

% DETCLIM - Function to determine color limit range from histogram of
%           spectrogram magnitudes.
%
% clim = detclim(bins, bhist, thresh, whole, mode);
%
% Inputs: bins - vector of bin values
%         bhist - vector of histogram values
%         thresh - scalar percentage of points to consider
%                  if thresh is empty, then use all points
%         whole - scalar that equals 1 if whole numbers are
%                 desired for clim, otherwise, clim is real
%         mode - string for mode of operation; either 'auto' for
%                auto mode or something else for 'interactive' mode
%
% Outputs: clim - recommended values for [clow, chigh]

% written by: Ken Hrovat on 12/20/95
% $Id: detclim.m 4160 2009-12-11 19:10:14Z khrovat $

% 1. Verify i/o count
% 2. Determine percentage of points in each magnitude bin
% 3. Use threshold to chop off left and right tails and
%    determine clow and chigh from tails to give clim


% 1. Verify i/o count

if ( nargin~=5 )
	error('DETCLIM: REQUIRES 5 INPUTS')
end
fig1=[];
fig2=[];


% 2. Determine percentage of points in each magnitude bin and plot

pct=bhist/sum(bhist)*100;

if ~strcmp(mode,'auto')
	fig1=figure;
	set(gcf,'position',[65 109 560 420])
	plot(bins,pct)
	title('Histogram to Determine Color Limits')
	xlabel('Bins [Log10(g^2/Hz)]')
	ylabel('Percentage of Points')
	set(gca,'xtick',[bins(1):bins(length(bins))])
	grid
%	pause
end


% 3. Use threshold to chop off left and right tails

if ( strcmp(mode,lower('auto')) | isempty(thresh) )
	ind=find(pct~=0);
	clow=bins(min(ind));
	chigh=bins(max(ind));
else
	intfromleft=cumsum(bhist)/sum(bhist)*100;
	intfromright=cumsum(flipud(bhist(:)))/sum(bhist)*100;
	fig2=figure;
	set(gcf,'position',[65 109 560 420])
	plot(bins,intfromleft,bins,flipud(intfromright),'r')
	axis([bins(1) bins(length(bins)) 0 1])
	set(gca,'xtick',[bins(1):bins(length(bins))])
	grid
	xlabel('Bins [Log10(g^2/Hz)]')
	ylabel('# Points (%)')
	title('Integrated Histogram (Yellow - Left to Right, Red - Right to Left)')
	hold on
	leftthreshmin=min(intfromleft);
	rightthreshmin=min(intfromright);
	while 1
		while 1
			leftthresh=input(sprintf('Enter LEFT threshold value greater than %.3f: ',leftthreshmin));
			if ( leftthresh > leftthreshmin ), break; end
		end
		while 1
			rightthresh=input(sprintf('Enter RIGHT threshold value greater than %.3f: ',rightthreshmin));
			if ( rightthresh > rightthreshmin ), break; end
		end
		xlims=get(gca,'xlim');
		leftxline=[xlims(1) xlims(1)/2];
		leftyline=[leftthresh leftthresh];
		hleftline=line(leftxline,leftyline,'linestyle','--','color','y');
		rightxline=[leftxline(2) xlims(2)];
		rightyline=[rightthresh rightthresh];
		hrightline=line(rightxline,rightyline,'linestyle','--','color','r');
		indleft=find(intfromleft<=leftthresh);
		indright=find(intfromright<=rightthresh);
		pcttossleft=intfromleft(length(indleft));
		pcttossright=intfromright(length(indright));
		disp(sprintf('\nPercentage of Points Tossed: %.3f%% from left, %.3f%% from right totalling %.3f%%',pcttossleft,pcttossright,pcttossleft+pcttossright))
		clow=bins(length(indleft));
		chigh=bins(length(bins)-indright(length(indright)));
		if whole
			clow=floor(clow);
			chigh=ceil(chigh);
		end
		disp(sprintf('this gives clim = [%.1f %.1f]',clow,chigh))
		cont=askyn('Is this okay','y');
		if ( strcmp(lower(cont),'y') )
			break % out of while
		else
			delete([hleftline hrightline])
		end
	end % while
end

clim=[clow chigh];

% ind=find(bins>clow & bins<chigh);
% nb=bins(ind);
% nbh=bhist(ind);
% ipks=dpeaks(nbh,4);
% disp(sprintf('\n\nEstimated noise floor is at %.1f [log10(g^2/Hz)]\n',nb(ipks(1))))



