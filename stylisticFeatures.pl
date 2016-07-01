#!/usr/bin/perl 
use strict;
require "NormalizeMatrixByFeatures.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Lingua-EN-Sentence-0.25/lib';

use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS get_acronyms);
use File::Basename;
use File::Find;

my $file_path        = $ARGV[0];
my $mat_file_path    = $ARGV[1];
my $vocabFile        = $ARGV[2];
my $rlabel           = $ARGV[3];
my $cols_avg         = $ARGV[4];
my $dataType         = $ARGV[5];    #if it contains value 'train', name of the file is author name as we are now in profile based approach.

my @matrix         = ();
my @row            = ();
my %postsPerAuthor = ();
my @post_names     = ();
my $debug          = "";
my $features       = "";
my @featuresArray = ();
my $mytotal = 5;
my $authorMap = ();

=pod
my %featuresToSubroutines  = (	
			'totalSentences'	=> \&totalSentences,
			'totalTokens'			=> \&totalTokens,  
			'wordsWithoutVowel'		=> \&wordsWithoutVowel,
			'allCapsLetter'     		=> \&allCapsLetter,
			'totalPunctCount'    		=> \&totalPunctCount,
			'totalAlphabetCount'  		=> \&totalAlphabetCount,
			'twoContPunctuation'  		=> \&twoContPunctuation,
			'threeContPunctuation'		=> \&threeContPunctuation,
			'totalIntegerFloat'    		=> \&totalIntegerFloat,
			'totalDateCount'      		=> \&totalDateCount,
			'totalContractionCount'		=> \&totalContractionCount,
#			'parenthesisCount'   		=> \&parenthesisCount,
#			'happyEmoticons'   		=> \&happyEmoticons,
#			'sadEmoticons'    		=> \&sadEmoticons,
#			'laughingEmoticons'  		=> \&laughingEmoticons,
#			'winkEmoticons'      		=> \&winkEmoticons,
			'beginningOfSen'   		=> \&beginningOfSen,
			'allEmoticons'    		=> \&allEmoticons,	
		 );
=cut
my %featuresToSubroutines  = (	
			'totalSentences'		=> \&totalSentences,
			'totalTokens'			=> \&totalTokens,  
			'wordsWithoutVowel'		=> \&wordsWithoutVowel,
			'totalPunctCount'    		=> \&totalPunctCount,
			'totalContractionCount'		=> \&totalContractionCount,
			'parenthesisCount'   		=> \&parenthesisCount,
			'threeContPunctuation'		=> \&threeContPunctuation,
			'allCapsLetter'     		=> \&allCapsLetter,
			'allEmoticons'    		=> \&allEmoticons,
			'happyEmoticons'   		=> \&happyEmoticons,
##			'blankLinesCount'   		=> \&blankLinesCount,
			'twoContPunctuation'  		=> \&twoContPunctuation,
			'totalAlphabetCount'  		=> \&totalAlphabetCount,
			'beginningOfSen'   		=> \&beginningOfSen,
			'quotationCount' 		=> \&quotationCount,
			'htlmBreak'  			=> \&htlmBreak,
			'htmlAhref'   			=> \&htmlAhref,
			'htmlImg' 			=> \&htmlImg,
#			'htmlBold' 			=> \&htmlBold,
			'htmlHttp' 			=> \&htmlHttp,
			'htmlWww' 			=> \&htmlWww,
			'isChat'			=> \&isChat,			
	
			
		 );


	my $regex = '<b|<a|<img|//>|center>|http|</|href'; 
#testRef();




sub testRef
{
	foreach my $x(keys %featuresToSubroutines)
	{
			my $value = $featuresToSubroutines{$x}->("I am a boy huhu hhh....");
			print "$x:$value\n";
	}

}







sub readFile
{
	my $src_file = $_[0];
	open( FILE, "<$src_file" ) or die("Can't open $src_file");
	my ($data) = do { local $/; <FILE> };
	close(FILE);
	$data =~ s/Signature\s*://g;                 # remove 'Signatures:'
	$data =~ s/Post\s*:\s*\(\s*Quote\s*\)//g;    #removes tokens like "Post ( Quote )"
	$data =~ s/Post\s*:\s*//g;                   #remove tokens like "Post : "
	$data =~ s/\(\s*Quote\s*\)//g;               #removes tokens like "( Quote )"
	return $data;
}

sub isChat
{
	my $data   = $_[0];
	my $isChat = "1";

	my $regex = '<b|<a|<img|//>|center>|http|</|href'; 
	my $count = () = $data =~ /$regex/gi;
	$isChat = "0" if $count >2;
	return $isChat;
}


sub htlmBreak
{
	my $data   = $_[0];
	my $regex  = '<br';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}
sub htmlAhref
{
	my $data   = $_[0];
	my $regex  = '<a | <a\s+href';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}
sub htmlImg
{
	my $data   = $_[0];
	my $regex  = '<img';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}
sub htmlBold
{
	my $data   = $_[0];
	my $regex  = '<b';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}
