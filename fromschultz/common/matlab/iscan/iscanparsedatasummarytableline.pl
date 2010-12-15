# parse command line args
if ($#ARGV < 0) {die "NEED INPUT ARG FOR FILENAME ... Usage: iscanparsedatasummarytableline.pl FILENAME.dat\n";}
$filename = $ARGV[0];

open(MYINPUTFILE, $filename) || die "ERROR: could not open txt file '$filename'\n";
$count = 0;
LINE: while(<MYINPUTFILE>)
{
 my($line) = $_;
 if($count == 1)
 {
	 last LINE;
 }
 chomp($line);
 if($line =~ m/DATA SUMMARY TABLE/)
 {
	my($linenum) = $.;
	print "$linenum"; # line number
	$count++;
 }
}
close(MYINPUTFILE);