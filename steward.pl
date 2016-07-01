#!/usr/bin/perl 
use strict;
use warnings;
use File::Basename;

		our $dataset 		= "StewarDCorpus";
		my $file_name_delimiter 	= "_";
		my $authorIndex 		= 0;
		our $numberOfSemanticFeatures 	= 3500;
		our $numberOfCharngrams 	= 3500;
		our %modalities 	=('sty'		=> \&stylistic,  
					  'sem'		=> \&semantic,
					  'ppl'    	=> \&ppl,
					  'charngram'   => \&charngram, 
					  'mood'    	=> \&mood,
					  'stop'    	=> \&stop, 
						);

		our @mergeModalities 	=('sem');
		#our @mergeModalities 	=('stop');
		#our @mergeModalities 	=('mood');
		#our @mergeModalities 	=('charngram');
		#our @mergeModalities 	=('mood','stop');
		#our @mergeModalities 	=('mood','stop','sem','charngram');
		#our @mergeModalities 	=('mood','stop','charngram');
		#our @mergeModalities 	=('mood','stop','sem');
		our @modalities 	=(
					  #'mood',
					  #'stop',
					  #'charngram',
					  #'sem'
					  #'sty',
					  #'ppl',
					   );
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
