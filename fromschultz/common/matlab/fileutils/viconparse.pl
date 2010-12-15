#!/usr/bin/env perl

# parse command line args
if ($#ARGV < 0) {die "NEED INPUT ARG FOR FILENAME ... Usage: getviconasciidatalines.pl FILENAME\n";}
$filename = $ARGV[0];

# open file and seek header size in bytes and number of data columns
open(MYINPUTFILE, $filename) || die "ERROR: could not open dat file '$filename'\n";
$count = 0;
while(<MYINPUTFILE>)
{

 my($line) = $_;
 $count++;

 chomp($line);

 if($line =~ m/^\s+/)
 {
	$bot = $count - 1;
	print "$bot,$hdr\n"; # found blank line
 }
 elsif($line =~ m/^\D/)
 {
	$hdr = $line;
	$hdr =~ s/\t/,/g;
	$hdr =~ s/[ :]/_/g;
	$top = $count + 1;
	print "$top,"; # found header line
 }
}
close(MYINPUTFILE);

