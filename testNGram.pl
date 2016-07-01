#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;

createUnique();
sub createUnique
{

  my $ng3 = Text::Ngrams->new( type => word, windowsize => 1 );

  $ng3->{tokenrex} = qr/\/?([a-zA-Z]+|(\d+(\.\d+)?|\d*\.\d+)([eE][-+]?\d+)?)/;

                 #m/\/?([^\/]+)$/ and print $1;
                                   
  $ng3->process_text("I/A am/B a/C boy/D ./. I/A am/B a/C girl/D ./.");
  #$ng3->process_files(@post_names);
  #print $ng3->to_string;
  my @ngramsarray = $ng3->get_ngrams(n=>1,orderby=>'frequency');  
=pod
  my %uniqueMap = ();

  for(my $ngram = $min_n_for_word_ngrams; $ngram <=$n_for_word_ngrams; $ngram++)
  {
	 #print "---------$ngram-grams---------\n";
#	 my @ngramsarray = $ng3->get_ngrams(n=>$ngram,orderby=>'frequency', onlyfirst=>$numberOfSemanticFeatures);	
	 my @ngramsarray = $ng3->get_ngrams(n=>$ngram,orderby=>'frequency');  
	 for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	 {
		 my $j = $i+1;
	 	#print "$ngramsarray[$i] $ngramsarray[$j]\n";
                my $current_ngram = $ngramsarray[$i];
		my $frequency = $ngramsarray[$j];
		$current_ngram = lc($current_ngram);
		if (!(exists $uniqueMap{$current_ngram}) && !(exists $stopWords{$current_ngram}) && length($current_ngram)>1 && $frequency >= $frequencyThreshold)
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
=cut
	 for(my $i = 0; $i < $#ngramsarray; $i = $i+2)
	 {
		 my $j = $i+1;
	 	print "$ngramsarray[$i] $ngramsarray[$j]\n";
                
	 }

 
}
