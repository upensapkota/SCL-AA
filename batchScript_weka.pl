#!/usr/bin/perl 
use strict;
require "variable.pl";

our (@mergeModalities);

my $directory_path= $ARGV[0];
my $fname = $ARGV[1]; 
my $run = $ARGV[2];
my $h = $ARGV[3];


my $location_weka = "/home/upendra/NLP/Softwares/weka-3-7-6";

print "** Classifying using weka**\n";

my $runPath = "$directory_path$fname/$run";
foreach my $i(0..$#mergeModalities)
{
	my @modalities = @{$mergeModalities[$i]};
	my $merged = join("+",@modalities);
        my $weka_h = "$runPath/weka/$h";
	my $outputFile = "$weka_h/$merged/smo_classic.txt";
	my $pathToWekaFolder = "$weka_h/$merged/classic";
	print "-----Working on $merged -------------\n";

	system("java -Xmx23000m -cp $location_weka/weka.jar weka.classifiers.functions.SMO  -v -o -t $pathToWekaFolder/classic_train.arff -T $pathToWekaFolder/classic_test.arff -i  >$outputFile");
}



