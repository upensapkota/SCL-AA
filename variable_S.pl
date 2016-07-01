#!/usr/bin/perl 
use strict;
use warnings;
use File::Basename;

		our $dataset 		= "StewarDCorpus";
		my $file_name_delimiter 	= "_";
		my $authorIndex 		= 0;
		our $numberOfSemanticFeatures 	= 3500;
		our $numberOfCharngrams 	= 3500;
#		our $numberOfCharngrams 	= 10000; ## just to replicate stamatatos experiments.
		our $numberOfSNGrams 		= 3500;
		our $byteOrCharacterNgram	= "byte";
		our %modalities 	=('sty'			=> \&stylistic,  
					  'syndep'		=> \&syndep,
					  'constituency'		=> \&constituency,
					  'stop2'		=> \&stop2,
					  'stop5'		=> \&stop5,
					  'stop10'		=> \&stop10,
					  'stop20'		=> \&stop20,
					  'stop30'		=> \&stop30,
					  'stop50'		=> \&stop50,
					  'stop80'		=> \&stop80,
					  'stop100'		=> \&stop100,
					  'sem2'		=> \&semantic2,
					  'sem5'		=> \&semantic5,
					  'sem10'		=> \&semantic10,
					  'sem20'		=> \&semantic20,
					  'sem30'		=> \&semantic30,
					  'sem50'		=> \&semantic50,
					  'sem80'		=> \&semantic80,
					  'sem100'		=> \&semantic100,
					  'stop'    		=> \&stop, 
					  'charngram2'		=> \&charngram2,  
					  'charngram5'    	=> \&charngram5,
					  'charngram10'		=> \&charngram10,  
					  'charngram20'    	=> \&charngram20,
					  'charngram30'		=> \&charngram30,  
					  'charngram50'    	=> \&charngram50,
					  'charngram80'		=> \&charngram80,  
					  'charngram100'    	=> \&charngram100,

  					);

=pod
		our @mergeModalities	=	(
						['sty'],
						['sem2'],
						['sem5'],
						['sem10'],
						['sem20'],
						['sem30'],
						['sem50'],
						['sem80'],
						['sem100'],
						['charngram2'],
						['charngram5'],
						['charngram10'],
						['charngram20'],
						['charngram30'],
						['charngram50'],
						['charngram80'],
						['charngram100'],
						);
=cut

#=pod
		our @mergeModalities	=	(
						['sem','stop','sty','charngram']
						);



#=cut
=pod
		our @mergeModalities	=	(
						['stop2'],
						['stop5'],
						['stop10'],
						['stop20'],
						['stop30'],
						['stop50'],
						['stop80'],
						['stop100'],
						['syndep'],
						);
=cut





#### the values in @modalities array will be used to compute the new features, if all are commented, fv computer earlier will be used to merge different combination as defined in @mergedModalities.
=pod
		our @modalities 	=(
					'stop2',
					'stop5',
					'stop10',
					'stop20',
					'stop30',
					'stop50',
					'stop80',
					'stop100',
					'syndep',
					   );
=cut



=pod
		our @modalities 	=(
					'sty',
					'constituency',
					'sem2',
					'sem5',
					'sem10',
					'sem20',
					'sem30',
					'sem50',
					'sem80',
					'sem100',
					'charngram2',
					'charngram5',
					'charngram10',
					'charngram20',
					'charngram30',
					'charngram50',
					'charngram80',
					'charngram100',
					   );
=cut
#=pod
		our @modalities 	=(
					'sem',
					'sty',
					'charngram',
					'stop',
					   );
#=cut				   


		sub getAuthorName
		{
			my ($file_path, $profileType) = @_;
			my ( $fname, $folder ) = fileparse($file_path);
			
			$fname =~ s/\.txt//g;
			$fname =~ /(^.\d*)./;
			my $class_name = $1;
			return $class_name;
       		 }

		sub getTopicName
		{
			my ($file_path, $profileType) = @_;
			my ( $fname, $folder ) = fileparse($file_path);
			$fname =~ s/\.txt//g;
			$fname =~ /(.)\d*$/;		
			my $topicName = $1;
			return $topicName;
		}
		
		sub getGenreName
		{
			my ($file_path, $profileType) = @_;
			my ( $fname, $folder ) = fileparse($file_path);
			
			$fname =~ s/\.txt//g;
			$fname =~ /(^.\d*)(.)\d(.)/;
			my $genreName = $2; #returns the first character
           		 return $genreName;
		}

		
		
	
		return 1;
