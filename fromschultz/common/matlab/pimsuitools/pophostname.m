function [strHost,strRemote]=pophostname;

%POPHOSTNAME - system call to get hostname for applicable GUI fig;
%              needed workaround for behemoth's F3D_HOME and setenv
%              problems (early summer 2000).
%
%[strHost,strRemote]=pophostname;
%
%Output: strHost - string for hostname
%        strRemote - string for remotehost (same as strHost if not remote)

% written by: Ken Hrovat on 5/26/2000
% $Id: pophostname.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by: Eric Kelly on 7/6/2000 to return remote host if isunix

goodchars='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

if isunix
   % Get the host name
   [trash,strBig]=unix('hostname');
   k=find(abs(strBig==10));
   if isempty(k)
      error('cannot get hostname')
   elseif length(k)==1
      strHost=strBig(1:k-1);
   else
      strHost=strBig(k(end-1)+1:k(end)-1);
   end
   
   % get the RemoteHost name
   [trash,strBig]=unix('echo $REMOTEHOST');
   k=find(abs(strBig==10));
   
   if isempty(k)
      error('cannot get Remote hostname')
   elseif length(k)==1
      strRemote=strBig(1:k-1);
   else
      strRemote=strBig(k(end-1)+1:k(end)-1);
   end
   
   % Return same as host if not on remote login
   if strcmp(strRemote,'REMOTEHOST: Undefined variable.')
      strRemote = strHost;
   end
   
elseif strcmp(computer,'PCWIN')
   strHost=lower(computer);
   strRemote=strHost;
else
   msg=sprintf('pophostname not implemented for computer = %s',computer);
   error(msg)
end

