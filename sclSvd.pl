#!/usr/bin/perl
use strict;
use lib '/home/upendra/NLP/Softwares/Lingua-EN-Sentence-0.25/lib';
use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS get_acronyms);
require "create_file_hierarchy.pl";
require "variable.pl";
our($h);
use File::Copy;

use PDL::MatrixOps;

use Algorithm::LBFGS;
use Math::GSL::Linalg::SVD;
# create an L-BFGS optimizer
my $o = Algorithm::LBFGS->new;

=pod
my $totalInstances = 2; #number of unlabeled instances
my $n = 3; #number of non-pivot features
my @x = ([0,2,1], [3,1,2]); ## feature vector x_0 and x_1, since total unlabeled instances are 2.
my $lambda = 0.001;#0.5; # this value can be changed. 
my @pls = ([1,1],[0,1]);
=cut
my @x = ();
my $thetaX = ();
my @pls = ();
my $lambda = 0.5;#0.5; # this value can be changed. 
my @weightMatrix = ();




my $srcData	= $ARGV[0]; ## source documents
my $location 	= $ARGV[1]; #location of the main folder
my $folder_name = $ARGV[2]; #actual folder inside which the hierarchy of file is to be created
my $run 	= $ARGV[3];
my $pvtF	= $ARGV[4]; #pivotC
my $nonPvtF	= $ARGV[5]; #non-pivotC
my $newF	= $ARGV[6]; #new
my $destFolder	= $ARGV[7]; #SCLFilesC
my $meanOrMedian= $ARGV[8]; 


my $runPath = "${location}$folder_name/$run";

my $newLabels = "$runPath/vocab/${newF}labels.txt";
my $pivotFile = "$runPath/vocab/${pvtF}labels.txt";
my $nonPivotFile = "$runPath/vocab/${nonPvtF}labels.txt";
my $testFv = "$runPath/fv/${nonPvtF}_test.txt";
my $trainFv = "$runPath/fv/${nonPvtF}_train.txt";

my $testLabel = "$runPath/labels/rlabel_test.txt";
my $trainLabel = "$runPath/labels/rlabel_train.txt";
my $processedData = "$srcData/all_data/processedData";
my $fvPath = "$runPath/fv";



my $destPath = "$runPath/$destFolder";
createNewFolder("$destPath") if (!(-e "$destPath"));

my $weightTransposedFile = "$destPath/WTranspose.txt";
my $UMatrixFile = "$destPath/UMatrix.txt";
my $U_hMatrixFile = "$destPath/U_${h}Matrix.txt";
my $thetaFile = "$destPath/thetaMatrix.txt";
my $newXFile = "$destPath/${newF}X.txt";
my $newXTestFile = "$fvPath/${newF}_test.txt";
my $newXTrainFile = "$fvPath/${newF}_train.txt";


## store the name of all files in @allLabels.
my @allLabels = ();
my $testLabels 	= readFile($testLabel);
my $trainLabels	= readFile($trainLabel);
push @allLabels, @$testLabels;
push @allLabels, @$trainLabels;

## store feature vectors for non-pivot features from all unlabeled instances in @x
my $testFvs 	= parseFV($testFv);
my $trainFvs 	= parseFV($trainFv);
push @x, @$testFvs;
push @x, @$trainFvs;


my $pivots	= readFile($pivotFile);
my $nonPivots	= readFile($nonPivotFile);
my $n = scalar(@$nonPivots);
my $m = scalar(@$pivots);
my $totalInstances = scalar(@x);

my $printPivot = 0; # if 0, don't print otherwise, print pivot features on console.
my $printOptimizedweight = 0; # if 0, don't print otherwise, print.





########## addition for pivot ########################
my $pivotCountPath = "$runPath/pivotCount";
my $binaryValuesFile = "$runPath/pivotCount/${pvtF}${meanOrMedian}Binary.txt";


my $start_run = time(); 

