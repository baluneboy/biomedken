function one3rdhist(id, bins, rmsval)

% ONE3RDHSIT - Function to do log10 and update histograms for each of
%              the 1/3 octave frequency bands.
%
% one3rdhist(id, bins, rmsval);
%
% Inputs: id - string for unique identifier
%         bins - vector of bin values to use for histogram
%                for example, bins=[-18:0.2:0]
%         rmsval - matrix of RMS values to take next histogram of, each
%                  row is for different 1/3 octave band
%
% Outputs: [implicit] files for updated histograms (one for each band)

% adapted from histupdate by KH on 7/22/97

% For each 1/3 octave band:
% 1. Initialize output file (if non-existent) and load old histogram
% 2. Verify current bins match old bins and sizes 
% 3. Compute log10 and compute new histograms
% 4. Add new histogram values to old on bin-by-bin basis
% 5. Save updated histograms to files



for band=1:size(rmsval,1)

	fprintf('Updating histogram for band number %d \r',band)

	% 1. Initialize output files (if non-existent) and load old histograms
	
	rmsfile= bulkanchfile(['onethird/hist' id 'rmsband' num2str(band)]);
	if ( ~exist([rmsfile '.mat']) )
		oldbins=bins;
		eval(['newhist' num2str(band) '=zeros(size(bins));']);
		eval(['save ' rmsfile ' oldbins newhist' num2str(band)]);
	else
		eval(['load ' rmsfile]);
	end


	% 2. Verify current bins match old bins and sizes
	%    NOTE: error replaced with disp/return for graceful exit 
	
	if ( oldbins~=bins )
		disp('ONE3RDHIST: BINS NOT EQUAL TO OLD BINS => HISTOGRAM NOT UPDATED')
		return
	end
	if ( ~(any(size(oldbins)==size(eval(['newhist' num2str(band)])))) )
		disp('ONE3RDHIST: SIZE(OLDBINS) NOT EQUAL TO SIZE(OLDBHIST) => HISTOGRAM NOT UPDATED')
		return
	end
	
	
	% 3. Compute log10 and compute new histogram
	
	rms10=log10(rmsval(band,:));
	[n,x]=hist(rms10,bins);
	
	
	% 4. Add new histogram values to old on bin-by-bin basis
	
	eval(['newhist' num2str(band) '=newhist' num2str(band) '+n;']);
	
	
	% 5. Save updated histograms to files
	
	eval(['save ' rmsfile ' oldbins newhist' num2str(band)]);
		
end
