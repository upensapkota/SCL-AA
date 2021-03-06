#!/usr/bin/perl 
use strict;
use lib '/home/upendra/NLP/Softwares/Algorithm-LibLinear-0.10/lib/';
use Algorithm::LibLinear;
  # Constructs a model for L2-regularized L2 loss support vector classification.
  my $learner = Algorithm::LibLinear->new(
    cost => 1,
    epsilon => 0.01,
    solver => 'L2R_L2LOSS_SVC_DUAL',
    weights => [
      +{ label => 1, weight => 1, },
      +{ label => -1, weight => 1, },
    ],
  );
  # Loads a training data set from DATA filehandle.
  my $data_set = Algorithm::LibLinear::DataSet->load(fh => \*DATA);
  # Executes cross validation.
  my $accuracy = $learner->cross_validation(data_set => $data_set, num_folds => 5);
  # Executes training.
  my $classifier = $learner->train(data_set => $data_set);
  # Determines which (+1 or -1) is the class for the given feature to belong.
  #my $class_label = $classifier->predict(feature => +{ 1 => 0.38, 2 => -0.5, ... });


__DATA__
+1 1:0.708333 2:1 3:1 4:-0.320755 5:-0.105023 6:-1 7:1 8:-0.419847 9:-1 10:-0.225806 12:1 13:-1 
-1 1:0.583333 2:-1 3:0.333333 4:-0.603774 5:1 6:-1 7:1 8:0.358779 9:-1 10:-0.483871 12:-1 13:1 
+1 1:0.166667 2:1 3:-0.333333 4:-0.433962 5:-0.383562 6:-1 7:-1 8:0.0687023 9:-1 10:-0.903226 11:-1 12:-1 13:1 
-1 1:0.458333 2:1 3:1 4:-0.358491 5:-0.374429 6:-1 7:-1 8:-0.480916 9:1 10:-0.935484 12:-0.333333 13:1 
-1 1:0.875 2:-1 3:-0.333333 4:-0.509434 5:-0.347032 6:-1 7:1 8:-0.236641 9:1 10:-0.935484 11:-1 12:-0.333333 13:-1
