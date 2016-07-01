#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
our ($byteOrCharacterNgram);
our($numberOfCharngrams);
our($n);
my $lowercase  = 0; ## lowercase means lower case all the characters. zero means no lowercase.
my $frequencyThreshold = 5;
#my $frequencyThreshold = 0;

use File::Basename;
use File::Find;

my $src        = $ARGV[0];
my $rlabel     = $ARGV[1];
my $dest       = $ARGV[2];
my $types      = $ARGV[3];

print "@$types\n";


my $prefixFile = $dest."/char${n}Prefixlabels.txt";
my $multiWordFile = $dest."/char${n}MultiWordlabels.txt";
my $entireWordFile = $dest."/char${n}EntireWordlabels.txt";
my $suffixFile = $dest."/char${n}Suffixlabels.txt";
my $middleFile = $dest."/char${n}Middlelabels.txt";
my $spaceBegFile = $dest."/char${n}SpaceBeglabels.txt";
my $spaceEndFile = $dest."/char${n}SpaceEndlabels.txt";
my $punctBegFile = $dest."/char${n}PunctBeglabels.txt";
my $punctEndFile = $dest."/char${n}PunctEndlabels.txt";
my $punctMiddleFile = $dest."/char${n}PunctMiddlelabels.txt";
my $allNgramsFile = $dest."/char${n}ngramlabels.txt";
my $otherFile = $dest."/char${n}Otherlabels.txt";



my $unique_ngrams = "";
my @posts_names = ();


my %length_freq;

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

my $replaceSpaceWith = " ";


createNewFolder($dest) if (!(-e "$dest"));   
readRLabel();
#createUnique();
createUniqueManual();


print "$chartype\n";

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readRLabel()
{
    open(RLABEL,"< $rlabel") or die("Could not open $rlabel:$!");  
    foreach my $line(<RLABEL>)
    {
        push(@post_names,"$src/".trim($line));
    }
    close(RLABEL);
}


sub createUniqueManual
{

	foreach my $file (@post_names)
	{
		#print "$file\n";
		open(WORD,"< $file") or die("Could not open $file");
		my($s) = do { local $/; <WORD> };
		$s =~ s/\s+/$replaceSpaceWith/g;
		my $l = length $s;
		$length_freq{$l}++;
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

				#print "current: \t*$nPlus2Chars*\t$currentNgram\n";
				$ngram_freq {$currentNgram}++;

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
					$prefix_freq{$currentNgram}++;
					#print "Prefix\t*$nPlus2Chars*\t$currentNgram\n"
				}
				elsif($nPlus2Chars =~ m/\w$currentNgram\b/g)
				{
					$suffix_freq {$currentNgram}++;
					#print "Suffix\t*$nPlus2Chars*\t$currentNgram\n"
				}
				else
				{
					#die("There are more\n");
					$other_freq {$currentNgram}++;
					#print "Other\t*$nPlus2Chars*\t$currentNgram\n"
				}


=pod
				my $testCount = 0;
				$testCount++ if defined $other_freq {$currentNgram};
				$testCount++ if defined $multiWord_frq{$currentNgram};
				$testCount++ if defined $entire_freq {$currentNgram};
				$testCount++ if defined $prefix_freq {$currentNgram};
				$testCount++ if defined $suffix_freq {$currentNgram};
				$testCount++ if defined $otherPunct_freq {$currentNgram};
				$testCount++ if defined $middle_freq {$currentNgram};
				print "Test count: $testCount ($currentNgram)\n" if $testCount > 1;
=cut

			}
	   	 }
	 }

        printNgrams($prefixFile, \%prefix_freq); 
        printNgrams($multiWordFile, \%multiWord_freq); 


        printNgrams($spaceBegFile, \%spaceBeg_freq); 
        printNgrams($spaceEndFile, \%spaceEnd_freq); 

        printNgrams($entireWordFile, \%entire_freq); 
        printNgrams($suffixFile, \%suffix_freq); 
 #       printNgrams($otherPunctFile, \%otherPunct_freq); 



        printNgrams($punctBegFile, \%punctBeg_freq); 
        printNgrams($punctEndFile, \%punctEnd_freq); 
        printNgrams($punctMiddleFile, \%punctMiddle_freq); 


        printNgrams($middleFile, \%middle_freq); 
        printNgrams($otherFile, \%other_freq); 
        printNgrams($allNgramsFile, \%ngram_freq); 

 
}

sub printNgrams
{
	my ($file, $ngramMapRef) = @_;
	my %map = %$ngramMapRef;

	open(UNIQUE,">$file") or die("Can't open $file: $!");
	#print "$file\n";
	my $unique_ngrams = "";
	my $count = 0;
	foreach my $ngram(sort {$map{$b}<=>$map{$a}}keys %map)
	{
		#print "$ngram\n";
		my $newNgram = $ngram;
		$newNgram =~ s/\s+/_/g; ## in vocab file, replace all spaces with underscores. 
		$unique_ngrams = $unique_ngrams."$newNgram\n" if ($map{$ngram} >= $frequencyThreshold);
	}

	print UNIQUE $unique_ngrams;
	close(UNIQUE);

}






