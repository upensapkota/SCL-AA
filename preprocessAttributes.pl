#!/usr/bin/perl 
use strict;
require "create_file_hierarchy.pl";
my $label_file 	= $ARGV[0];
my $type 	= $ARGV[1];
use Encode;

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


#
# This function takes any label file and preprocess it so that weka will not give exception while classifying.
#
sub preprocess
{
	my $file_path = $_[0];
	open FILE, "<$file_path" or die "Not Found: $file_path $!\n";
	open OUT,  ">temp.txt"   or die "$!\n";
	foreach my $line (<FILE>)
	{
	   chomp($line);
	  # $line = decode_utf8( $line );
	   $line =~ s/\s+//g;
	   $line =~ s/\,/commaPunct/g;
	   $line =~ s/\./periodPunct/g;
	   $line =~ s/\:/colonPunct/g;
	   $line =~ s/\'/sqPunct/g;
	   $line =~ s/\"/dqPunct/g;
	   $line =~ s/\*/asterickPunct/g;
	   $line =~ s/\%/percentPunct/g;
	   $line =~ s/\{/opencurlyPunct/g;
	   $line =~ s/\}/closecurlyPunct/g;
	   $line =~ s/\(/leftParenthesisPunct/g;
	   $line =~ s/\)/rightParenthesisPunct/g;
	   $line =~ s/\[/leftBracketPunct/g;
	   $line =~ s/\]/rightBracketPunct/g;
	   $line =~ s/\//backslashPunct/g;
	   $line =~ s/\\/forwardSlashPunct/g;
	   $line = ${line}."${type}\n";
	  # print $line;
	   print OUT $line;
	}
	close FILE;
	close OUT;
	unlink($file_path);
	rename( "temp.txt", $file_path ) or die "Error in rename: $!\n";
}

#print "Processing attributes for label file: $label_file\n";
preprocess($label_file);
