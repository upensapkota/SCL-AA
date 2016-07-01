#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
our ($byteOrCharacterNgram);
our($numberOfCharngrams);
our ($threshold_charngram);
my $n_for_char_ngrams = 3;



use File::Basename;
use File::Find;

my $src        = $ARGV[0];
my $rlabel     = $ARGV[1];
my $dest       = $ARGV[2];
my $vocab_file = $ARGV[3];

$vocab_file = $dest."/".$vocab_file;

my $unique_ngrams = "";
my @posts_names = ();

#push (@posts,"/nethome/students/upendra/NLP/MyRun/Data/profile_based/delete/test.txt");
#push (@posts,"/nethome/students/upendra/NLP/MyRun/Data/profile_based/delete/test1.txt");

createNewFolder($dest) if (!(-e "$dest"));   
readRLabel();
createUnique();


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
	my $ng3 = Text::Ngrams->new( type => $byteOrCharacterNgram, windowsize => $n_for_char_ngrams );

	$ng3->process_files(@post_names);

	my @ngramsarray = $ng3->get_ngrams(n=>$n_for_char_ngrams,orderby=>'frequency', onlyfirst=>$numberOfCharngrams);
#	my @ngramsarray = $ng3->get_ngrams(n=>$n_for_char_ngrams,orderby=>'frequency');	  	  
	for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	{
		my $j = $i+1;
		my $current_ngram = $ngramsarray[$i];
		my $frequency = $ngramsarray[$j];
		if ($frequency > $threshold_charngram)
		{
			$unique_ngrams = $unique_ngrams."$current_ngram\n";
		}
		#print "$current_ngram($frequency)\n" if $current_ngram eq "g e ?";
	}

	print UNIQUE $unique_ngrams;
	close(UNIQUE);
 
}


