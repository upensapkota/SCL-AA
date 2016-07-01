#!/usr/bin/perl 
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use Text::Ngrams;
require "variable.pl";
require "create_file_hierarchy.pl";
my $n_for_word_ngrams = 1;
my $min_n_for_word_ngrams = 1;

our($numberOfSemanticFeatures);

use File::Basename;
use File::Find;
use Lingua::Treebank::Const;


my $src        = $ARGV[0];
my $rlabel     = $ARGV[1];
my $dest       = $ARGV[2];
my $vocab_file = $ARGV[3];


$vocab_file = $dest."/".$vocab_file;
my %globalRules = ();
my @posts_names = ();

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
  foreach my $fileName(@post_names)
  {
	#print "$fileName\n";
	open( FILE, "<$fileName" ) or die("Not found $fileName");
	my ($text) = do { local $/; <FILE> };
	my @lines = split( /\n/, $text );
	foreach my $line(@lines)
	{
		#skip blank lines.
		if(length(trim($line)) <= 1)
		{
		    next;
		}
		#skip blank lines.
		if($line =~/Sentence skipped: no PCFG fallback./i)
		{
		    next;
		}

		if($line =~/SENTENCE_SKIPPED_OR_UNPARSABLE/i)
		{
		    next;
		}
		
		my ($rules, $lexunits) = getRulesAndLexUnits($line);
		#first check for rule repetitions.
		foreach my $rule (@$rules)
		{
		    $globalRules{trim($rule)}++;
		    #print "$rule\n";
		}
	}
    }
my @sortedKeys = sort {$globalRules{$b} <=> $globalRules{$a}}keys %globalRules; 

=pod
foreach my $key(@sortedKeys)
{
 #print "$key\t$globalRules{$key}\n";
}
=cut


 #print join("\n", @sortedKeys)."\n";
 print UNIQUE join("\n", @sortedKeys);
 close(UNIQUE);
 
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



