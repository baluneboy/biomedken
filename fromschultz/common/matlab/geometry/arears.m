clc
%  AREA APPROXIMATIONS USING RIEMANN SUMS
%  MATLAB script:  arears
%
%  This script prompts the user for two nonconstant input functions, an
%  interval, and the maximum number of rectangles.
%
%  If functions of x, the area between graphs are 
%  approximated using vertical rectangles with
%  height determined using left hand endpoints.  If 
%  functions of y, the areas are approximated by
%  horizontal rectangles with length determined using 
%  lower endpoints.  Approximation begins with 2 rectangles and 
%  increases to n in increments of 2. 
%
%  The graphics display is divided into two subplots.  
%  The left hand plot illustrates the approximating rectangles.
%  The right hand plot displays the successive approximations.
%  As the number of rectangles is increased, the approximations
%  approach a limiting value which can be computed using definite
%  integrals.  There is a three second interval between frames.
%
%  IMPORTANT:  Recommended for demonstrations.  Not all functions will
%              display satisfactorily.  Plan ahead to determine optimal
%              plotting intervals.  
%              Nice demos include:  
%                   f1 = y, f2 = y^2, [-1 1]
%                   f1 = sin(x), f2 = cos(x), [0 pi]
%  
%  M-file by Lila F. Roberts, Georgia Southern University (lroberts@gasou.edu)
%        and David R. Hill, Temple University (hill@math.temple.edu)
done = 'close(gcf);clear;';
help arears
pause
disp('Press Enter to continue.')
clc
disp('Input the first function of x OR y.')
f1 = input('f1 = ','s');
disp('Input the second function of x OR y.')
f2 = input('f2 = ','s');
ind_var1 = findsym(sym(f1));
ind_var2 = findsym(sym(f2));
eflag1 = find(ind_var1==',');
eflag2 = find(ind_var2==',');
if (~isempty(eflag1) & any(find(ind_var1==','))) |  (~isempty(eflag2) & any(find(ind_var2==',')))
   error('Functions must contain exactly one variable.  Start over.'),
   elseif ind_var1 ~= ind_var2
      error('f1 and f2 must be functions of the same variable. Start Over.')
   elseif (ind_var1 ~= 'x')&(ind_var1 ~= 'y')
      error('Your functions must be functions of x or y.  Start Over.')
end
disp('Enter the interval. ')
interval = input('[a b] = ');
disp('Enter the maximum number of approximating rectangles you wish to see.')
maxn=input('Use 20 < = maxn <=50. maxn = ');
while (maxn - round(maxn) ~=0) | (maxn < 0)
   disp('The maximum number of rectangles must be a positive integer.')
   maxn=input('Use maxn <=50. maxn = ');
