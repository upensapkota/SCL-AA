#!/usr/bin/perl 
use strict;
use warnings;
use File::Basename;

		our $dataset 		= "ScheinCorpusAndGuardianCorpus";
		my $file_name_delimiter 	= "_";
		my $authorIndex 		= 0;
		our $numberOfSemanticFeatures 	= 3500;

		our $numberOfCharngrams 	= 3500;
		our $n		 		= 3;
		our $byteOrCharacterNgram	= "byte";
		our $numberOfPivotFeatures	= 100; # top most frequent character$n$grams.
		#our $h				= 50; ## No. of new scl features, reduced dimensionality
		our $h				= "noSVD"; ## only when no SVD is done
#=pod
############ Coling2014- For pivot = char-ngrams, non-pivot = BOW+Stop
# 
		my $newFileName 	= "newC";

		our %modalities 	=(
					  'pivotC'    	=> \&pivotC_charngram,
					  'non-pivotC' 	=> \&nonPivotC_semanticAndStop, 
					  'sem' 	=> \&semantic, 
					  'stop' 	=> \&stop, 
					  'charngram'   => \&charngram,
  					);
=pod

		our @mergeModalities	=	(
						["pivotC"],
						["non-pivotC"],
						["newC${h}"],
						["non-pivotC","pivotC"],
						["non-pivotC", "pivotC","newC${h}"],
						);
=cut
#=pod
		our @mergeModalities	=	(
						["pivotC","newC${h}"],
						);

#=cut

#=pod

		our @modalities 	=("pivotC",
					"non-pivotC",
					);
#=cut


=pod

		our @modalities 	=("stop",
					 "charngram",
					"sem",
					"pivotC",
					"non-pivotC",
					);
=cut

#=cut



=pod
############ NAACL2015- pivot = beg-punct+mid-punct, non-pivot = remaining 8 categories of char ngrams (non-pivotN).
# we assume that 10 categories of char n-grams are already computed. If not, we first have to run charngram subfunction in batchscript.pl. 
		my $newFileName 	= "newN";
		our %modalities 	=(
					  'pivotN'    	=> \&PivotN-begPlusEndPunct,
					  'non-pivotN' 	=> \&nonPivotN-8Categories, 
  					);

		our @mergeModalities	=	(
						["non-pivotN"],
						["newN"],
						["non-pivotN", "newN"],
						["non-pivotN","pivotN"],
						["non-pivotN", "pivotN","newN"],
						);

=cut

############ For pivot = stop, non-pivot = BOW
=pod

		my $newFileName 	= "new";
		our %modalities 	=(
					  'stop'    	=> \&stop,
					  'sem'    	=> \&semantic, 
  					);

		our @mergeModalities	=	(
						["sem"],
						["new"],
						["sem","new"],
						["sem","stop"],
						["sem","stop","new"],
						);

=cut




#### the values in @modalities array will be used to compute the new features, if all are commented, fv computed earlier will be used to merge different combination as defined in @mergedModalities.

=pod
		our @modalities 	=(
					'charPrefix',
					'charOther',
					'charMultiWord',
					'charEntireWord',
					'charSuffix',
					'constituency',
					'charngram',
					   );

			


		our @modalities 	=(
					'stop',
					'sem',
					   );	   
=cut
		sub getAuthorName
		{
			my ($FULL_FILE_NAME,$dataType) = @_;

			my @FileName = split(/\//,$FULL_FILE_NAME);
			my $fname=$FileName[scalar(@FileName)-1];
                        my $class_name = "";
                        my @splitFilename = split(/$file_name_delimiter/,$fname);
	       		$class_name=$splitFilename[$authorIndex];
                        return $class_name;
                 }


		sub getTopicName
		{
			my ($FULL_FILE_NAME,$dataType) = @_;

			my @FileName = split(/\//,$FULL_FILE_NAME);
			my $fname=$FileName[scalar(@FileName)-1];
                        my $class_name = "";
                        my @splitFilename = split(/$file_name_delimiter/,$fname);
	       		$class_name=$splitFilename[1];
                        return $class_name;
                 }


		
		
	
		return 1;
