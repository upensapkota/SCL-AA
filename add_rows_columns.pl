#!/usr/bin/perl 
use strict;
my $rLabelFile = $ARGV[0];
my $featureLabelFile = $ARGV[1];
my $targetFile = $ARGV[2];
#
#this script adds rows and column numbers in each file which is required for clustering purpose.
#Based on rlabelFile and featureLabelFile, we add rows and columns to targetFile.
#   
  my $rows = countRows($rLabelFile);
  my $cols = countRows($featureLabelFile);
  
  add_rows_cols();

sub add_rows_cols()
{
my $tmp = "tmp.txt";
open(SRC,"< $targetFile") or die("Could not open $targetFile:$!");
open(DEST,"> $tmp") or die("Could not open $targetFile:$!");

print DEST "$rows $cols\n"; # <--- HERE'S THE MAGIC

while( <SRC> )
        {
        print DEST $_;
        }
unlink($targetFile);
rename($tmp, $targetFile);
close SRC;
close DEST;
}

sub countRows($)
{
 my $rows = 0;
 open(FILE, "<@_") or die("can't open $featureLabelFile: $!"); 
 foreach my $line (<FILE>)
  {
    $rows++;
  }
 close(FILE);
 return $rows;
}
sub fastWay()
{
  my $firstContent = 'perl -pi -e \' print "$rows $cols\n" if $. == 1\' $targetFile';
  system($firstContent);
}

