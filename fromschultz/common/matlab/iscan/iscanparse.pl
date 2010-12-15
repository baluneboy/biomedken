# parse command line args
if ($#ARGV < 0) {die "NEED INPUT ARG FOR FILENAME ... Usage: iscanparse.pl FILENAME.dat\n";}
$filename = $ARGV[0];

open(MYINPUTFILE, $filename) || die "ERROR: could not open txt file '$filename'\n";
$count = 0;
LINE: while(<MYINPUTFILE>)
{
 my($line) = $_;
 if($count == 2)
 {
	 last LINE;
 }
 chomp($line);
 if($line =~ m/Runs Recorded:\s+(\d+)/)
 {
	my($runs) = int($1);
	print "$runs,"; # runs recorded
	$count++;
 }
 elsif($line =~ m/Samps Recorded:\s+(\d+)/)
 {
	my($samps) = int($1);
	print "$samps\n"; # number of samples
	$count++;
 }
}
close(MYINPUTFILE);