end
%Start the approximation.  
if ind_var1 == 'y'
	%Approximate the area using maxn. 
	%This will help to set a range for the area plotting window.
   yinterval=interval;
   ybegin=yinterval(1);yend=yinterval(2);
	y = [ybegin:(yend-ybegin)/maxn:yend];
	xright = eval(vectorize(f1));
	xleft= eval(vectorize(f2));
	for i = 1:length(xright)
   	if xright(i) < xleft(i)
      	temp = xright(i);
      	xright(i) = xleft(i);
      	xleft(i) = temp;
   	end
   end
   rmax = (sum(xright(1:maxn)-xleft(1:maxn)))*(yend-ybegin)/maxn;
	% Begin Plotting Loop.'
	n=0;
	dn=2;
   m=1;
   figure('units','normal','position',[0 0 1 1],'color','w')
   endh = uicontrol('style','push','units','normal','position',[0 .3 .08 .06], ...
       'string','Quit','call',done);

   while n <= maxn-dn
      m = m+1;
      subplot(1,2,1)
   	n=n+dn;
   	ybegin=yinterval(1);yend=yinterval(2);
   	yplot=[ybegin:0.01:yend];
		y = yplot;
		xright = eval(vectorize(f1));
      xleft= eval(vectorize(f2));
      plot(xright,y,'b',xleft,y,'r')
   	hold on
   	clear y;
		y = [ybegin:(yend-ybegin)/n:yend];
		xright = eval(vectorize(f1));
		xleft= eval(vectorize(f2));
		for i = 1:length(xright)
   		if xright(i) < xleft(i)
      		temp = xright(i);
      		xright(i) = xleft(i);
      		xleft(i) = temp;
   		end
   	end
   	text1=char(f1);
		text2=char(f2);
		minx = min(min(xleft),min(xright));
		maxx = max(max(xleft),max(xright));
		py = (yinterval(2)-yinterval(1))/10;
		px = (maxx-minx)/10;
		ytext = (yinterval(1)+yinterval(2))/2;
		text(minx-2.5*px,ytext, text1, 'color','b')
		text(minx-2.5*px,ytext- py,text2,'color','r')
   	r(n) = (sum(xright(1:n)-xleft(1:n)))*(yend-ybegin)/n;
   	for i=1:n
      	plot([xleft(i) xright(i)],[y(i) y(i)],'k')
			plot([xleft(i) xleft(i)],[y(i) y(i+1)],'k')
			plot([xleft(i) xright(i)],[y(i+1),y(i+1)],'k')
			plot([xright(i) xright(i)],[y(i+1) y(i)],'k')
		end
		xlabel(['# Rectangles = ' int2str(n)])
		axis([min(0,min(xleft)) max(0,max(xright)) min(min(ybegin),min(yend)) max(max(ybegin),max(yend))])
   	hold off
   	subplot(1,2,2)
   	plot([dn:dn:n],r(dn:dn:n),'b^','MarkerSize',5)
   	axis('normal')
   	axis([0 maxn 0 max(rmax,max(r))+1])
   	title(['Approximate Area = ' sprintf('%9.6f',r(n))])
   	xlabel('Number of Rectangles')
   	hold off
      pause(3)
   end
   end
   if ind_var1 == 'x'
   	%Approximate the area using maxn. 
		%This will help to set a range for the area plotting window.
   	xinterval=interval;
   	xbegin=xinterval(1);xend=xinterval(2);
		x = [xbegin:(xend-xbegin)/maxn:xend];
		ytop = eval(vectorize(f1));
		ybottom= eval(vectorize(f2));
		for i=1:length(ytop)
   		if ytop(i)<ybottom(i)
      	temp = ytop(i);
      	ytop(i) = ybottom(i);
      	ybottom(i) = temp;
   		end
		end
   rmax = (sum(ytop(1:maxn)-ybottom(1:maxn)))*(xend-xbegin)/maxn;
   clear x
   % Begin Plotting Loop.'
	n=0;
	dn=2;
   m=1;
   figure('units','normal','position',[0 0 1 1],'color','w')
   endh = uicontrol('style','push','units','normal','pos',[0 .3 .08 .06], ...
      	'string','Quit','call',done);
    	while n <= maxn-dn
      m = m+1;
      subplot(1,2,1)
   	n=n+dn;
   	xbegin=xinterval(1);xend=xinterval(2);
   	xplot=[xbegin:0.01:xend];
		x = xplot;
		ytop = eval(vectorize(f1));
   	ybottom= eval(vectorize(f2));
   	plot(x,ytop,'b',x,ybottom,'r')
   	hold on
   	clear x;
		x = [xbegin:(xend-xbegin)/n:xend];
		ytop = eval(vectorize(f1));
		ybottom= eval(vectorize(f2));
		for i = 1:length(ytop)
   		if ytop(i) < ybottom(i)
      		temp = ytop(i);
      		ytop(i) = ybottom(i);
      		ybottom(i) = temp;
   		end
   	end
   	text1=char(f1);
		text2=char(f2);
		miny = min(min(ybottom),min(ytop));
		maxy = max(max(ybottom),max(ytop));
		px = (xinterval(2)-xinterval(1))/10;
		py = (maxy-miny)/10;
		ytext = (maxy+miny)/2;
		text(xinterval(1)-2.5*px,ytext, text1, 'color','b')
      text(xinterval(1)-2.5*px,ytext-py,text2,'color','r')   	
      r(n) = (sum(ytop(1:n)-ybottom(1:n)))*(xend-xbegin)/n;
   	for i=1:n
      	plot([x(i) x(i)],[ybottom(i) ytop(i)],'k')
			plot([x(i) x(i+1)],[ybottom(i) ybottom(i)],'k')
			plot([x(i+1) x(i+1)],[ybottom(i) ytop(i)],'k')
			plot([x(i+1) x(i)],[ytop(i) ytop(i)],'k')
		end
		xlabel(['# Rectangles = ' int2str(n)])
      axis([min(min(xbegin),min(xend)) max(max(xbegin),xend) min(0,min(ybottom)) max(0,max(ytop))])
      hold off
   	subplot(1,2,2)
   	plot([dn:dn:n],r(dn:dn:n),'b^','MarkerSize',5)
   	axis('normal')
   	axis([0 maxn 0 max(rmax,max(r))+1])
   	title(['Approximate Area = ' sprintf('%9.6f',r(n))])
   	xlabel('Number of Rectangles')
   	hold off
   	pause(3)   
   end
end