##--------------------------------------
## call the main function
main();
##--------------------------------------
my $end_run = time(); 
my $mins = ($end_run-$start_run)/60;
print "Total time\t$mins mins\n";


# main function that calls other necessary functions
sub main
{
	my $start_run1 = time(); 
	# compute pivot vectors and store in @pls
	computePL();
	my $end_run1 = time(); 
	my $mins1 = ($end_run1-$start_run1)/60;
	print "Time for computing Pl\t$mins1 mins\n";

	print "m\t$m (Pivot Features Count)\nn\t$n (Non-pivot Features Count)\nTotIns\t$totalInstances (Unlabeled Instances Count)\n";
	my $nonPivots = scalar(@pls);
	my $i = 1;
	
	#for each pivot vector
	foreach my $pl(@pls)
	{
		print "\n\n------pivot = ${i}-----------\n" if ($printPivot != 0);
		print "@$pl\n" if ($printPivot != 0);
		lossFunction($pl);
		$i++;
	}


	my $weightMatrixRef = [@weightMatrix];

	## transposing this weight matrix will create a matrix with pivot weight as column
	my $transposedMatrix = transposeMatrix($weightMatrixRef);
	printMatrixFile($transposedMatrix,$weightTransposedFile); # weight matrix
	#computeSVD($transposedMatrix);  ### remove comment for SVD


}

## Compute binary value for each pivot feature for each unlabeled document.
sub computePL
{
	## For each instance, each pivot feature has either 0 or 1 value. So, let's say, pivot value is 1 if the normalized occurrence of pivot feature in current document is at least threshold gamma

	my $plsRef = parseFV($binaryValuesFile);
	@pls = @$plsRef;
	#my $temp = $pls[0];
	#print "@$temp\n";
=pod
	foreach my $l(0..$m-1) ## for each pivot features 
	{
		my $pl_ = ();
		foreach my $j(0..$totalInstances-1) ## for each instance j
		{
			my $currValue = countPivot("$processedData/$allLabels[$j]", $pivots->[$l]);
			my $binaryValue = 0;
			#$binaryValue = 1 if ($currValue >= 0.002);
			$binaryValue = 1 if ($currValue > 0);
			#$binaryValue = $currValue;
			#print "\t\tpivotVal\t$currValue\t($pivots->[$l]\t$binaryValue)\n";
			push @$pl_,$binaryValue;
		}	
		#print "@$pl_\n\n\n\n";
		push @pls, $pl_;
	}	
=cut
}







sub computeSVDNew
{
    my $data = $_[0];
    #my $matrix  = pdl([[3,4],[6,2]]);  # 2x2 matrix
    my ($r1, $s, $r2) = svd($data);
}



