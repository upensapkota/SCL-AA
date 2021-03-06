#!/usr/bin/perl 
require "variable.pl";
require "create_file_hierarchy.pl";

my $frequencyThreshold = 5;
use File::Basename;
use File::Find;

my $vocabPth        		= $ARGV[0];
my $fvPth		  	= $ARGV[1];
my $srcModality       		= $ARGV[2]; # charngram
my $dstModality       		= $ARGV[3]; # pivotC
my $numbeOfFeatures	  	= $ARGV[4];
my $isPvt		  	= $ARGV[5]; ## 1 if pivot

my @srcModalities = split(/\s*,\s*/,$srcModality);

createFiles();
createVocab();
createFV("train");
createFV("test");

sub createFiles
{
	
}
sub createVocab
{
	open(VOCAB_D,">$vocabPth/${dstModality}labels.txt") or die("Can't open $vocabPth/${dstModality}labels.txt: $!");
	my @vocab = ();
	my @remainingVocab = (); ## to 
	foreach my $srcModality(@srcModalities)
	{
		open(VOCAB_S,"<$vocabPth/${srcModality}labels.txt") or die("Can't open $vocabPth/${srcModality}labels.txt: $!");
		my $count = 1;
		my @currentVocab = ();
	   	foreach my $line(<VOCAB_S>)
		{
			$line = trim($line);
#			push @vocab, $line;
			push @currentVocab, $line;
		}	
		close VOCAB_S;
		if (scalar(@currentVocab) > $numbeOfFeatures)
		{
			push @vocab, @currentVocab[0..$numbeOfFeatures-1];
			push @remainingVocab, @currentVocab[$numbeOfFeatures..scalar(@currentVocab)-1];
		}
		else
		{
			push @vocab, @currentVocab;
		}
	}
	print VOCAB_D join("\n", @vocab);
	close VOCAB_D;	

	if ($isPvt == 1)
	{
		open(VOCAB_R,">$vocabPth/${dstModality}_notUsedlabels.txt") or die("Can't open $vocabPth/${dstModality}_notUsedlabels.txt: $!");
		print VOCAB_R join("\n", @remainingVocab);
		close VOCAB_R;	
	}
	
}

sub createFV
{
	my $type = $_[0];
	open(FV_D,">$fvPth/${dstModality}_$type.txt") or die("Can't create $fvPth/${dstModality}_$type.txt: $!");


	my %combinedFvs = ();
	my %remainingFvs = (); ## reamining FVs after selecting pivot FVs
	foreach my $m(0..$#srcModalities)
	{
		$srcModality = $srcModalities[$m];
		my @allfvs = ();
		open(FV_S,"<$fvPth/${srcModality}_$type.txt") or die("Can't open $fvPth/${srcModality}_$type.txt: $!");
		foreach my $line(<FV_S>)
		{
			push(@allfvs,trim($line));
			#print "count:".scalar(@allfvs)."\n";
		}

		
		foreach my  $i(0..$#allfvs)
		{
			$fv = $allfvs[$i];
			my @split = split(/ /, $fv);
			my @selected = ();
			my @remainingFvs = (); ## remaining from pivot features.
			if (scalar(@split) > $numbeOfFeatures)
			{
				@selected = @split[0..$numbeOfFeatures-1];
				@remainingVocab = @split[$numbeOfFeatures..scalar(@split)-1];
			
			}
			else
			{
				@selected = @split;
			}
			my $current = ();
			$current = $combinedFvs{$i} if defined $combinedFvs{$i};
			push @$current, @selected;
			$combinedFvs{$i} = $current;

			if ($isPvt == 1)  ## compute fv for remaining of features after extracting pivot features
			{
				my $currentR = ();
				$currentR = $remainingFvs{$i} if defined $remainingFvs{$i};
				push @$currentR, @remainingVocab;
				$remainingFvs{$i} = $currentR;
			}
			
						
		}
	}
	foreach my $i(sort {$a <=> $b} keys %combinedFvs)
	{
			print FV_D join(" ", @{$combinedFvs{$i}})."\n";
	}
	close FV_D;
	close FV_S;

	if ($isPvt == 1)
	{

		open(FV_D,">$fvPth/${dstModality}_notUsed_$type.txt") or die("Can't create $fvPth/${dstModality}_notUsed_$type.txt: $!");
		foreach my $i(sort {$a <=> $b} keys %remainingFvs)
		{
				print FV_D join(" ", @{$remainingFvs{$i}})."\n";
		}
		close FV_D;
	}
}


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
