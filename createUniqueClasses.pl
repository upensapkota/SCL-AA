#!/usr/bin/perl 
use strict;

my $rclass_train_file	 	= $ARGV[0];
my $dest_file 			= $ARGV[1];

my %uniqueClasses=();


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readRLabel
{
	open(RCLASS,"< $rclass_train_file") or die("Could not open $rclass_train_file file:$!");  
	foreach my $line(<RCLASS>)
	{
	    $uniqueClasses{trim($line)}++;
	}
	close(RLABEL);
}

sub writeToFile
{
	my @sortedClasses = sort {$a cmp $b} keys %uniqueClasses;
        open(CLASS,"> $dest_file") or die("Can't create $dest_file:$!");
	print CLASS join(",",@sortedClasses);
	close(CLASS);
}

readRLabel();
writeToFile();

