function	setgrid(varargin)

% setgrid({'ax1' 'ax2' ... 'axN'})
%	to draw gridlines on userdefined tickmarks
%
% axN:	define grid plane
%	'xy' | 1:	X-axis in XY-plane
%	'yx' | 1:	Y-axis in XY-plane
%

% created
%	us	07nov00	 for <comp.sys-soft.matlab>

%-----------------------------------------------------------------------
if	nargin < 1
help setgrid;
return;
end

% keep layout
apar={'grid'};
apar=[apar {'xlim' 'xscale'}];
apar=[apar {'ylim' 'yscale'}];
apar=[apar {'zlim' 'zscale'}];
oax=get(gca,apar);
agrd=get(gca,'grid');

% cycle through axis-defines

for	i=1:nargin
agrid=varargin{i};
switch	agrid
case	{'xy' 1}
alim=get(gca,'ylim');
atic=get(gca,'xtick');
vtic=repmat(alim,length(atic),1);
line([atic;atic],vtic','linestyle',agrd,'color',[0 0
0]);
case	{'yx' 2}
alim=get(gca,'xlim');
atic=get(gca,'ytick');
vtic=repmat(alim,length(atic),1);
line(vtic',[atic;atic],'linestyle',agrd,'color',[0 0
0]);
otherwise
disp(sprintf('setgrid> invalid axis spec <%c>',cgrid));
end
end

% reset layout
set(gca,apar,oax);
return;