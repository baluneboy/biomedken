# purpose: print number of lines in a file
# usage:   printnumlines.pl input_file

# get the command line arguments
@ARGV == 1 or die "Usage: printnumlines.pl input_file\n";
$filename = $ARGV[0];

# open the file (or die trying)
open (F, $filename) || die "Could not open $f: $!\n";
my @f = <F>;
close F;
my $lines = @f;
print $lines;