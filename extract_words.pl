#!/usr/bin/perl 

require "NormalizeMatrixByFeatures.pl";
require "create_file_hierarchy.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use File::Basename;
use File::Find;
use Text::Ngrams;
my %unique_ngrams = ();

my $src           = $ARGV[0];
my $rlabel        = $ARGV[1];
my $vocab_file    = $ARGV[2];
my $fv_file       = $ARGV[3];
my $cols_avg      = $ARGV[4];

my $n_for_word_ngrams 		= 1;
my $min_n_for_word_ngrams 	= 1;



my @post_names = ();
my @matrix     = ();
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
	open( VECTOR, "< $vocab_file" ) or die("Could not open log file:$!");

	#print "$vocab_file\n";
	foreach (<VECTOR>)
	{
		push( @unique_ngrams, trim($_) );
	}
	close(VECTOR);

	foreach my $post (@post_names)
	{
		my %file_ngrams = ();
		my $string      = "";
		@row = ();
		my $counter = 0;

		#open( NGRAM_FILE, "< $src$post" ) or die("Could not open $dest$post file.");

		my $ng3 = Text::Ngrams->new( type => word, windowsize => $n_for_word_ngrams );
		$ng3->process_files("${src}${post}");
		for ( my $ngram = $min_n_for_word_ngrams ; $ngram <= $n_for_word_ngrams ; $ngram++ )
		{
			my @ngramsarray = ();
			@ngramsarray = $ng3->get_ngrams( n => $ngram, orderby => 'frequency' );

			for ( my $i = 0 ; $i < $#ngramsarray ; $i = $i + 2 )
			{
				my $j             = $i + 1;
				my $current_ngram = $ngramsarray[$i];
				$current_ngram = lc($current_ngram);
				$file_ngrams{$current_ngram} = $ngramsarray[$j];

			}

		}

		#close(NGRAM_FILE);

		foreach my $unique (@unique_ngrams)
		{

			my $count = 0;
			$count = $file_ngrams{ trim($unique) } if defined $file_ngrams{ trim($unique) };
			push @row, $count;

		}
		push @matrix, [@row];
		undef(@row);

	}
}

sub writeToFile()
{
#	my @normalized_matrix = normalize($fv_file, $cols_avg, @matrix );
	my @normalized_matrix = @matrix;
	undef(@matrix);
	open( VECTOR, "> $fv_file" ) or die("Could not open $fv_file.");
	foreach my $i ( 0 .. $#normalized_matrix )
	{
		print VECTOR "@{$normalized_matrix[$i]}\n";
	}
	close(VECTOR);
	undef(@normalized_matrix);
}

readRLabel();
createNewFolder($dest);
extractFV();
writeToFile();

