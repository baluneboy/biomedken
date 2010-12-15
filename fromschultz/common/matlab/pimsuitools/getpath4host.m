function strPath=getpath4host(strMidpath,sdn);

% strPath=getpath4host(strMidpath[,sdn]);
%
%Inputs: strMidpath - string for path after "root"
%        sdn - [optional] serial date number to append path
%
%Output: strPath - string for path on particular host
%
%examples:
% strPath=getpath4host('offline/batch/results/');
% strPath=getpath4host('www/plots/batch/',now);

%Author: Ken Hrovat
%$Id: getpath4host.m 4160 2009-12-11 19:10:14Z khrovat $

u=filesep;

strMidpath=strrep(strMidpath,'\',u);
strMidpath=strrep(strMidpath,'/',u);

[strHost,strRemote]=pophostname;
switch strHost
case 'pcwin'
   strRoot='T:\';
case 'ra-new'
   strRoot='/sdds/pims2/';
otherwise
   error(sprintf('unknown host %s',strHost))
end

strPath=[strRoot strMidpath];

if nargin==2
   strPath=[strPath sprintf('year%4d%smonth%02d%sday%02d%s',year(sdn),u,month(sdn),u,day(sdn),u)];
end