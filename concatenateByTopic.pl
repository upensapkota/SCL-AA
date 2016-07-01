#!/usr/bin/perl 
use strict;
use POSIX qw(ceil floor);
use List::Util qw/shuffle/; 
use File::Basename;
use File::Find;
use File::Copy::Recursive qw(dircopy);
require "create_file_hierarchy.pl";
require "variable.pl";#require "fileNameFormat.pl";


# perl concatenateByTopic.pl /nethome/students/upendra/NLP/MyRun/Data/crossDomain/crossTopic noConcatenation concatenation


my $mainPath		= $ARGV[0];# //nethome/students/upendra/NLP/MyRun/Data/crossDomain/crossTopic
my $srcFolder		= $ARGV[1];# noConcatenation
my $dstFolder		= $ARGV[2]; #concatenation

my $srcPath = "$mainPath/$srcFolder";
my $dstPath = "$mainPath/$dstFolder";

createNewFolder("$dstPath/all_data/posts_original");

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub createProfiles
{
	my $currentPath = "$srcPath/all_data/posts_original";
	$currentPath .= '/' if ( $currentPath !~ /\/$/ );
	my @postNames = glob( $currentPath . '*.txt' );

	foreach my $file (@postNames)
	{

		my ( $fname, $folder ) = fileparse($file);
		my $topic = getTopicName("$fname");	
		my $author = getAuthorName("$fname");
		print "$fname \t author:$author \t topic:$topic\n";
		open(FH,"<$file") or die("Could not open $file");
		my($file_contents) = do { local $/; <FH> };
		close (FH);
		open(PROFILE,">> $dstPath/all_data/posts_original/$author$topic.txt") or die("Can't create $dstPath/all_data/posts_original/$author$topic.txt");
		print PROFILE "$file_contents\n";
		close (PROFILE);
	}

        
}

createProfiles();
