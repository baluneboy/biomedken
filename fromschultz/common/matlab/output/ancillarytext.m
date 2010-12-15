function handles=ancillarytext(orient,head,fc,fs,l3,l4,mission,coord,r3,r4);

% This is the new function for ancillary data headers.  It will accept the
% orientation of the paper ('l','t'), as well as the headers to put for each 
% field.  And, it will accept the head, fc, fs, mission, coord, as well as 
% strings to place in the left3, left4, right3, right4 positions.  In order to
% put no string in these positions, input an empty string ('').  The function
% will output the handles for each of these text strings, as well as that for
% the rev.  The returned handles will be in the form of a vector,
% with [axanc hl1 hl2 hl3 hl4 hr1 hr2 hr3 hr4 hclock].

% Combine the head, fc, fs, and create clock string
	strHead=['Head ' upper(head) ', ' fc ' Hz'];
	strSampleRate=['fs=' fs ' samples per second'];
	strRev='$Revision: 1.1.1.1 $';
	
% Open a new axes
	axanc=axes;
	set(axanc,'unit','inch','fontname','times');
	axis off
	
% And to put the text on
	if strcmp(orient,'l')
		set(axanc,'position',[0 0 11 8.5])
		hl1=text(0.5,8.1875+0.25,strHead,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl1,'tag','pims_anc_headfcstr');
		hl2=text(0.5,8.0575+0.25,strSampleRate,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl2,'tag','pims_anc_fsstr');
		hl3=text(0.5,7.9275+0.25,l3,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl3,'tag','pims_anc_dfstr');
		hl4=text(0.5,7.7975+0.25,l4,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');	
		hr1=text(10.5,8.1875+0.25,mission,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		set(hr1,'tag','pims_anc_missionstr');
		hr2=text(10.5,8.0575+0.25,coord,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		set(hr2,'tag','pims_anc_coordstr');
		hr3=text(10.5,7.9275+0.25,r3,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		hr4=text(10.5,7.7975+0.25,r4,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		hclock=text(10.5,0.25,strRev,'fontname','times','fontsize',4,...
					'horizontal','right','unit','inch');		
	elseif strcmp(orient,'t')
		set(axanc,'position',[0 0 8.5 11])
		hl1=text(0.5,10.41,strHead,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl1,'tag','pims_anc_headfcstr');
		hl2=text(0.5,10.28,strSampleRate,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl2,'tag','pims_anc_fsstr');
		hl3=text(0.5,10.15,l3,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');
		set(hl3,'tag','pims_anc_dfstr');
		hl4=text(0.5,10.02,l4,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','left');	
		hr1=text(8.00,10.41,mission,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		set(hr1,'tag','pims_anc_missionstr');
		hr2=text(8.00,10.28,coord,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		set(hr2,'tag','pims_anc_coordstr');
		hr3=text(8.00,10.15,r3,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		hr4=text(8.00,10.02,r4,'unit','inch','fontname',...
				'times','fontsize',7,'horiz','right');
		hclock=text(8.00,0.25,strRev,'fontname','times','fontsize',4,...
					'horizontal','right','unit','inch');
	
	else
		disp('ancdataheader.m did not recognize the paper orientation.')
		disp('The paper must be set to either landscape (l) or tall (t)')
		disp('Not setting any ancillary handles.')
	end
	set(hclock,'tag','hclock')
	
% Set the output handles
	handles=[axanc hl1 hl2 hl3 hl4 hr1 hr2 hr3 hr4 hclock];
	
% Fix the units to normalized
	set(handles,'unit','normalized')
