function h=otobar(fig,mode,otomatrix,otomean,otosigma,otomin,otomax)

% OTOBAR - Function to overlay plot of 1/3 octave stat bars on top of
%          a figure.  If isempty(fig), then use figure(gcf).
%
% Modes:
%
% 1. Plot mean for each bin with some distinct marker and have the range bar
%    go from the respective minimums to the maximums.
% 2. Have range bars with marker for mean and extending from (mean-n*sigma)
%    to (mean+n*sigma) just for cases where mins/maxs are not exceeded.
%    If min, max, or both are exceeded, then put asterisk at mean and revert
%    to mode 1 for that bin.
% 3. Same as mode 2 except only "out of bounds tail" is set to min or max.
% 4. Plot all points as dots.
% 5. Have range bars with marker for mean and extending from (mean-n*sigma)
%    to (mean+n*sigma).  If (mean-n*sigma) is negative, then put asterisk at
%    mean and set bottom of bar to min.
% 6. Same as 5 above, except no asterisks are inserted.
%
% SEE OTOSTATS.M FUNCTION
%
% h=otobar(fig,mode,otomatrix,otomean,otosigma,otomin,otomax)
%
% Inputs: fig - scalar for figure to plot stat bars on top of
%         mode - scalar that is either 1 or 2 (see above)
%         otomatrix - matrix of 1/3 band RMS accel. values.
%         otomean - vector of 1/3 band RMS accel. means
%         otosigma - vector of 1/3 band RMS accel. standard deviations
%         otomin - vector of 1/3 band RMS accel. minimums
%         otomax - vector of 1/3 band RMS accel. maximums

%     written by: Ken Hrovat on 5/18/96 
% $Id: otobar.m 4160 2009-12-11 19:10:14Z khrovat $

if ( any(size(otomean)~=size(otosigma)) | any(size(otomean)~=size(otomin)) | ...
     any(size(otomean)~=size(otomax)) )
  error('The sizes of otomean, otosigma, otomin, and otomax must be the same.');
end

if ( isempty(fig) )
	fig=gcf;
end
figure(fig); hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
%%%  5.             TABLE OF 1/3 OCTAVE FREQUENCY BANDS                      %%%
%%%      (TAKEN FROM "Microgravity Control Plan" -- January 21, 1994)        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bands = [ 0.0891  0.10    0.1122;
          0.1122  0.125   0.1413;
          0.1413  0.16    0.1778;
          0.1778  0.20    0.2239;
          0.2239  0.25    0.2818;
          0.2818  0.315   0.3548;
          0.3548  0.40    0.4467;
          0.4467  0.50    0.5623;
          0.5623  0.63    0.7079;
          0.7079  0.80    0.8913;
          0.8913  1.00    1.1220;
          1.1220  1.25    1.4130;
          1.4130  1.6     1.7780;
          1.7780  2.00    2.2390;
          2.2390  2.5     2.8180;
          2.8180  3.15    3.5480;
          3.5480  4.0     4.4670;
          4.4670  5.0     5.6230;
          5.6230  6.3     7.0790;
          7.0790  8.0     8.9130;
          8.9130  10.0    11.220;
          11.220  12.5    14.130;
          14.130  16.0    17.780;
          17.780  20.0    22.390;
          22.390  25.0    28.180;
          28.180  31.5    35.480;
          35.480  40.0    44.670;
          44.670  50.0    56.230;         % this is last row of table they list
          56.230  64.0    71.838;         % so this row down was computed and 
          71.838  80.635  90.510;         % adjusted for continuity
          90.510  101.59  114.04];

bands=bands(1:length(otomean),:);
cf=bands(:,2);
tee = (bands(:,3)-bands(:,1))*0.11; % this value can be in range 0 to 0.5
xl = cf - tee;
xr = cf + tee;

