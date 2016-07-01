#!/usr/bin/perl 

require "NormalizeMatrixByFeatures.pl";
require "create_file_hierarchy.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use File::Basename;
use File::Find;
use Text::Ngrams;
our ($byteOrCharacterNgram);
#my $n = 3;
our($n);

my $src           = $ARGV[0];
my $rlabel        = $ARGV[1];
my $vocab_path    = $ARGV[2];
my $fvPath        = $ARGV[3];
my $cols_avg      = $ARGV[4];
my $testOrTrain   = $ARGV[5];


my @ngramTypes = ("char${n}Prefix", "char${n}MultiWord","char${n}EntireWord", "char${n}Suffix","char${n}SpaceBeg","char${n}SpaceEnd","char${n}PunctBeg","char${n}PunctEnd","char${n}PunctMiddle","char${n}Middle", "char${n}Other","char${n}ngram");


my $prefixFile = $vocab_path."/char${n}Prefixlabels.txt";
my $multiWordFile = $vocab_path."/char${n}MultiWordlabels.txt";
my $entireWordFile = $vocab_path."/char${n}EntireWordlabels.txt";
my $suffixFile = $vocab_path."/char${n}Suffixlabels.txt";
#my $otherPunctFile = $vocab_path."/char${n}OtherPunctlabels.txt";
my $middleFile = $vocab_path."/char${n}Middlelabels.txt";
my $otherFile = $vocab_path."/char${n}Otherlabels.txt";
my $allNgramsFile = $vocab_path."/char${n}ngramlabels.txt";
my $spaceBegFile = $vocab_path."/char${n}SpaceBeglabels.txt";
my $spaceEndFile = $vocab_path."/char${n}SpaceEndlabels.txt";
my $punctBegFile = $vocab_path."/char${n}PunctBeglabels.txt";
my $punctEndFile = $vocab_path."/char${n}PunctEndlabels.txt";
my $punctMiddleFile = $vocab_path."/char${n}PunctMiddlelabels.txt";


my $prefixFv = $fvPath."/char${n}Prefix_$testOrTrain.txt";
my $multiWordFv = $fvPath."/char${n}MultiWord_$testOrTrain.txt";
my $entireWordFv = $fvPath."/char${n}EntireWord_$testOrTrain.txt";
my $suffixFv = $fvPath."/char${n}Suffix_$testOrTrain.txt";
#my $otherPunctFv = $vocab_path."/char${n}OtherPunct_$testOrTrain.txt";
my $middleFv = $vocab_path."/char${n}Middle_$testOrTrain.txt";
my $otherFv = $fvPath."/char${n}Other_$testOrTrain.txt";
my $allNgramsFv = $fvPath."/char${n}ngram_$testOrTrain.txt";
my $spaceBegFv = $fvPath."/char${n}SpaceBeg_$testOrTrain.txt";
my $spaceEndFv = $fvPath."/char${n}SpaceEnd_$testOrTrain.txt";
my $punctBegFv = $fvPath."/char${n}PunctBeg_$testOrTrain.txt";
my $punctEndFv = $fvPath."/char${n}PunctEnd_$testOrTrain.txt";
my $punctMiddleFv = $fvPath."/char${n}PunctMiddle_$testOrTrain.txt";






my $replaceSpaceWith = " ";
my $lowercase = 0; # 0 for no lower case


my $n_for_char_ngrams 		= 3;;
my @post_names = ();
my %allMatrix     = ();
my @row        = ();

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readRLabel()
{
	open( RLABEL, "< $rlabel" ) or die("Could not open log file:$!");
	foreach my $line (<RLABEL>)
	{
		push( @post_names, trim($line) );
	}
	close(RLABEL);
}

