#!/usr/bin/perl 
use strict;
require "variable.pl";
require "create_file_hierarchy.pl";
our (@mergeModalities);

my $directory_path = $ARGV[0];
my $fname 	   = $ARGV[1]; 

my $cluster_numbers = 10;




#my @folders = ("T50115-T50013","T50013-T50115","T50048-T50128","T50128-T50048");
#my @folders = ("Marijuana-Sexdisc", "Sexdisc-Marijuana","Iraqwar-Sexdisc", "Sexdisc-Iraqwar","Church-Gay", "Gay-Church");


#=pod
####################  steward 10-fold cross-validation ########################
### perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/ 

#my @fnames = ('TwoTopics_B', 'TwoTopics_C','TwoTopics_D', 'TwoTopics_E','TwoTopics_P', 'TwoTopics_S');
my @fnames = ('TwoTopics_P', 'TwoTopics_S');
my @folders = ('Marijuana-Sexdisc', 'Sexdisc-Marijuana','Iraqwar-Sexdisc','Sexdisc-Iraqwar','Church-Gay','Gay-Church','Church-Sexdisc','Sexdisc-Church','Privacy-Sexdisc','Sexdisc-Privacy','Gay-Sexdisc','Sexdisc-Gay','Church-Marijuana','Marijuana-Church','Privacy-Marijuana','Marijuana-Privacy','Iraqwar-Marijuana','Marijuana-Iraqwar','Gay-Marijuana','Marijuana-Gay','Privacy-Church','Church-Privacy','Iraqwar-Church','Church-Iraqwar','Iraqwar-Privacy','Privacy-Iraqwar','Gay-Privacy','Privacy-Gay','Gay-Iraqwar','Iraqwar-Gay');
my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/perGenrePerTopic";
#=cut


=pod
####################  guardian 10-fold cross-validation ########################
my @fnames = ("TwoTopics10Shortened");
my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/perTopicGuardian10TrainShort";
####perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/
=cut

#my @fnames = ("TwoTopics10Shortened");
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
#my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/guardianCorpus/perGenrePerTopicSeed1";
####perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/


#my @fnames = ("TwoTopics10Shortened");
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
#my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/perTopicGuardian10TrainShort";
####perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/TheGuardianCorpus/TwoTopics10TrainShortened/


#my @fnames = ("TwoTopics3Train10TestShortened","TwoTopics5Train10TestShortened","TwoTopics7Train10TestShortened");
#my @fnames = ("TwoTopics1Train10TestShortened");
#my @folders = ('UK-World','World-UK','Society-World','World-Society','Politics-World','World-Politics','Society-UK','UK-Society','Politics-UK','UK-Politics','Politics-Society','Society-Politics');
#my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/multipleTrainSameTestGuardian";




########### single topic, (two-genres) cross-genre ###################
### perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/steward_corpus/singleTopicTwoGenresShortened/ 

#my @fnames = ('TwoGenres_Church','TwoGenres_Gay','TwoGenres_Iraqwar','TwoGenres_Marijuana','TwoGenres_Privacy','TwoGenres_Sexdisc');
#my @folders = ('Discussion-Essay','Essay-Discussion','Chat-Essay','Essay-Chat','PhoneInterview-Essay','Essay-PhoneInterview','Blog-Essay','Essay-Blog','Email-Essay','Essay-Email','Chat-Discussion','Discussion-Chat','PhoneInterview-Discussion','Discussion-PhoneInterview','Blog-Discussion','Discussion-Blog','Email-Discussion','Discussion-Email','PhoneInterview-Chat','Chat-PhoneInterview','Blog-Chat','Chat-Blog','Email-Chat','Chat-Email','Blog-PhoneInterview','PhoneInterview-Blog','Email-PhoneInterview','PhoneInterview-Email','Email-Blog','Blog-Email');
#my $output = "/home/upendra/NLP/CROSS-DOMAIN/Experiments/10CVSingleTopicOutput/perTopicTwoGenres";



my $location_weka = "/home/upendra/NLP/Softwares/weka-3-7-6";


my @testTrain = ("train", "test");




# perl 10FCVSingleTopic.pl /home/upendra/NLP/CROSS-DOMAIN/Experiments/steward_corpus/TwoTopicsSingleGenreShortened/

my %trainTopics = ();


foreach my $fname(@fnames)
{
	  my $outputPath = "$output/$fname";
  createNewFolder("$outputPath") if (!(-e "$outputPath"));
  print "---------------------$fname-------------------------\n";
  foreach my $run(@folders)
  {
  #    system("perl batchScript_arff.pl $directory_path $fname $cluster_numbers $run");

    my $runPath = "$directory_path$fname/$run";
    #print "$runPath\n";

    my @splits  = split(/-/, $run);
         my $trainTopic = $splits[0];
    foreach my $testOrTrain(@testTrain)
    {
      if( $testOrTrain eq "train" && !(exists $trainTopics{"$fname-$trainTopic"}) )
      {    
      
        print "\t10 Fold Cross Validation on $trainTopic($testOrTrain) -$run \n";
        foreach my $i(0..$#mergeModalities)
        {
          my @modalities = @{$mergeModalities[$i]};
          my $merged = join("+",@modalities);
          my $pathToWekaFolder = "$runPath/weka/$merged/classic";
          print "\t\t For features $merged \n";
     #### For 10 fold cross-validation###
       system("java -Dfile.encoding=utf-8 -Xmx23000m -cp  $location_weka/weka.jar weka.classifiers.functions.SMO  -o -t $pathToWekaFolder/classic_$testOrTrain.arff > $outputPath/smo_${trainTopic}_$merged.txt");

  #### For 5 fold cross-validation###
   #system("java -Dfile.encoding=utf-8 -Xmx23000m -cp  $location_weka/weka.jar weka.classifiers.functions.SMO -x 5  -o -t $pathToWekaFolder/classic_$testOrTrain.arff > $outputPath/smo_${trainTopic}_$merged.txt");
        }
        $trainTopics{"$fname-$trainTopic"}++;
    
      }
    }


  }
}


    #print "***************END***********************\n";
