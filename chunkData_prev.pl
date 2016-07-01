#!/usr/bin/perl 
use strict;
use File::Basename;
use File::Find;
use File::Copy;
require "create_file_hierarchy.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Lingua-EN-Sentence-0.25/lib';
use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS get_acronyms);
use POSIX qw(ceil floor);


my $directoryPath	 = "/nethome/students/upendra/NLP/MyRun/Data/crossDomain/crossTopic/mapping/gay_church";
my $dataSet 	 	 = $ARGV[0]; #"CCAT_10"
my $noShorten 	 	 = "noShortening";
my $folder 	  	 = "posts_original";
my $labelsBeforeShorting = "labels";

my $sentencesPerNewInstance 	= 4;  # total number of sentences in a file.
my $src		  		= "$directoryPath/$dataSet/$noShorten/all_data/$folder";  # all files before shorting
my $dst_path			= "$directoryPath/$dataSet/${sentencesPerNewInstance}SentencesPerInstance/all_data/";
my $dest	  		= "$dst_path/$folder";  # all files after shorting
my $labelFolder   		= "$directoryPath/$dataSet/${sentencesPerNewInstance}SentencesPerInstance/labels";  # labels after shortening documents

createNewFolder($dst_path);
createNewFolder($dest);
createNewFolder("$labelFolder");



my @rlabelTrain = ();
my @rlabelTest = ();
my %files = ();


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readTestLabels
{
    open(RLABEL,"< $directoryPath/$dataSet/$noShorten/$labelsBeforeShorting/rlabel_test.txt") or die("Could not open $labelsBeforeShorting/rlabel_test.txt");  
    foreach my $line(<RLABEL>)
    {
        push(@rlabelTest,trim($line));
    }
    close(RLABEL);
}




sub readTrainLabels
{
    open(RLABEL,"< $directoryPath/$dataSet/$noShorten/$labelsBeforeShorting/rlabel_train.txt") or die("Could not open $labelsBeforeShorting/rlabel_train.txt");  
    foreach my $line(<RLABEL>)
    {
        push(@rlabelTrain,trim($line));
    }
    close(RLABEL);
}








sub shortenFiles
{
	my $newRlabel   = $_[0];  # if train, then rlabel_train.txt.
	my $newRclass   = $_[1];  # if train, then rclass_train.txt.
	my $files	= $_[2];  # reference to names of the files, if train then @rlableTrain else @rlabelTest


	my @shortenedLabels = ();
	my @shortenedClass  = ();

	foreach my $fname (@$files)
	{
		my $filePath = "$src/$fname";
		open(SRC,"<$filePath") or die("Not found $filePath");
		my $data = do { local $/; <SRC> };
		my $author = getAuthorName($fname); #returns the first character
		my $sentences      = get_sentences($data);
	  	my $totalSentences = scalar(@$sentences);
		$fname =~ s/.txt//;	
		my $count = 0;

		my $number_instances = ceil($totalSentences/$sentencesPerNewInstance);
		print "$fname\t #Instances\t$number_instances\n";
		my $current = 0;	
		my $finalIndex = 0;

		foreach my $instance(1..$number_instances)
		{
			$count++;
			if($instance == $number_instances)
			{
			$finalIndex = $totalSentences;
			}
			else
			{
			$finalIndex = $instance*$sentencesPerNewInstance;
			}
			my @sliced = @$sentences[$current..$finalIndex-1];
			#print "Instance$instance: $current to $finalIndex\n";
			$current = $current + $sentencesPerNewInstance;
		
			my $newFile = "$fname-$count.txt";

			my $rclass = getAuthorName("$dest/$newFile");
			#print "label:$newFile\t class:$rclass\n";

			push @shortenedLabels, $newFile;
			push @shortenedClass, $rclass;
			open(F, ">$dest/$newFile") or die("Can't create $dest/$newFile");
			print F join("\n", @sliced);
			close(F);
	
		}		
	}
	printLabels($newRlabel, $newRclass, [@shortenedLabels], [@shortenedClass] );

	
}




sub printLabels
{
	my($labelFile, $classFile, $labelArray, $classArray) = @_;

	open(LABEL, ">$labelFolder/$labelFile") or die("Can't create $labelFolder/$labelFile");
	open(CLASS, ">$labelFolder/$classFile") or die("Can't create $labelFolder/$classFile");


  	print LABEL join("\n", @$labelArray);
	print CLASS join("\n", @$classArray);
		
	
}


readTestLabels();
readTrainLabels();
shortenFiles("rlabel_train.txt", "rclass_train.txt",[@rlabelTrain]);
shortenFiles("rlabel_test.txt", "rclass_test.txt",[@rlabelTest]);

