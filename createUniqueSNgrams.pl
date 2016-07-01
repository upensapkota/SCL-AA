#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
my $n_for_word_ngrams = 1;
my $min_n_for_word_ngrams = 1;

our($numberOfSNGrams);

use File::Basename;
use File::Find;


#/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/sngrams $runPath/labels/rlabel_train.txt $runPath/vocab semlabels.txt") ;
=pod
my $src        = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/sngrams";#$ARGV[0];
my $rlabel     = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/TwoTopics_P/Sexdisc-Marijuana/labels/rlabel_train.txt";#$ARGV[1];
my $dest       = "/home/upendra/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/TwoTopics_P/Sexdisc-Marijuana/vocab";#$ARGV[2];
my $vocab_file = "semlabels.txt";#$ARGV[3];
=cut

my $src        = $ARGV[0];
my $rlabel     = $ARGV[1];
my $dest       = $ARGV[2];
my $vocab_file = $ARGV[3];

$vocab_file = $dest."/".$vocab_file;

my @allFiles = ();
my %stopWords = ();
my $stopFile = "/home/upendra/MOOD_AND_STOP_WORDS/stop_words.txt";

my $ngrams = 2;
my %map = ();            ## per sentence
my %numberToWords = ();  ## per sentence
my %numberToTags = ();   ## per sentence
my %uniqueSNGrams = ();  ## all files
my $unique_ngrams = "";  ## global

createNewFolder($dest) if (!(-e "$dest"));   
readRLabel();
readStop();
findSNGrams();
#createUnique();

sub readStop
{
    open(STOP,"< $stopFile") or die("Could not open $stopFile:$!");  
    foreach my $line(<STOP>)
    {
        $stopWords{trim($line)}++;
    }
    close(STOP);
}


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readRLabel
{
    open(RLABEL,"< $rlabel") or die("Could not open $rlabel:$!");  
    foreach my $line(<RLABEL>)
    {
        push(@allFiles,"$src/".trim($line));
    }
	 print "Total train files:".@allFiles."\n";
    close(RLABEL);
}


sub findSNGrams
{
  	open(UNIQUE,">$vocab_file") or die("Can't open $vocab_file: $!");
	foreach my $file(@allFiles)
	{
		open(FILE,"<$file") or die("Not exists $file\n");
		my ($file_contents) = do { local $/; <FILE> };
		$file_contents = trim($file_contents);
		close(FILE);
		my @contents = split(/\n{2,}/,$file_contents);  ## split the file contents by two new lines, that means one one blank line
		my  $sentenceCount = 1;

		for(my $i = 0; $i < $#contents; $i = $i+2) ## for each sentence
		{

			%numberToWords = ();
			%numberToTags = ();
			%map = ();

			my $j = $i+1;
			my $tree = $contents[$i];
			my $dep = $contents[$j];
			%numberToWords = ();
			my @depSplit = split("\n",$dep);
			foreach my $d(@depSplit)  ## for each deptagency parsed line
			{
				$d =~ /(.*?)\((.*?)-(.*?),(.*?)-(.*?)\)/;

				my $relation = $1;
				my $headWord = $2;
				my $headPosition= $3;
				my $mainWord = $4;
				my $mainWordPosition = $5;
				$numberToWords{$mainWordPosition} = trim($mainWord);
				$numberToTags{$mainWordPosition} = trim($relation);
				my @values = ();
				@values = @{$map{$headPosition}} if exists $map{$headPosition};
				push (@values, "$mainWordPosition->$relation");
				$map{$headPosition}= \@values;
		
			}
			foreach my $headPosition(keys %map)
			{
				my @values = @{$map{$headPosition}};
				#print "$headPosition=>(".join(", ",@values).")\n";
			}
			#print "------------------sentence$sentenceCount-------------------\n";
			my @allPaths = findPathsAll(\%map, 0,"NULL");
			foreach my $path_(@allPaths)
			{
				my @path = @$path_;
				for (my $i=0; $i<$#path; $i++)
				{	
					next if $i eq 0;
					my $element1 = $path[$i];
					my $element2 = $path[$i+1];
					#my $bigram = "$numberToTags{$element1}_$numberToTags{$element2}";
					my $bigram = "$numberToWords{$element1}_$numberToWords{$element2}";						
					#print "[$bigram]\t";
					$uniqueSNGrams{$bigram}++;
				}
				#print "\n";
			}
			#print "@$_\n" for @allPaths;

			$sentenceCount++;
		}
	}

	my @sortedSNGrams = sort { $uniqueSNGrams{$b} <=> $uniqueSNGrams{$a} } keys %uniqueSNGrams;
	my @selectedNGrams = @sortedSNGrams;

	if(scalar(@sortedSNGrams) > $numberOfSNGrams)
	{
		@selectedNGrams = @sortedSNGrams[0..$numberOfSNGrams-1];
	}

	foreach my $sngram(@selectedNGrams)
	{
		if($uniqueSNGrams{$sngram} > 1)
		{
			$unique_ngrams = $unique_ngrams."$sngram\n";
		}
	}
	 print UNIQUE $unique_ngrams;
	 #print "$unique_ngrams\n";
  	 close(UNIQUE);
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub findPathsAll {
          my ($graph,$node,$tag) = @_;

          my $findPaths_sub;
          $findPaths_sub = sub {
            my( $seen, $node, $tag ) = @_;
#            return [[$node]] if isLeaf($graph, $node);
            return [[]] if isLeaf($graph, $node);
            $seen->{ $node } = 1;
            my @paths;
            for my $child ( @{ $graph->{ $node } } ) {
		my @split = split(/->/,$child);
		$node = $split[0];
		$tag = $split[1];
              my %seen = %{$seen};
              next if exists $seen{ $node };
              push @paths, [ $node, @$_ ]
                  for @{ $findPaths_sub->( \%seen, $node, $tag ) };
            }
            return \@paths;
          };

          my @all;
          push @all,[@$_]  for @{ $findPaths_sub->( {}, $node, $tag )};
          return @all;
  }





sub isLeaf
{
	my ($mapRef, $node) = @_;
	my $isLeaf = 1;

	$isLeaf = 0 if exists($mapRef->{$node});
	return $isLeaf;
}


