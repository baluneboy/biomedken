function [newylim,scale,ytick,yticklabels]=detylim(oldylim)



% DETYLIM - Function to determine "nice" y-limits, -ticks, -ticklabels and

%           scale for circumventing matlab's built-in "x10.." on top of

%           plots.  If ymin in old y-limits is negative, then return new

%           y-limits that are symmetric about zero.

%

% [newylim,scale,ytick,yticklabels]=detylim(oldylim);

%

% Inputs: oldylim - 2 element vector for containing old [ymin ymax]

%

% Outputs: newylim - 2 element vector for "nice" new [ymin ymax] limits

%          scale - scalar for scaling data and thus circumventing matlab's

%                  built-in "x10.." on top of plots

%          ytick - 6 or 11 element vector of "nice" yticks

%          yticklabels - 6 or 11 row string matrix for "nice" y tick labels



% written by: Ken Hrovat on 12/22/95
% $Id: detylim.m 4160 2009-12-11 19:10:14Z khrovat $



% 1. Verify i/o count

% 2. Extent = max(abs(oldylim))

% 3. Use int10.m to extract mantissa and exponent of extent

% 4. Use shdecpt.m to shift decimal point one place to the right

% 5. Set mantissa as ceil of mantissa from step 4

% 6. Use nxtmult5.m for "nice" mapping with next multiple

% 7. Use scienote.m to convert to scientific notation

% 8. Check for negative old ymin. If yes, then go with symmetric limits.

% 8a. Generate "nice" 6 or 11 element ytick vector

% 8b. Generate "nice" 6 or 11 row yticklabels string matrix

% 9. Calculate scale



% 1. Verify i/o count



if ( (nargin~=1) | (nargout~=4) )

	error('DETYLIM: REQUIRES 4 OUTPUT AND 1 INPUT ARGUMENT')

end





% 2. Extent = max(abs(oldylim))



extent = max(abs(oldylim));





% 3. Use int10.m to extract mantissa and exponent of extent



[oldman,oldexp]=int10(extent); 





% 4. Use shdecpt.m to shift decimal point one place to the right



[oldman,oldexp]=shdecpt(oldman,oldexp,+1);





% 5. Set mantissa as ceil of mantissa from step 4



oldman=ceil(oldman);





% 6. Use nxtmult5.m for "nice" mapping with next multiple



oldman=nxtmult5(oldman);





% 7. Use scienote.m to convert to scientific notation



[newman,newexp]=scienote(oldman,oldexp);





% 8. Check for negative old ymin. If yes, then go with symmetric limits.



if ( oldylim(1)<0 )

	newylim=[-newman newman];

	% 8a. Generate "nice" 11 element ytick vector

	dtick=newylim(2)/5;

	ytick=-newylim(2):dtick:newylim(2);

	% 8b. Generate "nice" 11 row yticklabels string matrix

	yticklabels=[];

	for yt=ytick

		yticklabels=str2mat(yticklabels,sprintf('%04.2f',yt));

	end

else

	newylim=[0 newman];

	% 8a. Generate "nice" 6 element ytick vector

	dtick=newylim(2)/5;

	ytick=0:dtick:newylim(2);

	% 8b. Generate "nice" 6 row yticklabels string matrix

	yticklabels=[];

	for yt=ytick

		yticklabels=str2mat(yticklabels,sprintf('%04.2f',yt));

	end

end



yticklabels=yticklabels(2:size(yticklabels,1),:);


% 9. Calculate scale



scale=1/10^newexp;

