#!/usr/bin/perl 

require "NormalizeMatrixByFeatures.pl";
require "create_file_hierarchy.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use File::Basename;
use File::Find;
use Text::Ngrams;
use Lingua::Treebank::Const;
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

	#print "-------------unique--------------------\n".join("\t",@unique_ngrams)."\n";

	foreach my $post (@post_names)
	{
		my %file_ngrams = ();
		my $string      = "";
		@row = ();
		my $counter = 0;
		my $fileName = "$src$post";
		open( FILE, "<$fileName" ) or die("Not found $fileName");
		my ($text) = do { local $/; <FILE> };
		my @lines = split( /\n/, $text );
		foreach my $line(@lines)
		{
			#skip blank lines.
			if(length($line) <= 1)
			{
			    next;
			}
			if($line =~/Sentence skipped: no PCFG fallback./i)
			{
			    next;
			}

			if($line =~/SENTENCE_SKIPPED_OR_UNPARSABLE/i)
			{
			    next;
			}
		       # print "$line\n";
			my ($rules, $lexunits) = getRulesAndLexUnits($line);
			#first check for rule repetitions.
			foreach my $rule (@$rules)
			{
			    $file_ngrams{trim($rule)}++;
			    #print "$rule\n";
			}
		}

		#my @sortedKeys = sort {$file_ngrams{$b} <=> $file_ngrams{$a}}keys %file_ngrams; 
	        #print "-------------file--------------------\n".join("\t",@sortedKeys)."\n";
		#close(NGRAM_FILE);

		foreach my $unique (@unique_ngrams)
		{

			my $count = 0;
			$count = $file_ngrams{ trim($unique) } if defined $file_ngrams{trim($unique)};
			push @row, $count;
			#print "$count" if $count >0;
			#print "$unique\t";

		}
		push @matrix, [@row];
		#print "@row\n";
		undef(@row);


	}
}



sub getRulesAndLexUnits
{
    my $sentenceParse = shift;
    
    my @rules;
    my %lexunits = ();
    
    #Create a tree representation in memory from the bracketed string format of the sentence.
    my $parent = Lingua::Treebank::Const->new->from_penn_string($sentenceParse);
    #Call a recursive BFS style algorithm to navigate the Tree and extract lexical and structural structures.
    getRulesAndLexUnitsHelper($parent, \@rules, \%lexunits);
    my @lexunitsarray = keys %lexunits;
    return (\@rules,\@lexunitsarray);
}

#A method to extract lexical and syntactic units from the given sentence. Uses a BFS style recursive algorithm to do this.
#Inputs are:
#$parent - Reference to the Parent node that has to be processed in the current cycle. It is an object of type Lingua::Treebank::Const.
#$rulesref - Reference to an array of rules that will be populated as the algorithm progresses.
#$lexunitsref - Reference to a hashtable of lexical units that will be populated as the algorithm progresses.

sub getRulesAndLexUnitsHelper
{
    my $parent = shift;
    my $rulesref = shift;
    my $lexunitsref = shift;
    
    my $children = $parent->children();
    my $derivation = $parent->tag() . " ";
    
    #Leaves will be of form: POS -> Lexical Word.
    if($parent->is_terminal())
    {
        $derivation = $derivation . $parent->word() . " ";
    }
    
    #Generate the production rule.
    foreach my $child (@$children)
    {
        $derivation = $derivation . $child->tag() . " ";
    }
    
    #push(@$rulesref,$derivation);
    push(@$rulesref,$derivation) if(not $parent->is_terminal() );
    
    my $lexunit = lc($parent->text());
    #$lexunitsref->{$lexunit} = 1;
    $lexunitsref->{$lexunit} = 1 if(not $parent->is_terminal() );

    #Now, recurse for all children.
    foreach my $child (@$children)
    {
        getRulesAndLexUnitsHelper($child, $rulesref, $lexunitsref);
    }
}


sub writeToFile()
{
	my @normalized_matrix = normalize($fv_file, $cols_avg, @matrix );
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

