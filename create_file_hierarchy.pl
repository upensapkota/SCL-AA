#!/usr/bin/perl 
use strict;

#this file should be run before extracting features i.e. before running batchScript but after running tagging scripts.
my $location       = $ARGV[0];
my $main_folder    = $ARGV[1];           #5Author
my $arff           = "arff";
my $avg            = "avg";
my $cluster        = "cluster";
my $fv             = "fv";
my $meta           = "meta";
my $weka           = "weka";
my $ppl            = "ppl";
my $vocab          = "vocab";
my $countFiles     = "CountFiles";
my $LMFiles        = "LMFiles";
my $PPLs           = "PPLs";
my $trainingFiles  = "trainingFiles";
my $vcluster_files = "vcluster_files";
my $cols_avg       = "column_average";

sub createNewFolder
{

	my $folderPathWithName = $_[0];

	#if the folder already exists, delete it along with all its contents.
	if ( -e "$folderPathWithName" )
	{
		use File::Path;
		my $status = rmtree( $folderPathWithName, 0, 1 ) ? "" : "";
	}

	#create the folder here.
        mkpath("$folderPathWithName");
	

	#print "created $folderPathWithName \n";

}

sub deleteFolder
{
    my $folderPathWithName = $_[0];
    if ( -e "$folderPathWithName" )
	{
		use File::Path;
		my $status = rmtree( $folderPathWithName, 0, 1 ) ? "" : "";
	}
}

sub createFor
{
	my $for = $_[0];
        #create cluster folder with subfolders
	createNewFolder("$for");
	createNewFolder("$for/10k");

}




sub createForFv
{
	my $for = $_[0];
	createNewFolder("$for");
	createNewFolder("$for/train");
	createNewFolder("$for/test");
}

sub deleteandRecreateAllFolders($)
{
	my $path = $_[0];
	print "$path \n";

	#create arff folder with subfolders
	createFor("$path/$arff");

	#create avg folder with subfolders
	createNewFolder("$path/$avg");

	#create cluster folder with subfolders
	createFor("$path/$cluster");

	#create fv folder with subfolders
	createForFv("$path/$fv");

	#create meta folder with subfolders
	createFor("$path/$meta");

	#create ppl folder with subfolders
	createForPpl("$path/$ppl");

	#create cluster folder with subfolders
	createFor("$path/$weka");

	#create folder with subfolders
	createNewFolder("$path/$vocab");
	createNewFolder("$path/$cols_avg");

	#create vlcuster_files folder with subfolders
	createNewFolder("$path/$vcluster_files");

}

1;

