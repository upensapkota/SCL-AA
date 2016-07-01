#!/usr/bin/perl
use strict;
use lib '/home/upendra/NLP/Softwares/Lingua-EN-Sentence-0.25/lib';
use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS get_acronyms);
require "create_file_hierarchy.pl";
require "variable.pl";
use File::Copy;

use PDL::MatrixOps;

my $srcData	= $ARGV[0]; ## source documents
my $location 	= $ARGV[1]; #location of the main folder
my $folder_name = $ARGV[2]; #actual folder inside which the hierarchy of file is to be created
my $run 	= $ARGV[3];
my $pvtF	= $ARGV[4]; #pivotC
my $nonPvtF	= $ARGV[5]; #non-pivotC
my $SCFiles	= $ARGV[6]; #new
my $newF	= $ARGV[7]; #new
my $h		= $ARGV[8]; #new

$newF = "$newF$h";

my $runPath = "${location}$folder_name/$run";
my $fvPath = "$runPath/fv";
my $newLabels = "$runPath/vocab/${newF}labels.txt";
my $testFv = "$runPath/fv/${nonPvtF}_test.txt";
my $trainFv = "$runPath/fv/${nonPvtF}_train.txt";

my $UMatrixFile = "$runPath/$SCFiles/UMatrix.txt";
my $WTransposeFile = "$runPath/$SCFiles/WTranspose.txt";

my $dstPath = "$runPath/$SCFiles/$h"; ### scfliles path

createNewFolder("$dstPath") if (!(-e "$dstPath"));


my $U_hMatrixFile = "$dstPath/U_${h}Matrix.txt";
my $thetaFile = "$dstPath/thetaMatrix.txt";
my $newXFile = "$dstPath/${newF}X.txt";
my $newXTestFile = "$fvPath/${newF}_test.txt";
my $newXTrainFile = "$fvPath/${newF}_train.txt";



my $testFv = "$runPath/fv/${nonPvtF}_test.txt";
my $trainFv = "$runPath/fv/${nonPvtF}_train.txt";
my $processedData = "$srcData/all_data/processedData";


## store feature vectors for non-pivot features from all unlabeled instances in @x
my $testFvs 	= parseFV($testFv);
my $trainFvs 	= parseFV($trainFv);
my @x = (); ## feature vector computed from all unlabelled instances based on occurrence of non-pivot features
push @x, @$testFvs;
push @x, @$trainFvs;


main();


sub main
{
	computeNewFeatures("$WTransposeFile");
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
}


sub printMatrix
{
	my $weightMatrixRef = $_[0];
   	for my $r (0..$#{$weightMatrixRef}) {
        for my $c (0..$#{$weightMatrixRef->[$r]}) { print qq{$weightMatrixRef->[$r][$c], } }; print qq{\n}; }
	#print "----------------------------\n";
	

}


sub readMatrixFile
{
	my $file = $_[0];
        my $weightMatrixRef = ();
	my @weightMatrix = ();
        open(FV,"< $file") or die("Could not open $file: $!");
   
	foreach my $line (<FV>)
	{
		my @fvs = ();
		$line= trim($line);
		@fvs = split( /\s+/, $line );
		push @weightMatrix, \@fvs;
		#print "size: ".scalar(@fvs)."\n";
	}
	close(FV); 

	my $weightMatrixRef = [@weightMatrix];

}


# function to get h rows from U-matrix
sub computeNewFeatures
{

    my $file = $_[0];
    my $UMatrixFile = ();
    my $U_mat_ref = ();
    $U_mat_ref = readMatrixFile($file);
    printMatrixSize ($U_mat_ref, "UMatrix");

=pod
    my $U_Trns = transposeMatrix($U_mat_ref); ## U_Trns = m*n

    my $theta = getHRows($U_Trns, $h); ## $theta = h*n
    my $theta_Trns = transposeMatrix($theta); ## theta_Trns has n*h because FV of x = 1*n. Therefore, x.theta  = 1*h = prjected fv
=cut

######## this is not to do SVD ############
   my $theta_Trns = $U_mat_ref; 
    printMatrixFile($theta_Trns,$thetaFile); ##
    printMatrixSize ($theta_Trns, "Theta");


    my $thetaDotX = computeThetaX($theta_Trns, \@x);
    printMatrixFile($thetaDotX,$newXFile); ##


    printNewVocabFile($theta_Trns, $newLabels);


    my $newTest = computeThetaX($theta_Trns, $testFvs);
    my $newTrain = computeThetaX($theta_Trns, $trainFvs);

    printMatrixSize ($newTest, "Theta.Xtest");
    printMatrixSize ($newTrain, "Theta.Xtrain");
    printMatrixFile($newTest,$newXTestFile); ##
    printMatrixFile($newTrain,$newXTrainFile); ##

    copyFilesTo($dstPath);



}



sub getHRows
{

	my $U_mat_ref = $_[0];

	print "Reduced dimensionality h = $h\n";
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

sub printMatrixSize
{
	my ($matRef, $type)= @_;
	my $rows = $#{$matRef}+1;
	my $cols = $#{$matRef->[0]}+1;
	print "\t\tSize of $type = $rows * $cols\n";
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

sub copyFilesTo
{
	my $destPath = $_[0];
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

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
