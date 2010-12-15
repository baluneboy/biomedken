# purpose: print a range of lines from a text file.
# usage:   printrangelines.pl first-line last-line input-file

# get the command line arguments
@ARGV == 3 or die "Usage: printrangelines.pl first-line last-line input-file\n";
$first_line = $ARGV[0];
$last_line = $ARGV[1];
$filename = $ARGV[2];

# open the file (or die trying)
open(FILE, $filename) or die "Could not read from $filename, program halting.";

# loop through the file; start printing when you get to the first_line; exit the
# program when you get to last_line.
$count = 1;
while (<FILE>)
{
  # exit the program when you get to the last line
  if ($count > $last_line)
  {
    close FILE;
    exit;
  }

  # print the current line if the line number is greater than our first param
  if ($count >= $first_line)
  {
    print $_;
  }

  # increment the line counter
  $count++;
}

# come here if last-line is greater than the number of lines in the file.
# print an error message here if you prefer.
close FILE;