sub htmlHttp
{
	my $data   = $_[0];
	my $regex  = 'http:';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}
sub htmlWww
{
	my $data   = $_[0];
	my $regex  = 'www';                      
	my $count  = () = $data =~ /$regex/g;
	return $count;
}


sub wordsWithoutVowel
{
	my $data   = $_[0];
	my $count  = 0;
	my @tokens = split( /\s+/, $data );
	foreach my $token (@tokens)
	{
		if ( $token =~ /\w/ && $token !~ /[AEIOUYaeiouy]/ )
		{
			$count++;
		}
	}
	$debug = $debug . "wordsWithoutVowel\t\t:$count\n";
	return $count;
}

sub totalTokens
{
	my $data      = $_[0];
	my $count     = 0;
	my $sentences = get_sentences($data);
	foreach my $sentence (@$sentences)
	{
		my @temp = split( /\s+/, $sentence );
		$count = $count + scalar(@temp);
	}
	$debug = $debug . "Tokens\t\t:$count\n";
	return $count;
}

sub totalSentences
{
	my $data           = $_[0];
	my $count          = 0;
	my $sentence_count = 0;
	my $sentences      = get_sentences($data);
	my $totalSentences = 1;
	if($sentences  eq 'ARRAY')
	{
		$debug = $debug . "sentences\t\t:" . scalar(@$sentences) . "\n";
	        $totalSentences = scalar(@$sentences);
	}
		return $totalSentences;
}

