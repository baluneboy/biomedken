function robowrite(outfile,data,hdr)
% ROBOWRITE - Writes binary IMT .dat files
%   Usage: robowrite(outfile,data,hdr)
%   Inputs:  outfile - string, path to output file
%            data - matrix, robotics data in columnwise form. First column should always be index
%            hdr - structure, data to write to IMT header (optional)
%   Output:  IMT compatible .dat file
%
%   When rewriting corrected .dat files, this is intended to be used in conjunction with roboread_hdr.m 
%   for full functionality and accuracy when preserving header information.
%
%   Notes: When determining timestamps, only hdr.logidate will be used - hdr.logdate will only be parsed
%   for time zone info (only EST/EDT written in code right now; see comments). hdr.logidate is in UNIX
%   time_t format (seconds since 1970-Jan-01 00:00:00 GMT). When possible, the modification time for
%   the output file will be changed to match the timestamp info in the header - this requires the
%   "touch" command to be installed on the system (built in to UNIX/Linux, available in CYGWIN for
%   Windows systems). 
%
% See also roboread_hdr

% AUTHOR: Roger Cheng
% $Id: robowrite.m 4160 2009-12-11 19:10:14Z khrovat $

%%% Parse header structure
% Create if it was excluded
if nargin == 2
    hdr = struct;
end

% Read/create data
if ~isfield(hdr,'logname')
    hdr.logname = outfile;
end
if ~isfield(hdr,'logversion')
    hdr.logversion = '1.0'; % I assume this is ver. 1.0 format...
end
if ~isfield(hdr,'userdata')
    hdr.userdata = {};
end

% Handle dates
% Only logidate will be processed; too much trouble to parse the logdate string cause it is an idiotic
%  format; it will be parsed for timezone if it is there, and compared for consistency

% Get timezone from logdate, if present (only have EST/EDT, add as needed, else assumes/defaults to GMT)
if isfield(hdr,'logdate')
    tz = sscanf(hdr.logdate,'%*s %*s %*s %*s %s %*s');
    switch tz
        case 'EST'
            offset = -5*3600;
        case 'EDT'
            offset = -4*3600;
        otherwise
            tz = 'GMT';
            offset = 0;
    end     
else
    % Stupid logidate is in GMT so keep it that way...
    tz = 'GMT';
    offset = 0;
end

% Get the UNIX timestamp, or use current time, if it isn't there
if isfield(hdr,'logidate')
    ts_sdn = (hdr.logidate+offset)/86400+719529;
else
    ts_sdn = datenum(now);
    hdr.logidate = (ts_sdn-719529)*86400-offset;
end
logdate = ['"',datestr(ts_sdn,'ddd mmm'),' ',num2str(str2num(datestr(ts_sdn,'dd'))),' ',datestr(ts_sdn,'HH:MM:SS'),' ',tz,' ',datestr(ts_sdn,'yyyy'),'"'];
if isfield(hdr,'logdate')
    if ~strcmpi(logdate,hdr.logdate)
        warning('LOGDATE string overwritten by value in LOGIDATE');
    end
end
hdr.logdate = logdate;

% Check number of columns
logcolumns = size(data,2);
if ~isfield(hdr,'logcolumns')
    hdr.logcolumns = logcolumns;
elseif hdr.logcolumns ~= logcolumns
    warning('Number of columns specified (%0.0f) is inaccurate; replacing with %0.0f',hdr.logcolumns,logcolumns);
    hdr.logcolumns = logcolumns;
end

% Construct complete header
hdr_write = sprintf('# imt log\nset logheadsize 000000\nset logcolumns %0.0f\nset logname %s\nset logversion %s\nset logdate %s\nset logidate %0.0f\n\n# begin user data',...
    hdr.logcolumns,hdr.logname,hdr.logversion,hdr.logdate,hdr.logidate);
% User data part
if ~isempty(hdr.userdata)
    for k = 1:numel(hdr.userdata)
        hdr_write = [hdr_write,10,hdr.userdata{k}];
    end
else
    hdr_write = [hdr_write,10];
end
hdr_write = [hdr_write,sprintf('\n# end user data\n\n#####\n')];

% Get size of header, then replace 000000
hdr_write(27:32) = sprintf('%06.0f',length(hdr_write));


%%% Write .dat file (pun intended)
out_pn = fileparts(outfile);
if ~exist(out_pn,'dir') && ~isempty(out_pn)
    mkdir(out_pn);
end
fid = fopen(outfile,'w');
if fid == -1
    error('Could not write to output file');
end
% Write header
fprintf(fid,hdr_write);
% Write data
fwrite(fid,data','double');
fclose(fid);

%%% Modify timestamp for .dat file
ts_mod_cmd = sprintf('touch %s -t %s',outfile,datestr(ts_sdn,'yyyymmddHHMM.SS'));
if ispc % Windows with cygwin
    try 
        dos(ts_mod_cmd);
    catch
        warning('Could not change file timestamp (is CYGWIN "touch" available?)');
    end
elseif isunix
    try 
        unix(ts_mod_cmd);
    catch
        warning('Could not change file timestamp (is UNIX "touch" available?)');
    end
else
    warning('File timestamp could not be changed');
end



