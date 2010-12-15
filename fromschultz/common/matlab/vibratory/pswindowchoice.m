function [choice,string]=pswindowchoice

% This function prompts the user for their windowchoice, and outputs 
% that choice.

	disp('Available weighting functions:')
	disp('If you do not know which to use, choose Hanning (option 5)')
	choice=textmenu('Bartlett','Blackman','Boxcar','Hamming','Hanning',...
				    'Kaiser, Beta=5','Triangular');

	if choice==1 string='Bartlett';
	elseif choice==2 string='Blackman';
	elseif choice==3 string='Boxcar';
	elseif choice==4 string='Hamming';
	elseif choice==5 string='Hanning';
	elseif choice==6 string='Kaiser, beta=5';
	elseif choice==7 string='Triangular';
	else disp ('Something went wrong')
	end