sub allCapsLetter
{
	my $data = $_[0];
	my $ALLcapCount = 0;
	#$ALLcapCount = () = $data =~ /[A-Z]/g;
	my @tokens        = split(/\s+/,$data);
	foreach my $token(@tokens)
	{
	     if(($token =~ /^[A-Z]+$/) && (length($token)>2))
	     {
		$ALLcapCount++;
		#print "$token\t";
	     }
	}
	$debug = $debug . "ALLcapCount\t\t:$ALLcapCount\n";
	return $ALLcapCount/totalSentences($data);
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub totalPunctCount
{
	my $data = $_[0];
	my $punctCount = () = $data =~ /\p{IsPunct}/g;
	$debug = $debug . "punctCount\t\t:$punctCount\n";
	return $punctCount;
}

sub totalAlphabetCount
{
	my $data = $_[0];
	my $alphaCount = () = $data =~ /\p{IsAlpha}/g;
	$debug = $debug . "alphaCount\t\t:$alphaCount\n";
	return $alphaCount;
}

sub twoContPunctuation
{
	my $data = $_[0];
	$data =~ s/\s*//g;
	my $specialCount = () = $data =~ /\p{IsPunct}\p{IsPunct}/g;
	$debug = $debug . "2Punct\t\t:$specialCount\n";
	return $specialCount;
}

sub threeContPunctuation
{
	my $data = $_[0];
	$data =~ s/\s*//g;
	my $specialCount = () = $data =~ /\p{IsPunct}\p{IsPunct}\p{IsPunct}/g;
	$debug = $debug . "3Punct\t\t:$specialCount\n";
	return $specialCount;
}

sub totalIntegerFloat
{
	my $data = $_[0];
	my $intandFloatCount = () = $data =~ /[-+]?[0-9]*\.?[0-9]+/g;
	$debug = $debug . "Init+Float\t\t:$intandFloatCount\n";
	return $intandFloatCount;
}

sub totalDateCount
{
	my $data = $_[0];
	my $totalDateCount = () = $data =~ /[0-1]\d[- \/ \.][0-3]\d[- \/ \.]\d\d/g;
	$debug = $debug . "totalDateCount\t\t:$totalDateCount\n";
	return $totalDateCount;

}

sub totalContractionCount
{
	my $data  = $_[0];
	my $count = 0;

	my @contraction_words = $data =~ /'(ve|re|s|ll|d|m|t)\s+/g;
	$count = scalar(@contraction_words);
	$debug = $debug . "Contractions\t\t:$count\n";
	return $count;
}

sub parenthesisCount
{
	my $data   = $_[0];
#	my $count  = () = $data =~ /(\(.*?\)|\{.*?\}|\[.*?\])/g;
	my $count  = () = $data =~ /(\{.*?\})|(\[.*?\])/g;
	my @values = ( $data =~ /(\(.*?\))|(\{.*?\})|(\[.*?\])/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "Parenthesis\t\t:$count\n";
	#$debug = $debug . $value."\n";
	return $count;
}

sub blankLinesCount
{
	 my $data   = $_[0];
	 my @lines = split(/\n/,$data);
	 my $blankCounter = 0;
	 my $total = 0;
	 foreach my $line(@lines)
	 {	
		$total++;
		if($line =~ /^\s+$/)
                {
                    $blankCounter=$blankCounter+1;                    
                }
	 }
	return $blankCounter/$total;
}

sub quotationCount
{
	my $data   = $_[0];
	my $count  = () = $data =~ /(".*?")/g;
	my @values = ( $data =~ /(".*?")/g);
	my $value  = join( "\t", @values );
	$debug = $debug . "Quotation\t\t:$count\n";
	#print "$value\n";
	#$debug = $debug . $value."\n";
	return $count;
}

sub allEmoticons
{
	my $data = $_[0];

	my $regex  = ':\s*\)|;\s*\)|:\s*D|:\s*\(';    # equivalent to :) or ;) or :D or :(
	my $count  = () = $data =~ /$regex/g;
	my @values = ( $data =~ /$regex/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "All emoticons\t\t:$count\n";
	$debug = $debug . $value . "\n";
	return $count;
}

sub happyEmoticons
{
	my $data   = $_[0];
	my $regex  = ':\s*\)';                        # equivalent to :)
	my $count  = () = $data =~ /$regex/g;
	my @values = ( $data =~ /$regex/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "Happy emoticons\t\t:$count\n";
	$debug = $debug . $value . "\n";
	return $count;
}

sub sadEmoticons
{
	my $data = $_[0];

	my $regex  = ':\s*\(';                  # equivalent to :(
	my $count  = () = $data =~ /$regex/g;
	my @values = ( $data =~ /$regex/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "sad emoticons\t\t:$count\n";
	$debug = $debug . $value . "\n";
	return $count;
}

sub laughingEmoticons
{
	my $data = $_[0];

	my $regex  = ':\s*D';                   # equivalent to :D
	my $count  = () = $data =~ /$regex/g;
	my @values = ( $data =~ /$regex/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "Laugh emoticons\t\t:$count\n";
	$debug = $debug . $value . "\n";
	return $count;
}

sub winkEmoticons
{
	my $data = $_[0];

	my $regex  = ';\s*\)';                  # equivalent to ;)
	my $count  = () = $data =~ /$regex/g;
	my @values = ( $data =~ /$regex/g );
	my $value  = join( "\t", @values );
	$debug = $debug . "Wink emoticons\t\t:$count\n";
	$debug = $debug . $value . "\n";
	return $count;
}

sub beginningOfSen_bak
{
	my $data         = $_[0];
	my $TotalSen     = 1;
	my $BegCharCount = 0;
	## Get the sentences.
	my $sentences = get_sentences($data);
	foreach my $sentence (@$sentences)
	{
		my @temp = split( /\s+/, $sentence );
		my @char = split( //,    $temp[0] );
		if ( grep( /\p{IsUpper}/, $char[0] ) )
		{
			$BegCharCount = $BegCharCount + 1;
		}
	}
	$debug = $debug . "BegCharCount\t\t:$BegCharCount\n";
	return $BegCharCount;

}

sub beginningOfSen
{
	my $data         = $_[0];
	my $BegCharCount = 0;
	my $sentences    = get_sentences($data);
	foreach my $sentence (@$sentences)
	{
		if ( $sentence =~ /^[A-Z]/ )
		{
			$BegCharCount = $BegCharCount + 1;
		}
	}
	$debug = $debug . "BegCharCount\t\t:$BegCharCount\n";
	return $BegCharCount;

}


sub extractFeatures
{
	foreach my $fname (@post_names)
	{
		my $file_path = "${file_path}$fname";
		@row = ();
		my $test = readFile($file_path);
		$debug = "";
		#print "-----------------------\n";
		foreach my $feature(keys %featuresToSubroutines)
		{
			my $value = 0;
			if (!(trim($test) eq ""))    #if file content is not null otherwise do nothing , means all values are assigned with 0
			{
				$value = $featuresToSubroutines{$feature}->($test); # $featuresToSubroutines{totalTokens}->($test) calls function 'totalTokens($test)'
				#print"$feature:$value\n";
			}
			push @row,$value;
		}
		#print "@row\n";
		push @matrix, [@row];
	}
}

sub featuresToString
{
	foreach my $feature(keys %featuresToSubroutines)
	{
			push @featuresArray,$feature;
	}
	my $featuresString =  join("\n", @featuresArray);
	return $featuresString;
}

sub readRLabel
{
	open( RLABEL, "< $rlabel" ) or die("Could not open $rlabel");
	foreach my $line (<RLABEL>)
	{
		push( @post_names, trim($line) );
	}
	close(RLABEL);
}

sub writeToFile
{

	my @normalized_matrix = normalize($mat_file_path, $cols_avg, @matrix );
#	my @normalized_matrix = @matrix;

	undef(@matrix);
	open( MATFILE, "> $mat_file_path" ) or die("Could not open file.");

	foreach my $i ( 0 .. $#normalized_matrix )
	{
		print MATFILE "@{$normalized_matrix[$i]}\n";
	}

	# print MATFILE "$dataToMat";
	close(MATFILE);
	undef(@normalized_matrix);

	if ( $dataType eq "train" )
	{
		open( CLABELFILE, "> $vocabFile" ) or die("Could not open file.");
		$features =  featuresToString();
		print CLABELFILE "$features";
		close(CLABELFILE);
	}

}

$file_path .= '/' if ( $file_path !~ /\/$/ );

readRLabel();
extractFeatures();
writeToFile();

