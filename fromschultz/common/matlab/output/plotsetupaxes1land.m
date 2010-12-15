function [ax1]=plotsetupaxes1land (fig)
	figure(fig);
	clf;
	set(fig,'unit','inch')
	set(fig,'position',[0 0 11 8.5],'unit','inch','color','w')
	set(fig,'unit','pixel')
	orient landscape
%	set(gcf,'paperposition',[0.25 0.125 10.50 7.625])
	set(gcf,'paperposition',[0.25 0.125 10.50 8.0])
	ax1=axes;
	set(ax1,'tickdir','out','fontname','times','box','on','unit','inch')
	set(ax1,'position',[0.75 0.65 9.50 7.00])