% build up nan-separated vector for bars
xb = [];
yb = [];
if ( mode==1 )
	for i = 1:length(otomean)
    	ytop = otomax(i);
    	ybot = otomin(i);
    	xb = [xb;cf(i);cf(i);nan;xl(i);xr(i);nan;xl(i);xr(i);nan];
    	yb = [yb;ytop;ybot;nan;ytop;ytop;nan;ybot;ybot;nan];
	end
	h1=plot(xb,yb,'-');
	h2=plot(cf,otomean,'o');
	h=[h1 h2];
elseif ( mode==2 )
	ineg=[];
	for i = 1:length(otomean)
    	ytop = otomean(i) + otosigma(i);
    	ybot = otomean(i) - otosigma(i);
		if ( ybot<otomin(i) | ytop>otomax(i) )
			ineg=[ineg i];
			ytop = otomax(i);
			ybot = otomin(i);
		end
    	xb = [xb;cf(i);cf(i);nan;xl(i);xr(i);nan;xl(i);xr(i);nan];
    	yb = [yb;ytop;ybot;nan;ytop;ytop;nan;ybot;ybot;nan];
	end
	h1=plot(xb,yb,'-');
	h2=plot(cf,otomean,'o');
	h3=plot(cf(ineg),otomean(ineg),'*');
	h=[h1 h2 h3];
elseif ( mode==3 )
	ipos=[];
	ineg=[];
	for i = 1:length(otomean)
    		ytop = otomean(i) + otosigma(i);
    		ybot = otomean(i) - otosigma(i);
		if ( ytop>otomax(i) )
			ipos=[ipos i];
			ytop = otomax(i);
		end
		if ( ybot<otomin(i) )
			ineg=[ineg i];
			ybot = otomin(i);
		end
    	xb = [xb;cf(i);cf(i);nan;xl(i);xr(i);nan;xl(i);xr(i);nan];
    	yb = [yb;ytop;ybot;nan;ytop;ytop;nan;ybot;ybot;nan];
	end
	h1=plot(xb,yb,'-');
	h2=plot(cf,otomean,'o');
	h=[h1 h2];
	if ( ~isempty(ipos) )
		h3=plot(cf(ipos),otomean(ipos),'+');
		h=[h h3];
	end
	if ( ~isempty(ineg) )
		h4=plot(cf(ineg),otomean(ineg),'x');
		h=[h h4];
	end
elseif( mode==4 )
	h1=plot(cf,otomean,'o');
	h2=plot(cf',otomatrix,'y.','markersize',1);
	h=[h1 h2];
elseif( mode==5 )
	ineg=[];
	for i = 1:length(otomean)
    	ytop = otomean(i) + otosigma(i);
    	ybot = otomean(i) - otosigma(i);
		if ( ybot<=0 )
			ineg=[ineg i];
			ybot = otomin(i);
		end
    	xb = [xb;cf(i);cf(i);nan;xl(i);xr(i);nan;xl(i);xr(i);nan];
    	yb = [yb;ytop;ybot;nan;ytop;ytop;nan;ybot;ybot;nan];
	end
	h1=plot(xb,yb,'-');
	h2=plot(cf,otomean,'o');
	h3=plot(cf(ineg),otomean(ineg),'*');
	h=[h1 h2 h3];
elseif( mode==6 )
	ineg=[];
	for i = 1:length(otomean)
    	ytop = otomean(i) + otosigma(i);
    	ybot = otomean(i) - otosigma(i);
		if ( ybot<=0 )
			ineg=[ineg i];
			ybot = otomin(i);
		end
    	xb = [xb;cf(i);cf(i);nan;xl(i);xr(i);nan;xl(i);xr(i);nan];
    	yb = [yb;ytop;ybot;nan;ytop;ytop;nan;ybot;ybot;nan];
	end
	h1=plot(xb,yb,'-');
	h2=plot(cf,otomean,'o');
	h=[h1 h2];
else
	error('mode must be either 1, 2, 3, 4, 5, or 6')
end
hold off

