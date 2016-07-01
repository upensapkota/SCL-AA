#!/usr/bin/perl 
use strict;

my $string = "Upendra          		 Upendra.";
$string =~ s/\s+/_/g;
my @array = ();
my %map = ();
#push @array, $1 while ($str =~ /(.{1,3})/msxog);


for (my $i = 0; $i < length($string); $i++)
{
	my $ngram = substr($string, $i, 3);
	$map{$ngram}++;
}



	foreach my $ngram(sort {$map{$b}<=>$map{$a}}keys %map)
	{
		print "$ngram\t$map{$ngram}\n";
	}


