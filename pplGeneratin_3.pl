#!/usr/bin/perl
use strict;
#character n-gram feature
require "create_file_hierarchy.pl";
my $testfiles_path	= $ARGV[0];
my $file_path 		= $ARGV[1];
my $lm_path 		= $ARGV[2];
my $author_path 	= $ARGV[3];
my $output_path 	=$ARGV[4];

my @testfiles=();

createNewFolder($output_path);
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
sub readRLabel()
{
    open(RLABEL,"< $testfiles_path") or die("Could not open $testfiles_path file: $!.");  
    foreach my $line(<RLABEL>)
    {
        push(@testfiles,trim($line));
    }
    close(RLABEL);
}

#generates PPLs
#@testFileNames contain all the test files
sub generatePPLs()
{
	opendir(DIR, $author_path);
	my @authorlist= grep !/^\.\.?$/,readdir(DIR);
	#create a hash with keys as author names, values will be the training data
	close(DIR);
	#loop through all the test files
	for (my $i=0;$i<scalar(@testfiles);$i++)
	{
		my $tf = "$file_path$testfiles[$i]";
		foreach my $author (@authorlist)
		{
			my $lmname = "$lm_path$author";
			
			my $author_2 =$author;
			$author_2 =~ s/\.txt//i;
			
			my $outputfile="$author_2"."_$testfiles[$i]";
			#print "$lmname $tf\n";
			my $temp="$output_path$outputfile";
				my($cmd)="ngram -ppl $tf -order 4 -lm $lmname > $temp";
				qx/$cmd/;
		}
	}
}

readRLabel();
generatePPLs();
