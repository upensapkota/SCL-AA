#!/usr/bin/perl 
use strict;
require "variable.pl";
require "create_file_hierarchy.pl";
use File::Copy;
our (%modalities);
our (@modalities);
our ($numberOfPivotFeatures);
our ($runTrain, $runTest);
our (@syn);


my $srcData	= $ARGV[0]; ## source documents
my $location 	= $ARGV[1]; #location of the main folder
my $folder_name = $ARGV[2]; #actual folder inside which the hierarchy of file is to be created,e.g. 5Author
my $run 	= $ARGV[3];


my $runPath = "${location}$folder_name/$run";

my $start_run = time();


main();

sub main
{

	print "Number of modalities:". scalar(@modalities)." [@modalities]\n";

	print "** Creating all the first level features **\n";
	createNewFolder("$runPath/fv") if (!(-e "$runPath/fv"));
	createNewFolder("$runPath/vocab") if (!(-e "$runPath/vocab"));
	createNewFolder("$runPath/column_average") if (!(-e "$runPath/column_average"));
	createNewFolder("$runPath/vcluster_files") if (!(-e "$runPath/vcluster_files"));
	
	#print("FILE HIERARCHY CREATION SUCCESSFUL.\n");
	foreach my $modality(@modalities)
	{
		print "------------feature extraction on $modality modality----------------\n";
		$modalities{$modality}->(); # $modalities{"sty"} calls function 'stylistic()'
#		copy("$runPath/vocab/${modality}labels.txt", "$runPath/vcluster_files/${modality}labels.txt") or die "$runPath/vocab/${modality}labels.txt can't be copied.";
    		#system("perl preprocessAttributes.pl $runPath/vcluster_files/${modality}labels.txt _$modality") ;
   		
	}

	#copyLabelsForClustering()  ;


}

#---------------- COLING 2014 PAPER-------------------#
sub pivotC_charngram
{
      my $n = 3;
      system("perl extractPivotC.pl $runPath/vocab $runPath/fv char${n}ngram pivotC $numberOfPivotFeatures 1");
	
}
sub nonPivotC_semanticAndStop
{
	my $n = 3;
	my $numberOfFeaturesOnEachModality = 3500;
        system("perl extractPivotC.pl $runPath/vocab $runPath/fv sem,stop,pivotC_notUsed non-pivotC $numberOfFeaturesOnEachModality");
	
}



sub charngram
{

#my @types = ('charPrefix','charOther', 'charMultiWord','charEntireWord', 'charSuffix','charngram');
	system("perl findcharngrams.pl ${srcData}/all_data/processedData $runPath/labels/rlabel_train.txt $runPath/vocab") ; ## new use this


	print "train\n";
	system( "perl extract_charngrams.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_train.txt $runPath/vocab $runPath/fv $runPath/column_average train")  ;

	print "test\n";
	system("perl extract_charngrams.pl   ${srcData}/all_data/processedData/ $runPath/labels/rlabel_test.txt $runPath/vocab $runPath/fv $runPath/column_average test") ;


}




sub stop
{
	my $inputFile = "/home/upendra/NLP/MOOD_AND_STOP_WORDS/stop_words.txt";
	my $frequencyThreshold = 2;
	my $numberOfFeatures = 1000;

	#system("perl findStopWords.pl ${srcData}/all_data/processedData $runPath/labels/rlabel_train.txt $runPath/vocab stoplabels.txt $numberOfFeatures") ;
#=pod
	copy($inputFile,"$runPath/vocab/stoplabels.txt");

	#
	#creates feature vector for each trainining files using the vocab created from above script.
	#
	system( "perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_train.txt $runPath/vocab/stoplabels.txt $runPath/fv/stop_train.txt $runPath/column_average")  ;
	#
	#creates feature vector for each test files using the vocab created from above script.
	#
	system("perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_test.txt $runPath/vocab/stoplabels.txt $runPath/fv/stop_test.txt $runPath/column_average") ;
#=cut
}

