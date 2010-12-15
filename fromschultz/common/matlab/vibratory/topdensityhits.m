function [freq,mag,hits]=topdensityhits(i,x,y,topn,display)

% This function is used to analyze a density image to find the top 
% "offenders".  Usage: [freq,mag,hits]=topdensityhits(i,x,y,topn,display)
% where freq is a vector of frequencies, mag is the magnitude at those
% frequencies, and hits are the hits at each freq-mag which are the top
% hits.  The inputs are the image matrix (i), the x-axis and y-axis 
% vectors, the top number of desired offenders (topn), and a 'y' or 'n' 
% for diplay to tell the program to display the output in tabular form or not.

% Intitialize
	freq=[];
	mag=[];
	hits=[];
	if nargin==3
		display='n';
	end

% The Loop
     for j=1:topn
	[r,c]=find(i==max(max(i)));
	ind=find(i==max(max(i)));
	for k=1:length(ind)
		freq=[freq;x(c(k))];
		mag=[mag;y(r(k))];
		hits=[hits;i(r(1),c(1))];
	end
	i(ind)=zeros(size(ind));	
     end

% And for a tabular display
     if strcmp(display,'y')
	disp(sprintf('# Hits\t\tFreq\t\tMagnitude'));
	disp(sprintf('------\t\t----\t\t---------'));
	for k=1:length(freq)
		disp(sprintf('%0.0f\t\t%0.2f\t\t%0.2e',hits(k),freq(k),10^mag(k)));
	end
     end
