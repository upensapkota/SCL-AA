#!/usr/bin/perl 
use strict;
require "create_file_hierarchy.pl";
####
#### finds the percentage of common features in each modality (sem, char, mood, and stop) between two topics as well as for each author.
####
my $directory_path = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/";
my $fname 	   = $ARGV[0]; #TwoTopics_B

my $totalNgrams = 10000;
my $modality = "sem";
my %stopWords = ();
my %moodWords = ();


use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
our ($byteOrCharacterNgram);
our($numberOfCharngrams);
my $n_for_char_ngrams = 3;
my $n_for_word_ngrams = 1;
my $min_n_for_word_ngrams = 1;

my %topicsName  = (	
			'M'		=> 'Marijuana',
			'S'		=> 'Sexdisc',			
			'I'		=> 'Iraqwar',
			'C'		=> 'Church',
			'G'		=> 'Gay',	
			'P'		=> 'Privacy',	


		 );


my $outputPath = "/home/upendra/CROSS-DOMAIN/Experiments/commonWordsBetweenTopics_singleGenreChunked";

my $topic1 = "Marijuana-Sexdisc";
my $topic2 = "Sexdisc-Marijuana";

my %crossTopicOrder  = (	
			'Marijuana'		=> ['Privacy','Church','Iraqwar','Sexdisc','Gay'],
			'Iraqwar'		=> ['Sexdisc','Privacy','Marijuana','Gay','Church'],			
			'Gay'		=> ['Privacy','Iraqwar','Marijuana','Sexdisc','Church'],
			'Church'		=> ['Sexdisc','Gay','Marijuana','Iraqwar','Privacy'],
			'Sexdisc'		=> ['Privacy','Iraqwar','Marijuana','Gay','Church'],	
			'Privacy'		=> ['Iraqwar','Gay','Church','Marijuana','Sexdisc'],
		 );

my @testTopicOrder = ('Marijuana','Iraqwar','Gay','Church','Sexdisc','Privacy');


our %modalities 	=('sem'		=> \&semantic,
			  'charngram'   => \&charngram, 
			  'mood'    	=> \&mood,
			  'stop'    	=> \&stop, 
			);
my @modalityOrder = ('sem','stop','mood','charngram');
#my @modalityOrder = ('stop','sem','charngram');




my $stopFile = "/home/upendra/MOOD_AND_STOP_WORDS/stop_words.txt";
my $moodFile = "/home/upendra/MOOD_AND_STOP_WORDS/unique_mood_words.txt";


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


sub readMood
{
    open(STOP,"< $moodFile") or die("Could not open $moodFile:$!");  
    foreach my $line(<STOP>)
    {
        $moodWords{trim($line)}++;
    }
    close(STOP);
}  


sub readVocabFile
{
	my $vocab_file = $_[0];
	my @unique_ngrams = ();
	open( VECTOR, "< $vocab_file" ) or die("Could not open log file:$!");
	foreach (<VECTOR>)
	{
		push( @unique_ngrams, trim($_) );
	}
	close(VECTOR);
	return @unique_ngrams;
}