sub lossFunction
{
	my $plRef = $_[0];
	my @pl = @$plRef;
	# let there be total of n non-pivot features, therefore w and x_j are vectors with n-1 elements.
	# f(w) = sum_j(1 - w.x_j p_l(x_j))^2 + lambda||w||^2
	# f(w) = sum_j(1 - (w[0].x_j[0] + w[1].x_j[1] + .. + w[n-1].x_j[n-1])p_l(x_j))^2 + l||w||^2 + lamdba( w[0]^2 + .. + w[n-1]^2 )
	# grad f(w) = sum_j(-2 p_l(x_j) x_j[0]   (1 - p_l(x_j) (w[0].x_j[0] + .. + w[n-1].x_j[n-1])) + 2*lambda*w[0], ...,
	#			  sum_j(-2 p_l(x_j) x_j[n-1] (1 - p_l(x_j) w[0].x_j[0] + .. + w[n-1].x_j[n-1])) + 2*lambda*w[n-1]


	#### These values are set just to make sure the code works for two instances and one non-pivot feature.

	#my $totalInstances = 2; #number of unlabeled instances
	#my $n = 1; #number of non-pivot features
	#my @x = ([0], [1]); ## feature vector x_0 and x_1, since total unlabeled instances are 2.
	#my @pl = (0,1); #predictor function for two instances for current pivot feature. 





	my $eval_cb = sub 
	{
		my $w = shift;
		my $f = 0;
		my $g = ();
		my $wSquare = 0;
		my @wDOTx_allValues = ();
		foreach my $j(0..$totalInstances-1) ## for each instance j
		{
			my $wDOTx = 0; 
			## for each non-pivot features ( length of vector w and xj)
			foreach my $i(0..$n-1) 
			{
				## compute the dot product
				$wDOTx = $wDOTx + $w->[$i]*$x[$j][$i]; 
			}			
			## for each j, x_j.w is saved in array which can be used for gradient
			push @wDOTx_allValues, $wDOTx;  
			
			my $plwxj = $pl[$j] * $wDOTx;

			if($plwxj >= -1)  #condition 1 
			{
				if((1- $plwxj) > 0) #condition 1.1 
				{
					#print "--- Condition 1.1 ------\n\n";
					## sum over all instances before adding the L2 regulization term.
					$f = $f + (1 - $wDOTx * $pl[$j]) *  (1 - $wDOTx * $pl[$j]); 
				}
				else #condition 1.2
				{
					#print "--- Condition 1.2 ------\n\n";
					## sum over all instances before adding the L2 regulization term.
					$f = $f + 0; 
				}
			}
			else #condition 2
			{
				#print "--- Condition 2 ------\n\n";
				## sum over all instances before adding the L2 regulization term.
				$f = $f +(-4* $pl[$j]*$wDOTx); 
			}

		}

		# compute ||w||^2
		foreach my $i(0..$n-1) ## for each non-pivot features ( length of vector)
		{
			$wSquare = $wSquare + $w->[$i]*$w->[$i];
		}
		$f = $f + $lambda * $wSquare;  ## This if the final value of function f(w)
      
		#---------- gradient -----------------------------------
		foreach my $i(0..$n-1) ## for each non-pivot features ( length of vector)
		{
			my $g_current = 0;
			foreach my $j(0..$totalInstances-1) ## for each j
			{
				my $wDOTx = $wDOTx_allValues[$j];
				my $plwxj = $pl[$j] * $wDOTx;
				if($plwxj >= -1)  #condition 1 
				{
					if(1- $plwxj > 0) #condition 1.1 
					{
						my $added = (-2*$pl[$j]*$x[$j][$i]*(1 - $wDOTx * $pl[$j]));
						$g_current = $g_current + (-2*$pl[$j]*$x[$j][$i]*(1 - $wDOTx * $pl[$j]));
					}
					else #condition 1.2
					{
					$g_current = $g_current + 0; 
					}
				}
				else #condition 2
				{
					$g_current = $g_current + (-4* $pl[$j]*$x[$j][$i]); ## sum over all instances before adding the L2 regulization term.
				}
				
			}
			$g_current = $g_current + 2* $lambda * $w->[$i];
			#$g_current = sprintf "%.5f", $g_current;
			push @$g, $g_current;
			
		}
		#print "\ngradient: @$g\n";
		return ($f, $g);
	};

  my $w0 = initiliazeVector($n); # initial point
  my $w = $o->fmin($eval_cb, $w0); # 
  push @weightMatrix, $w;
  print "Optimized weight vector: @$w\n" if ($printOptimizedweight != 0); 

}