sub semantic
{

	system("perl unique_wordsFixed.pl ${srcData}/all_data/processedData $runPath/labels/rlabel_train.txt $runPath/vocab semlabels.txt stoplabels.txt") ;
	#
	#creates feature vector for each trainining files using the vocab created from above script.
	#
	system( "perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_train.txt $runPath/vocab/semlabels.txt $runPath/fv/sem_train.txt $runPath/column_average") ;
	#
	#creates feature vector for each test files using the vocab created from above script.
	#
	system("perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_test.txt $runPath/vocab/semlabels.txt $runPath/fv/sem_test.txt $runPath/column_average") ;

}





#FEATURE GENERATION
sub syndep
{
	system("perl uniquesyndep_stanford_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_train.txt $runPath/vocab/syndeplabels.txt");

	system("perl extract_syndep_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_train.txt $runPath/vocab/syndeplabels.txt $runPath/fv/syndep_train.txt $runPath/column_average") ;
	system("perl extract_syndep_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_test.txt $runPath/vocab/syndeplabels.txt $runPath/fv/syndep_test.txt $runPath/column_average") ;
}


sub stylistic
{
	
	#print"--------- stylistic ---------- \n";
	system("perl stylisticFeatures.pl ${srcData}/all_data/processedData $runPath/fv/sty_train.txt $runPath/vocab/stylabels.txt $runPath/labels/rlabel_train.txt $runPath/column_average train")  ;

	system("perl stylisticFeatures.pl ${srcData}/all_data/processedData $runPath/fv/sty_test.txt $runPath/vocab/stylabels.txt $runPath/labels/rlabel_test.txt $runPath/column_average test") ;

}

sub constituency
{
	system("perl findConstituency.pl ${srcData}/all_data/constituency $runPath/labels/rlabel_train.txt $runPath/vocab constituencylabels.txt");

	system("perl extractConstituency.pl ${srcData}/all_data/constituency/ $runPath/labels/rlabel_train.txt $runPath/vocab/constituencylabels.txt $runPath/fv/constituency_train.txt $runPath/column_average") ;
	system("perl extractConstituency.pl ${srcData}/all_data/constituency/ $runPath/labels/rlabel_test.txt $runPath/vocab/constituencylabels.txt $runPath/fv/constituency_test.txt $runPath/column_average") ;
}









sub sngram
{


	print "-----creating sngrams------\n";
	system("perl createUniqueSNgrams.pl ${srcData}/all_data/sngrams $runPath/labels/rlabel_train.txt $runPath/vocab sngramlabels.txt") ;
	#
	#creates feature vector for each trainining files using the vocab created from above script.
	#
	print "----Extracting sngrams-----------\n";
	system( "perl extract_sngrams.pl ${srcData}/all_data/sngrams/ $runPath/labels/rlabel_train.txt $runPath/vocab/sngramlabels.txt $runPath/fv/sngram_train.txt $runPath/column_average") ;
	#
	#creates feature vector for each test files using the vocab created from above script.
	#
	system("perl extract_sngrams.pl ${srcData}/all_data/sngrams/ $runPath/labels/rlabel_test.txt $runPath/vocab/sngramlabels.txt $runPath/fv/sngram_test.txt $runPath/column_average") ;



}
sub mood
{
	my $inputFile = "/home/upendra/MOOD_AND_STOP_WORDS/unique_mood_words.txt";
	copy($inputFile,"$runPath/vocab/moodlabels.txt");

	#
	#creates feature vector for each trainining files using the vocab created from above script.
	#
	system( "perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_train.txt $inputFile $runPath/fv/mood_train.txt $runPath/column_average")  ;
	#
	#creates feature vector for each test files using the vocab created from above script.
	#
	system("perl extract_words.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_test.txt $inputFile $runPath/fv/mood_test.txt $runPath/column_average") ;
}

