#!/usr/bin/perl 
use strict;
my $first_file = $ARGV[0];
my $target =$ARGV[1]; #destination file

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# copy first file into target file

sub copyFiles
{
        my ($source_file, $destination_path) = @_;
   	open(SRC,"< $source_file") or die("Could not open $source_file :$!");
   	open(DEST,">> $destination_path") or die("Could not open $destination_path :$!");
   	foreach my $line(<SRC>)
        {
         $line = trim($line);
         print DEST "$line\n";
        }
        close (SRC);
        close(DEST);
}

copyFiles($first_file, $target);


