function [fileno,mint]=pcsagetdir (dirname,fileid)

% This function is used to read the directory for the PCSA bulk processing.
% The inputs are the directory to read, and the beginning portion of the
% filename.  This assumes all files have the ".mat" tagged on the end.


% Do the unix dir command
	if ~(dirname(length(dirname))=='/')
		dirname(length(dirname)+1)='/';
	end
	[trash,good]=unix(['ls -1 ' dirname fileid]);

% Strip the "good" down, based on the fileid length and slashes.
	indfileid=findstr(good,fileid(1:length(fileid)-1));
	ind10=find(good==10);
 % Build the list of indices to remove
	ind=[];
	l=length(fileid)-1;
	for i=1:size(ind10,2)
		if i==1
			ind=1:indfileid(i)+l-1;
		else
			ind=[ind ind10(i-1)+1:indfileid(i)+l-1];
		end
		
	end
 % Chop the lines
	good(ind)=[];


% Now put the filenames into the fileno matrix
	ind10=find(good==10);
	for i=1:size(ind10,2)
		if i==1
			fileno=good(1:ind10(i)-1);
		else
			fileno=str2mat(fileno,good(ind10(i-1)+1:ind10(i)-1));
		end
	end

% Strip the ".mat's"
	fileno(:,10:13)=[];

% And now, make the mint matrix
	for i=1:size(fileno,1)
		mint(i)=24*3600*str2num(fileno(i,1:3))+...
			3600*str2num(fileno(i,4:5))+...
			60*str2num(fileno(i,6:7))+...
			str2num(fileno(i,8:9));
		
	end

% And now, sort the mint matrix, and counter-sort the fileno matrix
	[mint,ind]=sort(mint);
	fileno=fileno(ind,:);
