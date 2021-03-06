#!/usr/bin/perl 
use strict;
use warnings;
require "create_file_hierarchy.pl";
my $srcData	= $ARGV[0]; ## source documents
my $location 	= $ARGV[1]; #location of the main folder
my $folder_name = $ARGV[2]; #actual folder inside which the hierarchy of file is to be created,e.g. 5Author
my $run 	= $ARGV[3];
my $pivot	= $ARGV[4]; # pivotC or pivotN



my $runPath 	= "${location}$folder_name/$run";

my $pivotFile	= "$runPath/vocab/${pivot}labels.txt";


my $testLabel = "$runPath/labels/rlabel_test.txt";
my $trainLabel = "$runPath/labels/rlabel_train.txt";
my $processedData = "$srcData/all_data/processedData";

## store the name of all files in @allLabels.
my @allLabels = ();
my $testLabels 	= readFile($testLabel);
my $trainLabels	= readFile($trainLabel);
push @allLabels, @$testLabels;
push @allLabels, @$trainLabels;

my @allPivots = ();
my $allPivotsRef = readFile($pivotFile);

@allPivots = @$allPivotsRef;
my $totalInstances = scalar(@allLabels);
my $m = scalar(@allPivots);

print "$pivotFile\n";
#print "Instances: $totalInstances\npivots: $m\n";
my @pls = ();

#$totalInstances = 1;
#$m = 1;
computePL();


sub computePL
{


	## For each instance, each pivot feature has either 0 or 1 value. So, let's say, pivot value is 1 if the normalized occurrence of pivot feature in current document is at least threshold gamma

	my @means = ();
	my @medians = ();
	foreach my $l(0..$m-1) ## for each pivot features 
	{
		my $pl_ = ();
		foreach my $j(0..$totalInstances-1) ## for each instance j
		{
			my $currValue = countPivot("$processedData/$allLabels[$j]", $allPivots[$l]);
			#print "\t\tpivotVal\t$currValue\t($pivots->[$l]\t$binaryValue)\n";
			push @$pl_,$currValue;
		}	
		#print "@$pl_\n\n\n\n";
		#print FILEP join(" ", @$pl_)."\n";
		my $median = computeMedian($pl_);
		my $mean = computeMean($pl_);
		push @medians, $median;
		push @means, $mean; 
		
		my $meanBinaries = computeBinary($pl_, $mean);
		my $medianBinaries = computeBinary($pl_, $median);
		#print FILEMDB join(" ", @$medianBinaries)."\n";
		#print FILEMEB join(" ", @$meanBinaries)."\n";
		print "Median: $median\tMean: $mean\n\n";
		#push @pls, $pl_;

	}

	
	

}

sub computeBinary
{
	my ($valR, $threshold) = @_;
	my @vals = @$valR;
	my @binaries = ();
	foreach my $val(@vals)
	{
		my $binary = 0;
		$binary = 1 if $val >= $threshold;
		push @binaries, $binary;
	}
	return \@binaries;
}


sub computeMedian
{
	my $valR = $_[0];
	my @vals = @$valR;
	my $sum = 0;
	my $med;
	
	#sort data points
	@vals = sort { $a <=> $b } (@vals);
	print "SORTED: @vals\n";

	#test to see if there are an even number of data points
	if( @vals % 2 == 0){
	#if even then:
	$sum = $vals[(@vals/2)-1] + $vals[(@vals/2)];
	$med = $sum/2;
	}
	else{
	#if odd then:
	$med = $vals[@vals/2];

	}
	$med = sprintf "%.0f", $med;
	return $med;
}


sub computeMean
{
	my $valR = $_[0];
	my @vals = @$valR;
	my $sum = 0;
	my $mean;
	
	foreach my $val(@vals)
	{
		$sum = $sum + $val;
	}
	$mean = $sum/scalar(@vals);
	$mean = sprintf "%.0f", $mean;
	return $mean;
	
}


## returns the count of given pivot feature on given document.
sub countPivot
{
	my ($unlabelDoc, $pivot) = @_;
	#print "$unlabelDoc \n$pivot\n";
	open(FILE,"< $unlabelDoc") or die("Could not open $unlabelDoc:$!");
	my($content) = do { local $/; <FILE> };
	#$content =~ s/[[:punct:]]/ /g;  ## remove all punctuations before computing the occurrence of pivot feature in current file.
	#print "$pivot\t";
	#$pivot =~ s/[[:punct:]]/\\[[:punct:]])/g;
	#$pivot =~ s/\)/\\)/g;
	#$pivot =~ s/\(/\\(/g;
        #print "$pivot\n";
	$content =~ s/\s+/\_/g;  ## remove all spaces by underscore before computing the occurrence of pivot feature in current file.
	my $count  = () = $content =~ /$pivot/gi;
	my $normCount = $count;
	return $normCount;
	
}

=pod
sub main
{
	my @lines = countModule();
	my $count = scalar @lines;  # 'scalar' is not required, but lends clarity.
	print "###########\n $count \n###########\n";
}

sub countModule
{
	my $file = "/test";
	open my $fh, "<",$file or die "could not open $file: $!";
	my @contents = <$fh>;  # The <> brackets are used to read from $fh.
	my @filtered = grep (/\// ,@contents);
	return @filtered;      # Remove the reference.
}

=cut


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
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

