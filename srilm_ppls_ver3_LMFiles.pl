#!/usr/bin/perl
use strict;
require "create_file_hierarchy.pl";

my $count_path	=$ARGV[0];
my $lm_path	=$ARGV[1];

createNewFolder("$lm_path");
#generates LMs
sub generateLMFile($)
{
    my(@path) = split(/\//,"@_");
    my $temp="$lm_path$path[scalar(@path)-1]";
    my($cmd)="ngram-count -wbdiscount -read @_  -order 4 -lm $temp";
     qx/$cmd/;
}

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
	  generateLMFile($eachFile);
        }
      }
}

## initial call ... $ARGV[0] is the first command line argument
#ARGV[0] is filepath for training files, count files or test files
recurse($ARGV[0]);