sub range
{


	system("perl unique_words_3Ranges.pl ${srcData}/all_data/processedData $runPath/labels/rlabel_train.txt $runPath/labels/rclass_train.txt $runPath/vocab rangelabels.txt") ; ## new use this

	#
	#creates feature vector for each trainining files using the vocab created from above script.
	#
	system( "perl extract_words_3Ranges.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_train.txt $runPath/vocab $runPath/fv/range_train.txt $runPath/column_average")  ;
	#
	#creates feature vector for each test files using the vocab created from above script.
	#
	system("perl extract_words_3Ranges.pl ${srcData}/all_data/processedData/ $runPath/labels/rlabel_test.txt $runPath/vocab $runPath/fv/range_test.txt $runPath/column_average") ;



}










sub NDLF
{
	
}

sub LFdist
{
	
}

sub LM
{
	
}
sub LEX
{
	
}
sub LexSyn
{
	
}




sub syntactic
{

	#print"********************** syntactic unigrams ********************** \n";
	#EXTRACTION
	#unigrams
	system("perl uniquetags_stanford_norm.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_unigram.txt") ;

	system("perl extract_tags_norm.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_unigram.txt $runPath/fv/pos_unigram_train.txt $runPath/column_average") ;
	system("perl extract_tags_norm.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_test.txt $runPath/vocab/pos_unigram.txt $runPath/fv/pos_unigram_test.txt $runPath/column_average") ;

	#print"********************** syntactic bigrams ********************** \n";
	#bigrams
	system("perl uniquetags_stanford_bigram_norm.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_bigram.txt");

	system("perl extract_tags_bigram.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_bigram.txt $runPath/fv/pos_bigram_train.txt $runPath/column_average") ;
	system("perl extract_tags_bigram.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_test.txt $runPath/vocab/pos_bigram.txt $runPath/fv/pos_bigram_test.txt $runPath/column_average") ;

	#print"********************** syntactic trigrams ********************** \n";
	#trigrams
	system("perl uniquetags_stanford_trigrams_norm.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_trigram.txt");

	system("perl extract_tags_trigram.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_train.txt $runPath/vocab/pos_trigram.txt $runPath/fv/pos_trigram_train.txt $runPath/column_average") ;
	system("perl extract_tags_trigram.pl ${srcData}/all_data/pos_stanford/ $runPath/labels/rlabel_test.txt $runPath/vocab/pos_trigram.txt $runPath/fv/pos_trigram_test.txt $runPath/column_average") ;

	#print"********************** syntactic syndep ********************** \n";
	#syn dep
	system("perl uniquesyndep_stanford_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_train.txt $runPath/vocab/syndep.txt");

	system("perl extract_syndep_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_train.txt $runPath/vocab/syndep.txt $runPath/fv/syndep_train.txt $runPath/column_average") ;
	system("perl extract_syndep_norm.pl ${srcData}/all_data/syndep/ $runPath/labels/rlabel_test.txt $runPath/vocab/syndep.txt $runPath/fv/syndep_test.txt $runPath/column_average") ;

	#print"********************** syntactic merging **********************\n";


	## name of the syntactic feature vector file will be 'syn_test.txt'
	mergeFeatureVectors("$runPath/fv","syn", "test", @syn );
	mergeFeatureVectors("$runPath/fv","syn", "train", @syn );

        createSyntacticLabels("$runPath/vocab", "syn",  @syn);
}


