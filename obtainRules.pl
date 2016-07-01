#!/usr/bin/perl 
use strict;
use File::Basename;
use File::Find;
use Lingua::Treebank;
use Lingua::Treebank::Const;

my $outputPath = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/del/PCFG";
my $fileName  = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/all_data/del/trebanked/test.txt";



sub trainPCFGforAuthor
{
        my @FileName = split(/\//,$fileName);
        my $fname=$FileName[scalar(@FileName)-1];

	print "$fileName\n"; 
	print "$fname\n";
	
	#
	# This line trains a PCFG  using annotated treebanked authors data
	#
	my $cmd = "java -cp stanford-parser.jar -mx1500m edu.stanford.nlp.parser.lexparser.LexicalizedParser  -train $fileName -saveToTextFile $outputPath/$fname";
	qx/$cmd/;

}

sub parseManually
{

  my @sentences = Lingua::Treebank->from_penn_file($fileName);

  foreach my $sentence(@sentences) {
    print "....$sentence....\n";

=pod
    foreach my $each ($value->get_all_terminals) {
      print $each->word()." ". $each->tag(). "\n";
    }
=cut

  }
}

sub usingConst
{
	open( FILE, "<$fileName" ) or die("Not found $fileName");
	my ($text) = do { local $/; <FILE> };
	my @lines = split( /\n/, $text );
	my %globalRules = ();
	foreach my $line(@lines)
	{
		my ($rules, $lexunits) = getRulesAndLexUnits($line);
		#first check for rule repetitions.
		foreach my $rule (@$rules)
		{
		    $globalRules{$rule}++;
		    #print "$rule\n";
		}
		
		#next check for lexical repetitions.
		foreach my $lexunit (@$lexunits)
		{
		    #print "$lexunit\n";            
		}
	}
	foreach my $rule(keys %globalRules)
	{
		print "$rule\t $globalRules{$rule}\n";
	}

}

sub printChildren
{
		my $node = $_[0];
		my $label = $node->tag();
		my @children = @{$node->children};
		print "$label:";
		foreach my $child(@children)
		{
	                print $child->tag();
		}
		print "\n";
		

}

sub getRulesAndLexUnits
{
    my $sentenceParse = shift;
    
    my @rules;
    my %lexunits = ();
    
    #Create a tree representation in memory from the bracketed string format of the sentence.
    my $parent = Lingua::Treebank::Const->new->from_penn_string($sentenceParse);
    print "$parent\n------------------------------------\n";
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



#trainPCFGforAuthor();
#parseManually();
usingConst();

