#!/usr/bin/perl -w
use strict;
use Cwd;
use File::Basename;
use Lingua::Treebank::Const;

my $inputmask = "H:\\itaproj\\code\\hcrc\\q*nc*.txt";
my @files = glob($inputmask);

my $scoresfile = "H:\\itaproj\\code\\scores.txt";
my $scores = getScores($scoresfile);
my $convinterval = 9999;

my ($lemma, $pos, $neg) = loadSentiWordNet("SentiWordNet_1.0.1.txt");

##Prepare to write arff file.
open F1, ">samp_senti.arff";
print F1 "\@relation \'MapTask\'\n";
print F1 "\@attribute positivesentences real\n";
print F1 "\@attribute negativesentences real\n";
print F1 "\@attribute neutralsentences real\n";
print F1 "\@attribute score real\n";
print F1 "\@data\n";

#my $startTime = time();

foreach my $file (@files)
{
    my $filename = basename($file, ".txt");
    print "Extracting features from $filename ...\n";
    my $score = $scores->{$filename};
    my @sentences = getFileSentences($file);
    
    my $numpositivesentences = 0;
    my $numnegativesentences = 0;
    my $numneutralsentences = 0;
    
    foreach my $sentence (@sentences)
    {
        my @tokens = tokenizeSentence($sentence);
        my $sentenceorientation = 0;
        my $notappeared = 0;
        #print "Sentence = $sentence ...\n";
        foreach my $token (@tokens)
        {
            #print "token = $token ...\n";
            my ($positive, $negative, $neutral) = getWordOrientation($token, $lemma, $pos, $neg);
            if($token eq "not" || $token eq "yet" || $token eq "but")
            {
                #print "$token ...\n";
                $notappeared = 1;
                next;
            }
            
            if($positive>$negative && $positive>$neutral)
            {
                $sentenceorientation++ if($notappeared eq 0);
                $sentenceorientation-- if($notappeared eq 1);
            }
            elsif($negative>$positive && $negative>$neutral)
            {
                #print "token = $token ...\n";
                $sentenceorientation-- if($notappeared eq 0);
                $sentenceorientation++ if($notappeared eq 1);
            }
        }
        #print "$sentence ...\n";
        if($sentenceorientation>0)
        {
            $numpositivesentences++;
        }
        elsif($sentenceorientation<0)
        {
            #print "$sentence ...$sentenceorientation\n";
            $numnegativesentences++;
        }
        else
        {
            $numneutralsentences++;
        }
    }
    print F1 "$numpositivesentences,$numnegativesentences,$numneutralsentences,$score\n";
    #last;
}
close(F1);

#my $endTime = time();
#print "Time take to process = " . ($endTime-$startTime) . " ...\n";

#my $sentence = "This is a test.";
#my @tokens = tokenizeSentence($sentence);
#print @tokens;

sub tokenizeSentence
{
    my $sentence = shift;
    #remove all chars except alphabet.
    $sentence =~ s/-/ /igs;
    $sentence =~ s/[^A-Za-z ]//igs;
    $sentence =~ s/ +/ /igs;
    my @tokens = split(/ /, $sentence);
    return @tokens;
}
#############################################################
=head3 loadSentiWordNet

=head4 Description

Load the local copy of Sentiwordnet into memory for later lookups.

=head4 Inputs

=over 12

=item Path to the file containing the Sentiwordnet text file.

=back

=head4 Outputs

=over 12

=item Reference to array of Lemmas from Sentiwordnet.

=item Hash of Positive values from Sentiwordnet.

=item Hash of Negative values from sentiwordnet.

=back

=cut

sub loadSentiWordNet
{
    my @lemmas =();
    my %pos = ();
    my %neg = ();
    my $filename = shift;
    open F2, $filename;
    
    while(my $line = <F2>)
    {
        if (substr($line,0,1) ne "#")
        {
            my @data = split(/\t/, $line);
            my $positivity = $data[2];
            my $negativity = $data[3];
            my @synsetLemmas = split(/ /, $data[4]);
            
            foreach my $lemma (@synsetLemmas)
            {
                chomp($lemma);
                $pos{$lemma} = $positivity;
                $neg{$lemma} = $negativity;
                push(@lemmas, $lemma);
                #print "$lemma,$positivity,$negativity\n";
            }
        }
    }
    return(\@lemmas, \%pos, \%neg);
}

=head3 getWordOrientation

=head4 Description

Calculate the sentiment values for the given word using local copy of Sentiwordnet. We search for sentiment values of most frequently used adjective form of the given word and then the most frequently used adverb form of the given word.

=head4 Inputs

=over 12

=item Word for which we need to find out the sentiment.

=item Reference to array of Lemmas from Sentiwordnet.

=item Hash of Positive values from Sentiwordnet.

=item Hash of Negative values from sentiwordnet.

=back

=head4 Outputs

=over 12

=item Positive score for the word.

=item Negative score for the word.

=item Neutral score for the word.

