#!/usr/bin/perl
use strict;
use lib '/home/upendra/NLP/Softwares/Lingua-EN-Sentence-0.25/lib';
use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS get_acronyms);


my $path = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10Train";
my $dataset = "Politics-World";
my $processedData = "$path/all_data/processedData";
my $testLabel = "$path/$dataset/labels/rlabel_test.txt";
my $trainLabel = "$path/$dataset/labels/rlabel_train.txt";

## store the name of all files in @allLabels.
my @allLabels = ();
my $testLabels 	= readFile($testLabel);
my $trainLabels	= readFile($trainLabel);
push @allLabels, @$testLabels;
push @allLabels, @$trainLabels;
my $totalInstances = scalar(@allLabels);

my $mapOfMap = ();


foreach my $j(0..$totalInstances-1) ## for each instance j
{
	my $currValue = countPivot("$processedData/$allLabels[$j ]", $pivots->[$l]);
	my $binaryValue = 0;
	$binaryValue = 1 if ($currValue >= 0.002);
	#$binaryValue = $currValue;
	#print "\t\tpivotVal\t$currValue\t($pivots->[$l]\t$binaryValue)\n";
	push @$pl_,$binaryValue;
}


sub readFile
{
	my $file = $_[0];
	my $temp = ();
	open(FILE,"< $file") or die("Could not open $file:$!");  
	foreach my $line(<FILE>)
	{
		push(@$temp,trim($line));
	}
	close(FILE);

	return $temp;
}

sub countPivot
{
	my ($unlabelDoc, $pivot) = @_;
	open(FILE,"< $unlabelDoc") or die("Could not open $unlabelDoc:$!");
	my($content) = do { local $/; <FILE> };
	my $tokenCount = 0;
	$tokenCount += scalar(split(/\s+/, $content));
=pod
	my $sentences = get_sentences($content);
	foreach my $sentence (@$sentences)
	{
		my @temp = split( /\s+/, $sentence );
		$tokenCount = $tokenCount + scalar(@temp);
	}
=cut
	#print "$tokenCount\n";
	$content =~ s/[[:punct:]]/ /g;  ## remove all punctuations before computing the occurrence of pivot feature in current file.
	my $count  = () = $content =~ /\s$pivot\s/gi;
	my $normCount = $count/$tokenCount;
	return $normCount;
	
}


