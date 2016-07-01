#!/usr/bin/perl 
use strict;
use File::Basename;
use File::Copy::Recursive qw(dircopy);
require "create_file_hierarchy.pl";
require "variable.pl";

my $path = "/nethome/students/upendra/NLP/MyRun/Data/crossDomain/Mikros_Corpus";
my $src = "/$path/all_data/posts_original";
my %topicsName  = (	
			'c'		=> 'culture',
			'p'		=> 'politics',			
		 );

my %topicToFiles = ();

sub readAllFiles    ## read all files, shuffle and store in array @files.
{
	my $path = $_[0];
	$path .= '/' if ( $path !~ /\/$/ );
	my @allFiles = glob( $path . '*.txt' );
	foreach my $file(@allFiles)
	{
		my $topic = getTopicName("$file");	
		my $author = getAuthorName("$file");	
		my ( $fname, $folder ) = fileparse($file);
			my @files = ();
			@files = @{$topicToFiles{$topic}} if ( exists $topicToFiles{$topic});
			my ( $fname, $folder ) = fileparse($file);
			push @files, $fname;
			$topicToFiles{$topic} = \@files; 
		
			
			#print "$fname\t$author\t\t$topic\n";

	}
	foreach my $key(keys %topicToFiles)
	{
		my @values = @{$topicToFiles{$key}};
	#	print"$key\n\t".join("\t",@values)."\n\n";
	#	print"$key\n\t".scalar(@values)."\n\n";
	}
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub createLabels
{
	my @topics = keys %topicsName;
	
	foreach my $i (0..$#topics)
	{
		my $testTopic = $topics[$i];
		my $topicPath = "$path/$topicsName{$testTopic}";
		my @trainTopics = ();
		my @testFiles = @{$topicToFiles{$testTopic}};
		my @trainFiles = ();
		foreach my $j (0..$#topics)
		{
			if($i!=$j)
			{
				push @trainTopics, $topics[$j];
				push @trainFiles, @{$topicToFiles{$topics[$j]}};
			}
		}
	#	print "Test\t$testTopic\nTrain\t".join("\t", @trainTopics)."\n\n";
	
	#	print "$topicPath\n";

		createNewFolder("$topicPath");
		createNewFolder("$topicPath/labels");
		my @rclassTest =  ();
		my @rclassTrain = ();
		
		
		open( TESTLABEL, ">$topicPath/labels/rlabel_test.txt" ) or die("Can't open $topicPath/labels/rlabel_test.txt");
		open( TESTCLASS, ">$topicPath/labels/rclass_test.txt" ) or die("Can't open $topicPath/labels/rclass_test.txt");
		open( TRAINLABEL, ">$topicPath/labels/rlabel_train.txt" ) or die("Can't open $topicPath/labels/rlabel_train.txt");
		open( TRAINCLASS, ">$topicPath/labels/rclass_train.txt" ) or die("Can't open $topicPath/labels/rclass_train.txt");
        
		print TESTLABEL join("\n",@testFiles);
		print TRAINLABEL join("\n",@trainFiles);
		
		foreach my $i(0..$#testFiles)
		{
				push @rclassTest, getAuthorName($testFiles[$i]);
		}
		
		foreach my $i(0..$#trainFiles)
		{
			push @rclassTrain, getAuthorName($trainFiles[$i]);
		}

		print TESTCLASS join("\n",@rclassTest);
		print TRAINCLASS join("\n",@rclassTrain);

	}

}


readAllFiles($src);
createLabels