=item -1 -1 -1 if word is not found in Sentiwordnet.

=back

=cut

sub getWordOrientation
{
    my $word = shift;
    my $lemmas = shift;
    my $pos = shift;
    my $neg = shift;
    
    my $positive, my $negative, my $neutral;
    my $key = "";
    
    if(defined($pos->{"$word#a#1"}))
    {
        $key = "$word#a#1";
    }
    elsif(defined($pos->{"$word#r#1"}))
    {
        $key = "$word#r#1";
    }
    else
    {
        $key = -1;
    }
    
    if($key ne -1)
    {
        $positive = $pos->{$key};
        $negative = $neg->{$key};
        $neutral = 1-($positive+$negative);
    }
    else
    {
        $positive = -1;
        $negative = -1;
        $neutral = -1;
    }
    return ($positive, $negative, $neutral);
}






###############################################################


sub getScores
{
    my $filename = shift;
    my %scores = ();
    open F2, $filename;
    my $count=0;
    while(my $line = <F2>)
    {
        $count++;
        #print "$line ...\n";
        $line =~ m/(\s*)(\S*)(\s*)(\S*)/i;
        if(defined($1) && defined($2))
        {
            $scores{$2} = $4;
            #print "$2 = $4 ...\n";
        }
    }
    #print "$count ...\n";
    return \%scores;
}
#Generates statistics related to priming from the given file.
#Specifically,
#$rulerep - Number of rules repeatitions.
#$lexrep - Number of Lexical units repetitions.
#$charsrep - Number of characters in the lexical units repeated.
#$numrules - Total number of rules processed.
#$numlex - Total number of lexical units processed.
#$numconv - Total number of conversations processed.
#Inputs are the following:
#$filename - Filename of the conversations file.
#$datapointinterval - Number of conversations per data point.
#$parser - Reference to the Stanford Parser object.
#Outputs are the following:
#Array of string: $rulerep, $lexrep, $charsrep, $numrules, $numlex, $numconv.

sub getPrimeFeaturesFromFile
{
    my $inputfile = shift;
    my $datapointinterval = shift;
    my $parser = shift;

    my @features = ();
    my %global_rules = ();
    my %global_lexunits = ();
    my $rulerep = 0;
    my $lexrep = 0;
    my $charsrep = 0;
    my $numrules = 0;
    my $numlex = 0;
    my $numconv = 0;
    
    my @sentences = getFileSentences($inputfile);
    foreach my $sentence (@sentences)
    {
        #skip blank lines.
        if(length($sentence) <= 1)
        {
            next;
        }
        
        $sentence =~ m/.+:/i;
        $sentence = $';
        
        $numconv++;
        
        #print "Processing conversation $numconv ...\n";
        
        my $parse = getStanfordParse($parser, $sentence);
        my ($rules, $lexunits) = getRulesAndLexUnits($parse);
        
        #first check for rule repetitions.
        foreach my $rule (@$rules)
        {
            $numrules++;
            if(defined $global_rules{$rule})
            {
                #print "Repeat ... $rule\n";
                $global_rules{$rule} = $global_rules{$rule} + 1;
                $rulerep++;
            }
            else
            {
                #print "Not Repeat ... $rule\n";
                $global_rules{$rule} = 1;
            }
        }
        
        #next check for lexical repetitions.
        foreach my $lexunit (@$lexunits)
        {
            $numlex++;
            if(defined $global_lexunits{$lexunit})
            {
                $global_lexunits{$lexunit} = $global_lexunits{$lexunit} + 1;
                $lexrep++;
                $charsrep = $charsrep + length($lexunit);
            }
            else
            {
                $global_lexunits{$lexunit} = 1;
            }
        }
        
        #Now, check to see if a new data point is to be created.
        if( ($numconv % $datapointinterval) eq 0 )
        {
            push(@features, "$rulerep,$lexrep,$charsrep,$numrules,$numlex,$numconv");
        }
    }
    
    #Create a final datapoint for leftover conversations.
    push(@features, "$rulerep,$lexrep,$charsrep,$numrules,$numlex,$numconv");
    return @features;
}

#Parse a sentence using the Stanford Parser. This in turn uses the Inline::Java module to call the Java parser class.
#Inputs are the Parser object and the Sentence.
#Output is the sentence parse in Penn format.
#NOTE: Some temporary files will be created in the directory from where the perl program is executed. Make sure write permissions are present.

sub getStanfordParse
{
    my $parser = shift;
    my $sentence = shift;
    
    my $parsedtext = $parser->parse($sentence);
    $parsedtext =~ s/\[.*?\]//ig;
    return $parsedtext;
}

#Read the contents of a file and tokenize them into sentences, 1 per line.
#Input is the filename.
#Output is the array of Preprocessed sentences.
#NOTE: This is the place to improve tokenization.