sub mergeFeatureVectors
{

	my($srcPath, $modality, $testOrTrain, @types) = @_;


	my @mergedValues = ();
        foreach my $m(0..$#types)
	{
	#	print "Merging $types[$m] to $modality modality\n";
		my $syn_elements = $types[$m];
		my @currValue = ();
		my @currentMerged = ();
		open(FILE,"< $srcPath/${syn_elements}_$testOrTrain.txt") or die("Not Found:  $srcPath/${syn_elements}_$testOrTrain.txt :$!");  
		foreach my $line(<FILE>)
		{
			push(@currValue,trim($line));
		}

		close(FILE);


		if($m == 0)  ## if first modality, final value will be the value of current modality only
		{
			@currentMerged = @currValue;
		}
		else ## if not merge current modality values to whatever is in previous value.
		{
			for (my $i=0; $i<scalar(@currValue); $i++)
			{
				push @currentMerged,"$mergedValues[$i] $currValue[$i]"; 
			}
		}
		@mergedValues = @currentMerged;
	}	

	open(MERGE,"> $srcPath/${modality}_$testOrTrain.txt") or die("Can't create $srcPath/${modality}_$testOrTrain.txt :$!");
	print MERGE join("\n", @mergedValues);
	undef @mergedValues;
	close(MERGE);
}


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}



sub ppl
{


#author language models
print "****************** Perplexity Generation ************************\n";
system("perl createTrainingFiles_rev3.pl $runPath/labels/rlabel_train.txt $runPath/labels/rclass_train.txt ${srcData}/all_data/processed_files/ $runPath/ppl/authorModels/trainingFiles/") ;
print "**************** * creating author count files *************************\n" ;
system("perl srilm_countFiles.pl $runPath/ppl/authorModels/trainingFiles/ $runPath/ppl/authorModels/CountFiles/") ;
print "****************** creating author language models *********************\n" ;
system("perl srilm_LMFiles.pl $runPath/ppl/authorModels/CountFiles/ $runPath/ppl/authorModels/LMFiles/") ;






print "****************** generate ppl for train files *********************\n" ;
system("perl pplGeneratin_3.pl $runPath/labels/rlabel_train.txt ${srcData}/all_data/processed_files/ $runPath/ppl/authorModels/LMFiles/ $runPath/ppl/authorModels/trainingFiles/ $runPath/ppl/train/PPLs/") ;

print "****************** generate ppl for test files *********************\n" ;
system("perl pplGeneratin_3.pl $runPath/labels/rlabel_test.txt ${srcData}/all_data/processed_files/ $runPath/ppl/authorModels/LMFiles/ $runPath/ppl/authorModels/trainingFiles/ $runPath/ppl/test/PPLs/") ;


print "************ read ppl for train files ***************************\n" ;
system("perl readPPL_3.pl $runPath/labels/rlabel_train.txt $runPath/ppl/authorModels/trainingFiles/ $runPath/ppl/train/PPLs/ $runPath/fv/ppl_train.txt $runPath/vocab/ppllabels.txt $runPath/column_average") ;

print "************ read ppl for test files ***************************\n" ;
system("perl readPPL_3.pl $runPath/labels/rlabel_test.txt $runPath/ppl/authorModels/trainingFiles/ $runPath/ppl/test/PPLs/ $runPath/fv/ppl_test.txt $runPath/vocab/ppllabels.txt $runPath/column_average") ;

}





## copies stylabels.txt from folder "fv" to "vcluster_files" folder. all these labels files are stored in vcluster_files folder. Need to generate ppllabels.txt manually looking at output.txt file generated after running batchScript.pl.



sub copyLabelsForClustering
{

=pod
	#print "********************   copying rlabel, rclass, and all training files to vcluster_files  *********************\n";
	use File::Copy;
	copy("$runPath/labels/rlabel_train.txt", "$runPath/vcluster_files/rlabel_train.txt") or die "File cannot be copied.";
	copy("$runPath/labels/rclass_train.txt", "$runPath/vcluster_files/rclass_train.txt") or die "File cannot be copied.";

	foreach my $modality(@mergeModalities)
	{

		copy("$runPath/fv/${modality}_train.txt", "$runPath/vcluster_files/${modality}_train.txt") or die "$runPath/fv/${modality}_train.txt can't be copied.";
		system("perl add_rows_columns.pl $runPath/vcluster_files/rlabel_train.txt $runPath/vcluster_files/${modality}labels.txt $runPath/vcluster_files/${modality}_train.txt");
	}
=cut

}





