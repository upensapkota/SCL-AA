#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
my $n_for_word_ngrams = 1;
my $min_n_for_word_ngrams = 1;

our($numberOfSemanticFeatures);

print "$numberOfSemanticFeatures\n";;

use File::Basename;
use File::Find;

my $src        = $ARGV[0];
my $rlabel     = $ARGV[1];
my $dest       = $ARGV[2];
my $vocab_file = $ARGV[3];
my $stopFileN  = $ARGV[4];

my $stopFile   = $dest."/".$stopFileN; 

$vocab_file = $dest."/".$vocab_file;

my $unique_ngrams = "";
my @posts_names = ();

my %stopWords = ();

#my $stopFile = "/home/upendra/NLP/MOOD_AND_STOP_WORDS/stop_words.txt";

createNewFolder($dest) if (!(-e "$dest"));   
readRLabel();
readStop();
createUnique();

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

sub readRLabel()
{
    open(RLABEL,"< $rlabel") or die("Could not open $rlabel:$!");  
    foreach my $line(<RLABEL>)
    {
        push(@post_names,"$src/".trim($line));
    }
    close(RLABEL);
}



sub createUnique
{
  open(UNIQUE,">$vocab_file") or die("Can't open $vocab_file: $!");
  my $ng3 = Text::Ngrams->new( type => word, windowsize => $n_for_word_ngrams );

  #$ng3->process_text("I am a boy. I am a girl.");
  $ng3->process_files(@post_names);
  #print $ng3->to_string;
  #my @ngramsarray = $ng3->get_ngrams(orderby=>'frequency',normalize=>1);

  my %uniqueMap = ();

  for(my $ngram = $min_n_for_word_ngrams; $ngram <=$n_for_word_ngrams; $ngram++)
  {
	 #print "---------$ngram-grams---------\n";
	 my @ngramsarray = $ng3->get_ngrams(n=>$ngram,orderby=>'frequency', onlyfirst=>$numberOfSemanticFeatures);	  
	 #print "$#ngramsarray\n";
	 for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	 {
		 my $j = $i+1;
	 	#print "$ngramsarray[$i] $ngramsarray[$j]\n";
                my $current_ngram = $ngramsarray[$i];
		my $frequency = $ngramsarray[$j];
		$current_ngram = lc($current_ngram);
		if (!(exists $uniqueMap{$current_ngram}) && !(exists $stopWords{$current_ngram}) && length($current_ngram)>1 && $frequency > 2)
		{
			$unique_ngrams = $unique_ngrams."$current_ngram\n" 
		}
		#print "$unique_ngramsn";
		$uniqueMap{$current_ngram}++;
	 }
  }
  
  #print $unique_ngrams;
  print UNIQUE $unique_ngrams;
  close(UNIQUE);
 
}


