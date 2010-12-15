function [hdr, data] = roboread_hdr(datfile)
% ROBOREAD_HDR - Reads binary IMT .dat files
%  This is very similar to roboread, but will return header information and operate on files with an
%  arbitrary number of columns.
%
%   Usage: [hdr, data] = roboread_hdr(datfile)
%   Input:   datfile - string, filename to read
%   Outputs: hdr - structure, contains information in IMT header
%            data - matrix, robotics data in columnwise form. First column is always index
%
%  Differences from roboread: Arbitrary # of columns - this will allow reading data in any format, however
%   it is up to the user to identify which column is what. For a more foolproof/stricter output, use
%   roboread. Header structure - use this to feed into robowrite. 
%  Note: roboread_hdr does NOT depend on roboparse.pl, so changes in there will not occur here
%
%  See also robowrite, roboread

% AUTHOR: Roger Cheng
% $Id: roboread_hdr.m 4160 2009-12-11 19:10:14Z khrovat $

% Open file
fid = fopen(datfile,'r');
if ~strcmp(fgetl(fid),'# imt log')
    fclose(fid);
    error('File does not appear to be an IMT log file');
end

%%% Read header
% Read main header (this should be in fixed order)
hdr.logheadsize = sscanf(fgetl(fid),'%*s %*s %d');
hdr.logcolumns = sscanf(fgetl(fid),'%*s %*s %d');
hdr.logname = sscanf(fgetl(fid),'%*s %*s %s');
hdr.logversion = sscanf(fgetl(fid),'%*s %*s %s');
hdr.logdate = regexp(fgetl(fid),'\<".*"\>','match','once'); % this will be overridden by logidate
hdr.logidate = sscanf(fgetl(fid),'%*s %*s %d');

% Read user data section (I've never seen this used yet, so just read it as a CAS
fgetl(fid); % Blank line
fgetl(fid); % "begin user data"
tmp = fgetl(fid);
hdr.userdata = {};
while ~strcmp(tmp,'# end user data') && ~feof(fid) % handle broken files so there is no infinite loop
    hdr.userdata = cat(1,hdr.userdata,tmp);
    tmp = fgetl(fid);
end
if feof(fid)
    if ~strcmp(tmp,'# end user data')
        error('Corrupt file')
    end
end

% Determine whether to read data
if nargout < 2 % Header only
    fclose(fid);
    return
end

%%% Read trial data
% Seek to data
fseek(fid,hdr.logheadsize,-1);
% Read a stream of doubles
data = fread(fid,inf,'double');
fclose(fid);
% Reshape
ncol = hdr.logcolumns;
nsamp = floor(numel(data)/ncol);
tmp = reshape(data(1:nsamp*ncol),ncol,nsamp);

% Error Check
if isempty(find(tmp(1,:)-floor(tmp(1,:)),1))
   data = tmp'; % Everything read fine
   
else % Messed up indices detected
    warning(sprintf('First column does not look like index, attempting alternate read;\n NaNs may be padded to incomplete sample points, or extraneous data may be truncated'));
    % Look for positive integers (assumedly, the indices)
    int_ind = find(and(data-floor(data) == 0, data > 0));
    new_col = unique(diff(int_ind));
    if numel(new_col) == 1 % wrong number of columns, correct number found (but pad anyway)
        maxsamp = numel(data)-int_ind(1)+1;
        nsamp = floor(maxsamp/new_col);
        % Re-section data according to correct columns
        data = reshape(data(int_ind(1):int_ind(1)-1+nsamp*new_col),new_col,nsamp)';
        if new_col < hdr.logcolumns % pad extra to reach number specified in header
            data = cat(2,data,NaN*ones(size(data,1),hdr.logcolumns-new_col));
        end

    else
        if hdr.logcolumns >= mode(diff(int_ind)) 
        % Really messed up data, but "mostly" correct and consistent with header OR
        % header specifies more columns than in data - output number specified in header and fill
        % missing data with NaN
            new_col = hdr.logcolumns;
        else
        % Header specifies fewer columns than most sample points seem to indicate - read number
        % apparent in data
            new_col = mode(diff(int_ind));
        end
                
        tmp = data;
%         while int_ind(end)+new_col-1 > numel(tmp)
%             int_ind = int_ind(end-1);
%         end
        int_ind = cat(1,int_ind,length(tmp)+1);
        
        data = NaN*ones(numel(int_ind)-1,new_col);
        for k = 1:numel(int_ind)-1
            if int_ind(k)+new_col > int_ind(k+1) % not enough columns, pad with NaN
                data(k,1:(int_ind(k+1)-int_ind(k))) = tmp(int_ind(k):int_ind(k+1)-1)';
            else % too many columns, truncate
                data(k,:) = tmp(int_ind(k):int_ind(k)+new_col-1)';
            end        
        end
    end
    
    % Check number of columns in header
    if hdr.logcolumns ~= new_col
%         hdr.logcolumns = new_col; % Update header
        warning('Number of columns specified in header (%0.0f) does not match columns of data (%0.0f)',hdr.logcolumns,new_col);
    end
end
clear tmp

% Quick check for missing samples (non-monotonically increasing index)
spacing = unique(diff(data(:,1)));
if numel(spacing) ~= 1 || spacing ~= 1
    warning('Non-monotonic index detected; gaps may be present in data timeline');
end
% Check for NaNs in data (missing data)
if find(isnan(data(:)),1)
    warning('NaNs present in data; incomplete sample points may be present');
end


