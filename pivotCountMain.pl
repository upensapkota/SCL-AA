#!/usr/bin/perl 
use strict;
require "variable.pl";
my $directory_path	= $ARGV[0]; #$HOME
my $author_numbers 	= 3; #not used
my $cluster_numbers 	= 21; #not used





$directory_path .= '/' if ( $directory_path !~ /\/$/ );




#my $srcData = "$baseFolder/steward_corpus/TwoTopicsSingleGenreShortened";   #stewart
#my $srcData = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/SEC";   #student essay corpus


my $start_run = time(); 


#for unshortened guardian corpus
#=pod 
my @folders = ('UK-World');
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
my $srcData = "$baseFolder/TheGuardianCorpus/TwoTopics10Train";  #guardian
my @mainFolders = ('TwoTopics10Train');
#perl main.pl TheGuardianCorpus/ 
#=cut

#for shortened guardian corpus
=pod
my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
my $srcData = "$baseFolder/TheGuardianCorpus/TwoTopics10TrainShortened";  #guardian
my @mainFolders = ('TwoTopics10Shortened');
#perl main.pl TheGuardianCorpus/TwoTopics10TrainShortened
=cut



#for ccat_10
=pod
my @folders = ('originalTestTrain-cicling');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
my $srcData = "$baseFolder/singleDomain/ccat_50";  #guardian
my @mainFolders = ('ccat_50');
#perl main.pl singleDomain/ 
=cut


#for delete
=pod
my @folders = ('justTest');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
my $srcData = "$baseFolder/singleDomain/del";  #guardian
my @mainFolders = ('del');
#perl main.pl singleDomain/ 
=cut
$directory_path = "$baseFolder/$directory_path";


		#### new scripts for cross-topic #####








foreach my $folder_name(@mainFolders)
{
	print "$folder_name\n";
	foreach my $run(@folders)
	{
		print "\t$run\n";


		die ("Not exists $directory_path$folder_name/$run") if(!(-e "$directory_path$folder_name/$run"));


		print "\n------- $directory_path$folder_name/$run -----------\n\n";

		system("perl pivotCountGraph.pl $srcData $directory_path $folder_name $run pivotC");
		#system("perl pivotOccurenceCount.pl $srcData $directory_path $folder_name $run pivotC");
		#system("perl batchScript.pl $srcData $directory_path $folder_name $run");
=pod
#####		system("perl sclSvd.pl $srcData	$directory_path $folder_name $run sem stop new SCLFiles");
		system("perl sclSvd.pl $srcData	$directory_path $folder_name $run pivotC non-pivotC  newC SCLFilesC Median");
		system("perl batchScript_arff.pl $directory_path $folder_name $cluster_numbers $run");
		system("perl batchScript_weka.pl $directory_path $folder_name $cluster_numbers $run");
=cut
		print "----------------- Completed $run------------------------\n\n";


	}
}


sub currentScript
{
	my $run = $_[0];
	use File::Copy;
	copy("variable.pl", "$directory_path/$run/variable.pl") or die("$!\n");
	use Cwd;
   	my $dir = getcwd;
	use File::Basename;
	my ( $fname, $folder ) = fileparse($dir);
	open(OUTFILE, "> $directory_path/$run/$fname") or die("error."); 
	close (OUTFILE);
}
