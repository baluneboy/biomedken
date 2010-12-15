function strVersion=bottomdateline(strDataSource);

%bottomdateline - generate small source and version control text near bottom of plots
%
%strVersion=bottomdateline(strDataSource);
%
%Input: strDataSource - string for PAD path
%
%Output: strVersion - string for small text at bottom

%Author: Ken Hrovat, 3/28/2001
%$Id: bottomdateline.m 4160 2009-12-11 19:10:14Z khrovat $

% Looks like this: "from: DataSource, ReleaseName, Date" (wo quotes)
strVersion=sprintf('from: %s, $Name:  $, %s',strDataSource,popdatestr(now,0));