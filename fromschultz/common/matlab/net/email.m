function email(to,toaddress,from,fromaddress,subject,message,varargin)
% EMAIL -- send an email using Windows IIS local smtp service
%
% NOTE: From and To address must be valid, and for some reason,
% fescenter.org does not like relaying messages from iis local smtp
%
% Inputs:
%   to: Name of sender
%   toaddress: email address of sender
%   from: Name of recipient
%   fromaddress: email address of recipient
%   subject: subject of mesage
%   message: email body (use a cell array of strings for multiple lines.)
%   (optional) pickup: the pickup directory if not the default ('C:\inetpub\mailroot\pickup')
%
% Example:
%   email('Optimus Prime','op@autobot.com','Megatron','mega@decepticon.org','I love you.',{'First Line','Second Line'});

% Author: Sahil Grover

pickup = 'C:\inetpub\mailroot\pickup';
if ~isempty(varargin)
    pickup = varargin{1};
end

tmpmail = [tempdir filesep 'tempmail.txt'];

fid = fopen(tmpmail,'w');
if fid==-1
    error('Could not open a temporary text file in %s',tempdir);
end

fprintf(fid,'To: "%s" <%s>\r\n',to,toaddress);
fprintf(fid,'From: "%s" <%s>\r\n',from,fromaddress);
fprintf(fid,'Subject: %s\r\n',subject);
fprintf(fid,'\r\n');

if iscellstr(message)
    cellfun(@(x)fprintf(fid,'%s\r\n',x),message,'uni',0);
else
    fprintf(fid,'%s',message);
end
fclose(fid);

movefile(tmpmail,pickup);