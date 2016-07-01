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


my $sentencesPerNewInstance = 20;

my $TotalInstanceDesired = 5;


#my $src	 = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/originalBeforeShortening";
#my $dest = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/processedData";

my $src	 = "/home/upendra/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/all_data/originalBeforeShortening";
my $dest = "/home/upendra/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/all_data/processedData";

#my $src	 = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/del";
#my $dest = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/del1";

createNewFolder($dest);


my %files = ();


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub shortenFiles
{
	my $path = $src;
	$path .= '/' if ( $path !~ /\/$/ );
	my @files = glob( $path . '*.txt' );

	foreach my $file (@files)
	{
		my $filePath = "$file";
		my ($fname, $path) = fileparse($file);
		open(SRC,"<$filePath") or die("Not found $filePath");
		my $data = do { local $/; <SRC> };
		my $data = trim($data);
		my $author = getAuthorName($fname); #returns the first character
		$data =~ s/\s*\r\s*/. /g;
		my $sentences      = get_sentences($data);
	  	my $totalSentences = scalar(@$sentences);
		$fname =~ s/.txt//;	
		my $count = 0;


		## if $number_instances given
		$sentencesPerNewInstance = ceil($totalSentences/$TotalInstanceDesired);
		my $number_instances = ceil($totalSentences/$sentencesPerNewInstance);

		## if $sentencesPerNewInstance given
		#my $number_instances = ceil($totalSentences/$sentencesPerNewInstance);
		
		print "$fname\t$totalSentences($sentencesPerNewInstance)\t #Instances\t$number_instances\n";
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
		
			my $newFile = "${fname}_$count.txt";

			my $rclass = getAuthorName("$dest/$newFile");
			#print "label:$newFile\t class:$rclass\n";
			open(F, ">$dest/$newFile") or die("Can't create $dest/$newFile");
			print F join("\n", @sliced);
			close(F);
	
		}	

	
	}

}





shortenFiles();

