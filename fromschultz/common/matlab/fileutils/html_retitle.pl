#!/usr/bin/perl -w -p -i.bak

($sec,$min,$hour,$mday,$mon,$year)=localtime(time);
$stamp = sprintf("bci log %4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);

s/Matlab-data display/$stamp/;
s/<td>/<td valign="top">/g;