## returns the normalized count of given pivot feature on given document.
sub countPivot
{
	my ($unlabelDoc, $pivot) = @_;
	open(FILE,"< $unlabelDoc") or die("Could not open $unlabelDoc:$!");
	my($content) = do { local $/; <FILE> };
	my $tokenCount = 0;
	$tokenCount += scalar(split(/\s+/, $content));
	$content =~ s/[[:punct:]]/ /g;  ## remove all punctuations before computing the occurrence of pivot feature in current file.
	my $count  = () = $content =~ /\s$pivot\s/gi;
	my $normCount = $count/$tokenCount;
	return $normCount;
	
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#split the feature vectors and store in matrix
sub parseFV
{
	my $file = $_[0];
	my $temp = ();
	open(FILE,"< $file") or die("Could not open $file:$!");  
	foreach my $line(<FILE>)
	{
		my $line = trim($line);
		my @splitSpace = split(/\s+/, $line);
		#print "\t\t".scalar(@splitSpace)."*$splitSpace[0]\n";
		push(@$temp,[@splitSpace]);
	}
	close(FILE);
	return $temp;
}



sub readFile
{
	my $file = $_[0];
	my $temp = ();
	open(FILE,"< $file") or die("Could not open $file:$!");  
	foreach my $line(<FILE>)
	{
		push(@$temp,trim($line));
	}
	close(FILE);

	return $temp;
}





sub printMatrix
{
	my $weightMatrixRef = $_[0];
   	for my $r (0..$#{$weightMatrixRef}) {
        for my $c (0..$#{$weightMatrixRef->[$r]}) { print qq{$weightMatrixRef->[$r][$c], } }; print qq{\n}; }
	#print "----------------------------\n";
	

}

sub printMatrixOnlyX
{
	my $xRef = $_[0];
   	for my $r (0..$#{$xRef}) 
	{
		my @x_temp = $xRef->[$r];
		for my $c (0..$#{$xRef->[$r]}) 
		{ 
			print qq{$x_temp[$c], };
		}
		print qq{\n}; 
	}
	#print "----------------------------\n";

}


sub printVectorFile
{

	my ($vectorRef, $file) = @_;
	#print "-----printing vector to file-----\n";
 	for my $c (0..scalar(@$vectorRef)-1) 
	{ 
		print FILE $vectorRef->[$c].", ";
	}; 
	#print "----------------------------\n";
}


sub printMatrixFile
{


	my ($weightMatrixRef, $file) = @_;
	open(FILE,"> $file") or die("Can't create $file:$!"); 
      	for my $r (0..$#{$weightMatrixRef}) 
	{
		for my $c (0..$#{$weightMatrixRef->[$r]}) 
		{ 
			print FILE qq{$weightMatrixRef->[$r][$c] } 
		}; 
		print FILE qq{\n}; 
	}
	#print "----------------------------\n";

}

=pod
sub printVector
{
	my ($vectorRef, $file) = @_;
	print "-----printing vector-----\n";
 	for my $c (0..scalar(@$vectorRef)-1) 
	{ 
		print $vectorRef->[$c].", ";
	}; 
	print "----------------------------\n";

}
=cut

sub transposeMatrix
{
	my $rowsRef = $_[0];#ogirinal matrix
	my @rows = @$rowsRef;
	my @transposed = ();

	for my $row (@rows) 
	{
		for my $column (0 .. $#{$row}) 
		{
			push(@{$transposed[$column]}, $row->[$column]);
		}
	}

	return \@transposed;
}




# function to compute SVD
sub computeSVD
{
    my $data = $_[0];
    # Create object.
    my $svd = Math::GSL::Linalg::SVD->new( { verbose => 1 } );

    # Load data.
    $svd->load_data( { data => $data } );

    # Perform singular value decomposition using the Golub-Reinsch algorithm (this is the default - see METHODS).
    # To perform eigen decomposition pass 'eign' as algorithm argument - see METHODS.
    $svd->decompose( { algorithm => q{gd} } );

    # Pass results - see METHODS for more details.
    my ($S_vec_ref, $U_mat_ref, $V_mat_ref, $original_data_ref) = $svd->results;
    print "\n";
    printMatrixSize ($U_mat_ref, "U");
    printMatrixSize ($V_mat_ref, "V");

#=pod

    # Print elements of matrix U.
    #print qq{\nPrint matrix U\n}; 
    #printMatrix($U_mat_ref); 



    ## svd(A_n_m) = U_n_n but thin svd returns U_n_m if n > m. Therefore, theta will have 
    printMatrixFile($U_mat_ref,$UMatrixFile); # $U_mat_ref = n*m

### getHRows.pl computed everything besides here upto =cut. ###
=pod
	
    my $U_Trns = transposeMatrix($U_mat_ref); ## U_Trns = m*n

    my $theta = getHRows($U_Trns, $h); ## $theta = h*n
    my $theta_Trns = transposeMatrix($theta); ## theta_Trns has n*h because FV of x = 1*n. Therefore, x.theta  = 1*h = prjected fv
    printMatrixFile($theta_Trns,$thetaFile); ##
    my $thetaDotX = computeThetaX($theta_Trns, \@x);
    printMatrixFile($thetaDotX,$newXFile); ##

    printNewVocabFile($theta_Trns, $newLabels);


    my $newTest = computeThetaX($theta_Trns, $testFvs);
    my $newTrain = computeThetaX($theta_Trns, $trainFvs);

    printMatrixFile($newTest,$newXTestFile); ##
    printMatrixFile($newTrain,$newXTrainFile); ##

    copyFiles();

=cut
### upto here

}


sub copyFiles
{
    copy($newXTestFile, "$destPath/${newF}_test.txt") or die($!);
    copy($newXTrainFile, "$destPath/${newF}_train.txt") or die($!);
}
sub printNewVocabFile
{

	my ($projectionRef, $file) = @_; ## columns of the projectionMatrix will be equal to the number of new features.
	my ($r2,$c2)=matrix_count_rows_cols($projectionRef);


	open(FILE,"> $file") or die("Can't create $file:$!"); 

      	for my $i (1..$c2) 
	{
		print FILE "new_$i\n"; 
	}
	#print "----------------------------\n";

}


sub computeThetaX
{
	my ($thetaRef, $xRef)= @_;
	my $thetaX_ = ();
	my $newX = ();
        #print "--- computing theta----\n";
	foreach my $j(0..scalar(@$xRef)-1)
	{
		my @_x = $xRef->[$j];
		my $r_mat1 = [@_x];
		undef (@_x);
		my $r_mat2 = $thetaRef;
		my $r_product = ();
		my ($r1,$c1)=matrix_count_rows_cols($r_mat1);
		my ($r2,$c2)=matrix_count_rows_cols($r_mat2);

		#print $c1,$c2,"\n";
		#print $r1,$r2,"\n";

		die "matrix 1 has $c1 columns and matrix 2 has $r2 rows>" 
		. " Cannot multiply\n" unless ($c1==$r2);
		my $i = 0; ## since we are multiplying vector and matrix.
		for (my $j=0;$j<$c2;$j++) 
		{
			my $sum=0;
			for (my $k=0;$k<$c1;$k++) 
			{
				$sum+=$r_mat1->[$i][$k]*$r_mat2->[$k][$j];
			}
			$r_product->[$j]=$sum;
		}
		push @$newX, $r_product;

	}
	return $newX;
}





sub matrix_count_rows_cols { 
    my ($r_mat)=@_;
    my $num_rows=@$r_mat;
    my $num_cols=@{$r_mat->[0]};
    ($num_rows,$num_cols);
}


sub printMatrixSize
{
	my ($matRef, $type)= @_;
	my $rows = $#{$matRef}+1;
	my $cols = $#{$matRef->[0]}+1;
	print "\t\tSize of $type = $rows * $cols\n";
}

sub getHRows
{
	my ($U_mat_ref, $h)= @_;
	my $U_h = ();
	if ($h <= $#{$U_mat_ref})
	{
		for my $r (0..$h-1) 
		{
			$U_h->[$r] = $U_mat_ref->[$r];
		}
	}
	else
	{
		$U_h = $U_mat_ref;
	}
	return $U_h;
}


sub initiliazeVector
{
	my $_n = $_[0];
	my $arr = ();
	foreach my $i (0..$_n-1) 
	{
    	push @$arr, 0;
	}
	return $arr;
}






		
