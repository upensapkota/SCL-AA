#!/usr/bin/perl 
use strict;
require "variable.pl";

#my $location_weka = "/home/upendra/NLP/Softwares/weka-3-6-4";
my $location_weka = "/home/upendra/NLP/Softwares/weka-3-7-6";
my $pathToWekaFolder = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/TwoTopics10Shortened/UK-World/weka/syndep";

	print "** Classifying using weka**\n";

		system("java -Xmx23000m -cp $location_weka/weka.jar weka.classifiers.functions.SMO  -v -o -t $pathToWekaFolder/classic/classic_train.arff -T $pathToWekaFolder/classic/classic_test.arff -i  > $pathToWekaFolder/smo_classic.txt");




