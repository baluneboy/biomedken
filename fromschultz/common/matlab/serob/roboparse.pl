# parse command line args
if ($#ARGV < 0) {die "NEED INPUT ARG FOR FILENAME ... Usage: roboparse.pl FILENAME.dat\n";}
$filename = $ARGV[0];

# open file and seek header size in bytes and number of data columns
open(MYINPUTFILE, $filename) || die "ERROR: could not open dat file '$filename'\n";
$count = 0;
LINE: while(<MYINPUTFILE>)
{
 my($line) = $_;
 if($count == 2)
 {
	 last LINE;
 }
 chomp($line);
 if($line =~ m/set logheadsize (\d+)/)
 {
	my($bytes) = int($1);
	print "$bytes,"; # header size in bytes
	$count++;
 }
 elsif($line =~ m/set logcolumns (\d+)/)
 {
	my($columns) = int($1);
	print "$columns\n"; # number of data columns
	$count++;
 }
}
close(MYINPUTFILE);
