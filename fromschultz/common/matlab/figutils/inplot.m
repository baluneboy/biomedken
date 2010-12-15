%function [h]=inplot(xvec,yvec,sran)

% This function plots the data (xvec,yvec) and then plots a 
% subset in the upper left corner of the screen to give 
% you a "picture-in-a-picture".   
%
% Required INPUTS:
%   xvec - vector of x data points
%   yvec - vector of y data points, same length as xvec
%   sran - 2 vector of form [smin,smax] for subset to be plotted.
%          Note that (smin,smax) must be a subset of (min(xvec),max(xvec)).
%
%
% OUTPUTS:
%   h - a 2 vector of handles.  The first entry is the main graph and
%       the second is the subplot graph.
%
% Examples: x=[-500:500]; y=randn(1,1001);
%  inplot(x,y,[-200 -180])
function [h]=inplot(xvec,yvec,sran)

ymax=max(yvec);
ymin=min(yvec);
xmax=max(xvec);
xmin=min(xvec);

% Figure out if user set window, entire plot or subplot axis, and which 
% is which...
%
wbds=[0.2 0.6 0.3 0.25];
sbds=[0 0 0 0];

pbds=[xmin xmax ymin-0.15*(ymax-ymin) ymax+1.25*(ymax-ymin)];

plenx=pbds(2)-pbds(1);
pleny=pbds(4)-pbds(3);

%
% plot data in large window with plot axis already set
%
h = figure;
plot(xvec,yvec)
axis(pbds)
hold on

%
% See if limits are valid
%
if (sran(1)>=sran(2)),
   disp(' ')
   disp(['Lower bound ',num2str(sran(1)),' must be less than upper bound ',num2str(sran(2))]);
   disp(' ')
   sran(1)=sran(2)-1;
end

%
% Clip data
%
i=min(find(xvec>=sran(1)));
j=max(find(xvec<=sran(2)));
%
% Check to see if user set window bounds manually...
%
if (sbds==[0 0 0 0]),
  sbds=[sran(1) sran(2) min(yvec(i:j)) max(yvec(i:j))];
else
  sbds(1)=min(sran(1),sbds(1));
  sbds(2)=max(sran(2),sbds(2));
end
%
% Plot delimiters...
%
sl=pbds(1)+plenx*(wbds(1)-0.13+wbds(3)*(sran(1)-sbds(1))/(sbds(2)-sbds(1)))/0.775;
sr=pbds(1)+plenx*(wbds(1)-0.13+wbds(3)*(sran(2)-sbds(1))/(sbds(2)-sbds(1)))/0.775;
y1=min(ymax,pbds(3)+pleny*((wbds(2)-0.11)/0.815-0.1));
y2=pbds(3)+pleny*((wbds(2)-0.11)/0.815-0.07);
y3=pbds(3)+pleny*((wbds(2)-0.11)/0.815-0.05);
plot([sran(1) sran(1) sl sl],[pbds(3) y1 y2 y3],'r-')
plot([sran(2) sran(2) sr sr],[pbds(3) y1 y2 y3],'r-')
%hold off
%
% Switch axes handle for small plot...
%
gca1=gca;
gca2=axes('position',wbds);
set(gca2,'ycolor','r','xcolor','r')
plot(xvec,yvec)
axis(sbds);

return;

