#!/usr/bin/perl 
use strict;
require "create_file_hierarchy.pl";
use File::Copy::Recursive qw(dircopy);


my $location    = $ARGV[0]; #/nethome/students/upendra/NLP/MyRun/Data/crossDomain
my $folder_name = $ARGV[1]; #Mikros_Corpus 10 2



my $src 			= "$location/$folder_name/all_data";

print("******************* character separation files ****************************\n");
system("perl characteSeparation.pl $src/ posts_original processed_files");

print "******************** End of script batchProcessindData.pl**********************************\n";