sub getFileSentences
{
    my $filename = shift;
    open CONV, $filename || die("Invalid file");
    my $backup = $/;
    $/ = undef;
    my $alltext = <CONV>;
    close(CONV);
    $/ = $backup;
    
    my @sentences = preprocessSentences($alltext);
    
    return @sentences;
}

#This is used to simulate a continuous stream of sentences.
#Inputs are array of sentences and current position.
#Outputs are sentence and new position (-1 if end).

sub getSentence
{
    my $data = shift;
    my $pos = shift;
    
    if($pos >= scalar(@$data))
    {
        return (-1, -1);
    }
    else
    {
        #strip off the user's identification word.
        my $temptext = $data->[$pos];
        $temptext =~ m/.+:/i;
        $temptext = $';
        return ($temptext, $pos+1)
    }
}

#Extract Grammer production rules and lexical units generated by the rules from a sentence. This in turn calls getRulesAndLexUnitsHelper to do the extraction.
#Inputs are:
#$sentenceParse - The parse of the sentence in bracketed notation as defined by the Penn treebank format.
#Outputs are:
#NOTE: Input should be a single sentence parse in a single line without any line breaks, preferably output of sepTreeBank method.

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

#Parse a sentence into its constituent syntactic structures like Noun, Verb etc. This method in turn uses a stanford parser to do the actual parsing.
#Input is the sentence to be parsed.
#Output is the Parse of the sentence in Penn treebank style bracketed notation.
#NOTE: The Input sentence should be a single sentence, preferably preprocessed using preprocessSentence method.
#NOTE: Some temporary files will be created in the directory from where the perl program is executed. Make sure write permissions are present.
#NOTE: This method can be replaced by any algorithm that returns a Parsed sentence in the form of bracketed notation as defined by Penn treebank.

sub getSentenceParse
{
    my $sentence = shift;
    
    my $parserpath = "C:\\temp\\stanfordparser\\stanford-parser-2008-10-26\\lexparser.bat";
    my $currentdir = getcwd();
    my $parserDir = dirname($parserpath);
    my $parsercmd = fileparse($parserpath);
    my $sentfile = "$currentdir\\temp.txt";
    my $parsefile = "$currentdir\\temp.out";
    
    chdir $parserDir;
    open F1, ">$sentfile" || die("Write permission missing ...");
    print F1 $sentence;
    close(F1);
    
    system("$parsercmd $sentfile > $parsefile 2>null");
    chdir($currentdir);
    
    open F1, $parsefile || die("Write permission missing");
    my $backup = $/;
    $/ = undef;
    my $alltext = <F1>;
    close(F1);
    $/ = $backup;
    
    my $sentenceParse = sepTreeBank($alltext);
    return $sentenceParse;
}

#Compress a multi-line parsed sentence output in bracketed notation into single line. The input can be either a single sentence or multiple sentences.
#Input is the string containing multi-line parsed sentences.
#Output is the string containing parsed sentence, one per line.

sub sepTreeBank
{
    my $alltext = shift;
    
    my $string1 = "ROOT(.*?)ROOT";
    my $outstring = "";

    #If there is only 1 parsed sentence.
    if(not($alltext =~ m/$string1/is))
    {
        $alltext =~ s/\n//ig;
        $outstring = $alltext;
    }
    #More than 1 parsed sentence.
    else
    {
        while($alltext =~ m/$string1/is)
        {
            my $tempstr = $1;
            chop($tempstr);
            $tempstr = "(ROOT" . $tempstr;
            
            my $backup1 = $';
            $tempstr =~ s/\n//ig;
            
            $outstring = $outstring . $tempstr . "\n";
            $alltext = "(ROOT" . $backup1;
        }
    }
    return $outstring;
}

#Do some preprocessing. Specifically, remove brackets, multiple .'s, split sentences into arrays.
#Input is a string containing one or more sentences.
#Output is an array containing the individual sentences.

sub preprocessSentences
{
    my $sentence = shift;
    
    #first remove any round brackets present.
    $sentence =~ s/\(|\)/ /ig;
    #replace multiple spaces by single space.
    $sentence =~ s/ +/ /ig;
    #replace multiple .'s by a single .
    $sentence =~ s/\.\.+/ /ig;
    #mark off ?'s and !'s for later replacement using ^^ and ^%.
    $sentence =~ s/\?/\^\^\?/ig;
    $sentence =~ s/\!/\^\%\!/ig;
    #split multiple sentences into an array.
    my @sentencesTemp = split(/\.|\?|\!/,$sentence);
    my @sentences;
    foreach my $sentence (@sentencesTemp)
    {
        if(length($sentence)>1)
        {
            chomp($sentence);
            if(substr($sentence, -2, 2) eq "^^")
            {
                substr($sentence, -2, 2) = "?";
                push(@sentences, $sentence);
            }
            elsif(substr($sentence, -2, 2) eq "^%")
            {
                substr($sentence, -2, 2) = "!";
                push(@sentences, $sentence);
            }
            else
            {
                push(@sentences, $sentence . ".");
            }
        }
    }
    return @sentences;
}
