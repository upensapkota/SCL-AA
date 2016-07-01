#!/usr/bin/perl 
use strict;
use File::Basename;
use File::Find;

#my $src = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/TwoTopics_S/all_data/processedData"; 

my $dataPath = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/TwoTopics_D";
my $old = "S21S2G4";
my $new = "S21D2G4";

$dataPath .= '/' if($dataPath !~ /\/$/);
opendir(SUBDIR, $dataPath);
my @folders = grep !/^\.\.?$/,readdir(SUBDIR);
closedir(SUBDIR);

sub renameFile
{
	foreach my $folder(@folders)
	{

#		if ( $folder =~ /Gay/ )
		if ( $folder =~ /Church-Gay/ )
		{
		print "$folder\n";
#		renameContent("$dataPath/$folder/labels/rlabel_train.txt");
		renameContent("$dataPath/$folder/labels/rlabel_test.txt");
		}

	}

}

sub renameContent
{
	my $file = $_[0];
	open (FILE,"<$file") or die($!);
	my ($file_contents) = do { local $/; <FILE> };
	close(FILE);
        $file_contents =~ s/$old/$new/gi;
	print "$file_contents";
	open (FILE,">$file") or die($!);
	print FILE "$file_contents";
#	close(FILE);

}

renameFile();