sub main
{
	readStop();
	readMood();
	my @topics = keys %topicsName;

	print "Test Topic\t Train Topic\t".join("\t\t\t\t",@modalityOrder)."\n";
	print "\t\tfractionAVG\tfractionSTD\tjaccardAVG\tjaccardSTD\tfractionAVG\tfractionSTD\tjaccardAVG\tjaccardSTD\tfractionAVG\tfractionSTD\tjaccardAVG\tjaccardSTD\tfractionAVG\tfractionSTD\tjaccardAVG\tjaccardSTD\n";


	foreach my $i (0..$#topics)
	{
		my $trainTopic = $topicsName{$topics[$i]};
		foreach my $j (0..$#topics)
		{
			if($i!=$j)
			{
				my $testTopic = $topicsName{$topics[$j]};
				my @authors = findAllAuthors("$trainTopic-$testTopic");
				foreach my $authorname(@authors)
				{
					unlink("$outputPath/authorProfiles/$fname/${authorname}_$trainTopic.txt") ;

				}
				createAuthorProfiles($trainTopic,$testTopic);
				last;
			}

		}
	}

#	foreach my $i (0..$#topics)
#	{
#		my $testTopic = $topicsName{$topics[$i]};
	foreach my $testTopic(@testTopicOrder)
	{
		print "$testTopic";

		my @otherTainTopics = @{$crossTopicOrder{$testTopic}};


		foreach my $trainTopic (@otherTainTopics)
		{
			print "\t$trainTopic";
			my @authors = findAllAuthors("$trainTopic-$testTopic");
			foreach my $modality(@modalityOrder)
			{
				my $totalPercentPerTopic = 0;
				#print "----$modality----\n";
				my @commonPercent = ();
				my @jaccards = ();
				foreach my $authorname(@authors)
				{
					my $map1 = $modalities{$modality}->("$outputPath/authorProfiles/$fname/${authorname}_$trainTopic.txt");
					my $map2 = $modalities{$modality}->("$outputPath/authorProfiles/$fname/${authorname}_$testTopic.txt");
					my @keys1 = keys %$map1;
					my @keys2 = keys %$map2;
					my @common_keys = grep { exists $map1->{$_} } keys( %{ $map2 } );

					#print COMMON "$author\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\n";

					my $commonCount = scalar(@common_keys);
					my $smallTotalCount = scalar(@keys1);
					$smallTotalCount = scalar(@keys2) if(scalar(@keys1) > scalar(@keys2));
					$smallTotalCount = 1 if $smallTotalCount ==0;
					my $percent = $commonCount/$smallTotalCount;
					$percent = sprintf "%.2f", $percent;
					push (@commonPercent, $percent);
					my $jaccard = $commonCount/(scalar(@keys1)+scalar(@keys2)-$commonCount);
					push (@jaccards,$jaccard);
					#print  "$authorname\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\t$percent\n";

						
				}
				my $averagePercentPerTopic = &average(\@commonPercent);
				my $stdPerTopic = &stdev(\@commonPercent);

				my $jaccardAverage = &average(\@jaccards);
				my $jaccardStd = &stdev(\@jaccards);
	
				print "\t$averagePercentPerTopic\t$stdPerTopic\t$jaccardAverage\t$jaccardStd";
			
			}
			print "\n";

		}
	print "\n\n";
	}

sub average
{
	my($data) = @_;
	if (not @$data) 
	{
		die("Empty array\n");
	}
	my $total = 0;
	foreach (@$data) 
	{
		$total += $_;
	}
	my $average = $total / @$data;
	$average = sprintf "%.2f", $average;
	return $average;
}
sub stdev
{
	my($data) = @_;
	if(@$data == 1)
	{
		return 0;
	}
	my $average = &average($data);
	my $sqtotal = 0;
	foreach(@$data) 
	{
		$sqtotal += ($average-$_) ** 2;
	}
	my $std = ($sqtotal / (@$data-1)) ** 0.5;
	$std = sprintf "%.2f", $std;
	return $std;
}


=pod

	foreach my $author(@authors)
	{
		my $map1 = getMapOfAllWords("$topic1",$author);
		my $map2 = getMapOfAllWords("$topic2",$author);
		my @keys1 = keys %$map1;
		my @keys2 = keys %$map2;
		my @common_keys = grep { exists $map1->{$_} } keys( %{ $map2 } );

#		open(COMMONWORDS, "> $outputPath/$1/commonwords_${author}.txt") or ("$!\n");
#		foreach my $common(@common_keys)
#		{
#	       		 print COMMONWORDS "$common\t$map1->{$common}\t$map2->{$common}\n";
#		}
		print COMMON "$author\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\n";
		print  "$author\t". scalar(@keys1)."\t".scalar(@keys2)."\t".scalar(@common_keys)."\n";
	}
=cut

}


sub findAllAuthors
{
	my $dataset = $_[0];
	my $runPath = "$directory_path$fname/$dataset";
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
	my ($trainTopic, $testTopic) = @_;
	my $dataset = "$trainTopic-$testTopic";
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
		close (FH);

		createNewFolder("$outputPath/authorProfiles/$fname") if (!(-e "$outputPath/authorProfiles/$fname"));
		open(PROFILE,">> $outputPath/authorProfiles/$fname/${authorname}_$trainTopic.txt") or die("Could not open$outputPath/authorProfiles/$fname/${authorname}_$trainTopic.txt");
		print PROFILE "$file_contents\n";
		close (PROFILE);
#		print "${authorname}_$trainTopic.txt\t" if "${authorname}_$trainTopic" eq "S1_Privacy";
	}


}


sub semantic
{
	my $authorProfile = $_[0];
	my %unique_words = ();
=pod
	my @selectedTerms = ();
	open(WORD,"< $authorProfile") or die("Could not open $authorProfile");
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
=cut
	  my $ng3 = Text::Ngrams->new( type => 'word', windowsize => $n_for_word_ngrams );
	$ng3->process_files($authorProfile);

	my @ngramsarray = $ng3->get_ngrams(n=>$n_for_word_ngrams,orderby=>'frequency', onlyfirst=>$totalNgrams);	  
	for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	{
		my $j = $i+1;
		my $current_ngram = $ngramsarray[$i];
		my $frequency = $ngramsarray[$j];
		$unique_words{$current_ngram} = $frequency;
		
	}

	foreach my $key(keys %unique_words)
	{
		delete $unique_words{$key} if $unique_words{$key}<3;;
	}
	return \%unique_words;
     
}


sub stop
{
	my $authorProfile = $_[0];
	my %unique_words = ();
	my @selectedTerms = ();


	open(WORD,"< $authorProfile") or die("Could not open $authorProfile");
	my($file_contents) = do { local $/; <WORD> };
	my @words = split(/\s+/, $file_contents);
	close(WORD);
	foreach my $word (@words)
	{
		$word = lc($word);
		$word = trim($word);
		$word =~ s/^\P{L}+//;  # remove initial non-letters
		$word =~ s/\P{L}+$//;  # remove final non-letters
		$unique_words{$word}++ if (exists $stopWords{$word});
	}
	return \%unique_words;

	
}


sub mood
{
	my $authorProfile = $_[0];
	my %unique_words = ();
	my @selectedTerms = ();
	open(WORD,"< $authorProfile") or die("Could not open $authorProfile");
	my($file_contents) = do { local $/; <WORD> };
	my @words = split(/\s+/, $file_contents);
	close(WORD);
	foreach my $word (@words)
	{
		$word = lc($word);
		$word = trim($word);
		$word =~ s/^\P{L}+//;  # remove initial non-letters
		$word =~ s/\P{L}+$//;  # remove final non-letters
		$unique_words{$word}++ if (exists $moodWords{$word});
	}
	return \%unique_words;

	
}


sub charngram
{
	my $authorProfile = $_[0];
	my %unique_ngrams = ();
	my $ng3 = Text::Ngrams->new( type => $byteOrCharacterNgram, windowsize => $n_for_char_ngrams );
	$ng3->process_files($authorProfile);

	my @ngramsarray = $ng3->get_ngrams(n=>$n_for_char_ngrams,orderby=>'frequency', onlyfirst=>$totalNgrams);	  
	for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	{
		my $j = $i+1;
		my $current_ngram = $ngramsarray[$i];
		my $frequency = $ngramsarray[$j];
		$unique_ngrams{$current_ngram} = $frequency;
		
	}
	return \%unique_ngrams;
 
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