sub extractFV
{
	my @unique_ngrams = ();
	my $vocab_file = "";
	my %allVocabMaps = ();
	foreach my $ngramType(@ngramTypes)
	{
		my @vocabNgrams = ();
		$vocab_file = "$vocab_path/${ngramType}labels.txt";
		open( VECTOR, "< $vocab_file" ) or die("Can't find: $vocab_file ($!)\n");

		foreach (<VECTOR>)
		{
			push( @vocabNgrams, trim($_) );
		}
		$allVocabMaps{$ngramType} =\@vocabNgrams;
		close(VECTOR);
	}
	


	foreach my $post (@post_names)
	{
		my %allCurrentNgramsMap = ();
		my %ngram_freq;
		my %prefix_freq;
		my %multiWord_freq;
		my %suffix_freq;
		my %entire_freq;
		#my %otherPunct_freq;
		my %middle_freq;
		my %other_freq;

		my %punctBeg_freq;
		my %punctEnd_freq;
		my %punctMiddle_freq;
		my %spaceEnd_freq;
		my %spaceBeg_freq;

		my $string      = "";
		@row = ();
		my $counter = 0;
		open(WORD,"< ${src}${post}") or die("Could not open ${src}${post}");
		my($s) = do { local $/; <WORD> };
		$s =~ s/\s+/$replaceSpaceWith/g;
		#print "$s\n";
		my $l = length $s;
		if ($l >= $n) 
		{
		    if ($lowercase) 
		    {
			$s = lc $s;
		    }

		    my @n = ();
		    while ($s =~ /(.{$n})/g) 
		    {
				my $currentNgram = $1;
				push @n, $1;
				my $nextPosition = pos($s);
				pos($s) -= $n - 1;
				my $prevPosition = pos($s)-1-1;
		
				my $nPlus2 = $n+2;
				$nPlus2 += $prevPosition if $prevPosition < 0;
				$prevPosition = 0 if $prevPosition < 0;

				my $prevChar = substr($s, $prevPosition, 1);
				my $nPlus2Chars = substr($s, $prevPosition, $nPlus2);
				my $nextChar = substr($s, $nextPosition, 1);

				$ngram_freq{$currentNgram}++;

				if($currentNgram =~ m/\p{IsPunct}/)
				{
					
#					$otherPunct_freq{$currentNgram}++;
					if($currentNgram =~ m/^.+[[:punct:]].+$/)
					{
						$punctMiddle_freq{$currentNgram}++;
						#print "Punct Middle\t$currentNgram\n";
					}
					elsif($currentNgram =~ m/^[[:punct:]]/)
					{
						$punctBeg_freq {$currentNgram}++;
						#print "Punct Begin\t$currentNgram\n";
					}
					elsif($currentNgram =~ m/[[:punct:]]$/)
					{
						$punctEnd_freq {$currentNgram}++;
						#print "Punct end\t$currentNgram\n";
					}
				}
				elsif($currentNgram=~ /$replaceSpaceWith/)
				{
		                        if($currentNgram =~ /^.+$replaceSpaceWith.+$/g)
					{
						$multiWord_freq {$currentNgram}++;
					}
					elsif($currentNgram =~ m/^$replaceSpaceWith/)
					{
						$spaceBeg_freq {$currentNgram}++;
					}
					elsif($currentNgram =~ m/$replaceSpaceWith$/)
					{
						$spaceEnd_freq {$currentNgram}++;
					}
					else
					{
						$other_freq{$currentNgram}++;
					}
				}


				elsif($nPlus2Chars =~ m/\w$currentNgram\w/g)
				{
				  	$middle_freq {$currentNgram}++;
				  	#print "Middle\t*$nPlus2Chars*\t$currentNgram\n";
				}
				elsif($nPlus2Chars =~ m/\b$currentNgram\b/g)
				{
					$entire_freq {$currentNgram}++;
					#print "entire\t*$nPlus2Chars*\t$currentNgram\n";
				}
				elsif($nPlus2Chars =~ m/\b$currentNgram\w/g)
				{
					$prefix_freq {$currentNgram}++;
					#print "Prefix\t*$nPlus2Chars*\t$currentNgram\n"
				}
				elsif($nPlus2Chars =~ m/\w$currentNgram\b/g)
				{
					$suffix_freq {$currentNgram}++;
					#print "Suffix\t*$nPlus2Chars*\t$currentNgram\n"
				}
				else
				{
					$other_freq {$currentNgram}++;
					#print "Other\t*$nPlus2Chars*\t$currentNgram\n"
				}
 


		   	}
		}


		$allCurrentNgramsMap{"char${n}Prefix"} =\%prefix_freq;
		$allCurrentNgramsMap{"char${n}MultiWord"} =\%multiWord_freq;
		$allCurrentNgramsMap{"char${n}EntireWord"} =\%entire_freq;
		$allCurrentNgramsMap{"char${n}Suffix"} =\%suffix_freq;
#		$allCurrentNgramsMap{"char${n}OtherPunct"} =\%otherPunct_freq;
		$allCurrentNgramsMap{"char${n}Middle"} =\%middle_freq;
		$allCurrentNgramsMap{"char${n}Other"} =\%other_freq;
		$allCurrentNgramsMap{"char${n}ngram"} =\%ngram_freq;

		$allCurrentNgramsMap{"char${n}SpaceBeg"} =\%spaceBeg_freq;
		$allCurrentNgramsMap{"char${n}SpaceEnd"} =\%spaceEnd_freq;
		$allCurrentNgramsMap{"char${n}PunctBeg"} =\%punctBeg_freq;
		$allCurrentNgramsMap{"char${n}PunctEnd"} =\%punctEnd_freq;
		$allCurrentNgramsMap{"char${n}PunctMiddle"} =\%punctMiddle_freq;

        	#for each ngram type, extra feature vector for the given post.
		foreach my $ngramType(@ngramTypes)
		{
			my $unique_ngramsRef = $allVocabMaps{$ngramType};
			my @unique_ngrams = @$unique_ngramsRef;

			my %file_ngrams = %{$allCurrentNgramsMap{$ngramType}}; ## one type of ngrams

			my @matrix = ();
			@matrix = @{$allMatrix{$ngramType}} if defined $allMatrix{$ngramType};
			foreach my $unique (@unique_ngrams)
			{
				#print "$unique\n";
				my $count = 0;

				my $replacedUnique = $unique;
				$replacedUnique =~ s/_/ /g; ## while extracting, replace each underscore with a space.

				$count = $file_ngrams{$replacedUnique} if defined $file_ngrams{$replacedUnique};
				#print "$unique: $count\n" if ($count > 0 && $ngramType eq "charOther");
				#print "*$unique*: $count\n" if ($ngramType eq "charOther");
				push @row, $count;

			}
			#print "@row\n" if ($ngramType eq "charOtherPunct");
			push @matrix, [@row];
			undef(@row);
			$allMatrix{$ngramType} = \@matrix;
		}

	}
}



sub writeToFile()
{
	#my @normalized_matrix = normalize($fv_file, $cols_avg, @matrix );
	foreach my $ngramType(@ngramTypes)
	{
		my $fv_file = $fvPath."/${ngramType}_$testOrTrain.txt";
		my @normalized_matrix = @{$allMatrix{$ngramType}} if defined $allMatrix{$ngramType};
		open( VECTOR, "> $fv_file" ) or die("Could not open $fv_file.");
		foreach my $i ( 0 .. $#normalized_matrix )
		{
			print VECTOR "@{$normalized_matrix[$i]}\n";
		}
		close(VECTOR);
		undef(@normalized_matrix);
	}
}

readRLabel();
createNewFolder($dest);
extractFV();
writeToFile();

