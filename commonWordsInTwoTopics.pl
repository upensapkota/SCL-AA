#!/usr/bin/perl 
use strict;
require "create_file_hierarchy.pl";

my $directory_path = $ARGV[0];
my $fname 	   = $ARGV[1]; #cbc_5, cbc_10, cbc_20, cbc_50, cbc_100

my $numberOfSemanticFeatures = 10000;
my %stopWords = ();

#my @folders = ("T50115-T50013","T50013-T50115");#,"T50048-T50128","T50128-T50048");
#my @folders = ("Marijuana-Sexdisc", "Sexdisc-Marijuana","Iraqwar-Sexdisc", "Sexdisc-Iraqwar","Church-Gay", "Gay-Church");
#my @folders = ("Marijuana-Sexdisc", "Sexdisc-Marijuana");
#my @folders = ("Iraqwar-Sexdisc", "Sexdisc-Iraqwar");
#my @folders = ("Church-Gay", "Gay-Church");
#my @folders = ("culture", "politics");


my $outputPath = "/home/upendra/CROSS-DOMAIN/Experiments/commonWordsBetweenTopics_singleGenreChunked";

#my $topic1 = "T50115-T50013";
#my $topic2 = "T50013-T50115";


#my $topic1 = "T50048-T50128";
#my $topic2 = "T50128-T50048";


my $topic1 = "Marijuana-Sexdisc";
my $topic2 = "Sexdisc-Marijuana";


#my $topic1 = "Iraqwar-Sexdisc";
#my $topic2 = "Sexdisc-Iraqwar";


#my $topic1 = "Church-Gay";
#my $topic2 = "Gay-Church";


my $stopFile = "/home/upendra/MOOD_AND_STOP_WORDS/stop_words.txt";


# perl commonWordsInTwoTopics.pl /home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/ TwoTopics


main();

sub readStop
{
    open(STOP,"< $stopFile") or die("Could not open $stopFile:$!");  
    foreach my $line(<STOP>)
    {
        $stopWords{trim($line)}++;
    }
    close(STOP);
}

sub main
{
	readStop();
	my @authors = findAllAuthors ();
	print "----------$topic1----------------\n";
	open(COMMON, "> $outputPath/commonwords_${topic1}_authors.txt") or ("$!\n");
#	createNewFolder("$outputPath/$topic1") if (!(-e "$outputPath/$topic1"));

	foreach my $authorname(@authors)
	{
		unlink("$outputPath/$topic1/${authorname}_$topic1.txt") ;
		unlink("$outputPath/$topic1/${authorname}_$topic2.txt") ;
		unlink("$outputPath/$topic1/commonwords_${authorname}.txt");

	}
	#createAuthorProfiles($topic1);
	#createAuthorProfiles($topic2);


 	foreach my $author(@authors)
	{
		my $map1 = getMapOfAllWords("$topic1",$author);
		my $map2 = getMapOfAllWords("$topic2",$author);
		my @keys1 = keys %$map1;
		my @keys2 = keys %$map2;
		my @common_keys = grep { exists $map1->{$_} } keys( %{ $map2 } );
=pod
		open(COMMONWORDS, "> $outputPath/$1/commonwords_${author}.txt") or ("$!\n");
		foreach my $common(@common_keys)
		{
	       		 print COMMONWORDS "$common\t$map1->{$common}\t$map2->{$common}\n";
		}
=cut
		print COMMON "$author\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\n";
		print  "$author\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\n";
	}


}
sub findAllAuthors
{
	my $runPath = "$directory_path$fname/$topic1";
	my %classes = ();
	open(RCLASS,"< $runPath/labels/rclass_train.txt") or die("Could not open $runPath/labels/rclass_train.txt");  
	foreach my $line(<RCLASS>)
	{
		$classes{trim($line)}++;
	}
	return keys %classes;
	
}


sub createAuthorProfiles
{
	my $dataset = $_[0];
	my %unique_words = ();
	my $runPath = "$directory_path$fname/$dataset";
	my $allFiles = readRLabel("$runPath/labels/rlabel_train.txt");
	my %authorMap = getAuthorMap("$runPath/labels/rlabel_train.txt","$runPath/labels/rclass_train.txt");


	foreach my $file(@$allFiles)
	{
		my $filePath = "$directory_path$fname/all_data/processedData/$file";
		#print "file: $file\n";
		my $authorname = $authorMap{$file};
		#print "$dataset\t$authorname\n";

		my $folder = "processedData";
		open(FH,"< $filePath") or die("Could not open $filePath");
		my($file_contents) = do { local $/; <FH> };

		if($authorname eq "A100023" && $dataset eq "T50048-T50128")
		{
			print "$file_contents\n\n";
		}

		close (FH);
		open(PROFILE,">> $outputPath/$topic1/${authorname}_$dataset.txt") or die("Could not open $outputPath/$topic1/${authorname}_$dataset.txt");
		print PROFILE "$file_contents\n";
		close (PROFILE);
	}

}


sub getMapOfAllWords
{
	my ($dataset, $author) = @_;
	#my $dataset = $_[0];
	#my $author = $_[1];
	my %unique_words = ();
	my $runPath = "$directory_path$fname/$dataset";
        my $allFiles = readRLabel("$runPath/labels/rlabel_train.txt");
        my %authorMap = getAuthorMap("$runPath/labels/rlabel_train.txt","$runPath/labels/rclass_train.txt");
	
	my @selectedTerms = ();
	foreach my $file_path(@$allFiles)
	{
		if($authorMap{$file_path} eq $author)   ## compute for the file if its author is the given author.
		{
			open(WORD,"< $directory_path$fname/all_data/processedData/$file_path") or die("Could not open $file_path");
			my($file_contents) = do { local $/; <WORD> };
			my @words = split(/\s+/, $file_contents);
			close(WORD);
			foreach my $word (@words)
			{
				$word = lc($word);
				$word = trim($word);
				$word =~ s/^\P{L}+//;  # remove initial non-letters
	    			$word =~ s/\P{L}+$//;  # remove final non-letters
				$unique_words{$word}++ if (!(exists $stopWords{$word}));
			}
		}

	}

	return \%unique_words;
     
}


sub readRLabel
{
	my $rlabel = $_[0];
	my @post_names = ();
	open(RLABEL,"< $rlabel") or die("Could not open $rlabel:$!");  
	foreach my $line(<RLABEL>)
	{
		push(@post_names,trim($line));
	}
	close(RLABEL);
	return \@post_names;
}


sub getAuthorMap
{
	my ($rlabel,$rclass) = @_;
	my @post_names = ();
	my @classes = ();
	my %authorMap = ();
	open(RLABEL,"< $rlabel") or die("Could not open $rlabel:$!");  
	foreach my $line(<RLABEL>)
	{
	push(@post_names,trim($line));
	}
	close(RLABEL);

	open(RCLASS,"< $rclass") or die("Could not open log file:$!");  
	foreach my $line(<RCLASS>)
	{
	push(@classes,trim($line));
	}

	close(RCLASS);

	foreach my $i(0..$#classes)
	{
		$authorMap{$post_names[$i]} = $classes[$i];
	}
	return %authorMap;
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


    #print "***************END***********************\n";
