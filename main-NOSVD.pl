#!/usr/bin/perl 
use strict;
require "variable.pl";
my $directory_path	= $ARGV[0]; #$HOME
my $author_numbers 	= 3; #not used
my $cluster_numbers 	= 21; #not used
our ($h);




$directory_path .= '/' if ( $directory_path !~ /\/$/ );





my $start_run = time(); 


#for unshortened guardian corpus (DATASET1)
#=pod 
#my @folders = ('Society-World');
#my @folders = ('UK-World','World-UK','Society-World');
#my @folders = ('World-Society','Politics-World','World-Politics');
#my @folders = ('Society-UK','UK-Society','Politics-UK');
my @folders = ('UK-Politics','Politics-Society','Society-Politics');

# uncomment this to use all 12 datasets  #
my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
#my $srcData = "$baseFolder/TheGuardianCorpus/GuardianDataset1";  #location of text files
my $srcData = "$baseFolder/TheGuardianCorpus/Guardian1NoSVD";  #location of text files
#my $srcData = "$baseFolder/TheGuardianCorpus/GuardianDataset1_greaterZero";  #location of text files

#my @mainFolders = ('GuardianDataset1');
#my @mainFolders = ('GuardianDataset1_greaterZero');
my @mainFolders = ('Guardian1NoSVD');


#perl main.pl TheGuardianCorpus/ 

#=cut


#for shortened guardian corpus (DATASET 2)
=pod

my @folders = ('Politics-Society');
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
my $baseFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments";
###### my $srcData = "$baseFolder/TheGuardianCorpus/TwoTopics10TrainShortened";  #guardian
my $srcData = "$baseFolder/TheGuardianCorpus/GuardianDataset2";  #guardian
######my @mainFolders = ('TwoTopics10Shortened');
my @mainFolders = ('GuardianDataset2');
####perl main.pl TheGuardianCorpus/TwoTopics10TrainShortened
#perl main.pl TheGuardianCorpus/

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


#=pod
		#system("perl batchScript.pl $srcData $directory_path $folder_name $run");

		#system("perl pivotOccurenceCount.pl $srcData $directory_path $folder_name $run pivotC");

# for > median
		#system("perl sclSvd.pl $srcData	$directory_path $folder_name $run pivotC non-pivotC newC SCLFilesC Median");
# for > 0
		#system("perl sclSvd.pl $srcData	$directory_path $folder_name $run pivotC non-pivotC newC SCLFilesC Count"); ## count > 0, pl[i] = 1
#=cut

#=pod
	


#	system("perl getHRows.pl $srcData $directory_path $folder_name $run pivotC non-pivotC  SCLFilesC newC $h");
		## no SVD ##
		system("perl getHRowsNoSVD.pl $srcData $directory_path $folder_name $run pivotC non-pivotC  SCLFilesC newC $h");
		system("perl batchScript_arff.pl $directory_path $folder_name $run $h");
		system("perl batchScript_weka.pl $directory_path $folder_name $run $h");
#=cut
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
