#!/usr/bin/perl
use strict;
require "create_file_hierarchy.pl";
my $training_path	=$ARGV[0];
my $count_path		=$ARGV[1];

#generates count files
sub generateCountFile($)
{
     my(@path) = split(/\//,"@_");
     my $temp="$count_path$path[scalar(@path)-1]";
     my($cmd)="ngram-count -wbdiscount -unk -text @_ -order 4 -write-binary $temp";   
     qx/$cmd/;
}
createNewFolder("$count_path");
#recurse through all the files
#execute in the following order:
# 1. generateCountFile()
# 2. generateLMFile()
# 3. generatePPLs()
sub recurse($)
{
      my($path) = @_;
      ## append a trailing / if it's not there
      $path .= '/' if($path !~ /\/$/);
      ## loop through the files contained in the directory
      for my $eachFile (glob($path.'*'))
      {
	## if the file is a directory
	if( -d $eachFile)
	{
	  ## pass the directory to the routine ( recursion )
	  &recurse($eachFile);
	}
	else
	{
	  generateCountFile($eachFile);
        }
      }
}

## initial call ... $ARGV[0] is the first command line argument
#ARGV[0] is filepath for training files, count files or test files
recurse($training_path);


