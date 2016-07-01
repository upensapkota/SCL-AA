#!/usr/bin/perl 
use strict;
require "NormalizeMatrixByFeatures.pl";
my $instances_path	=$ARGV[0];
my $author_path 	=$ARGV[1];
my $ppl_path		=$ARGV[2];
my $matrix_file		=$ARGV[3];
my $pplalabels		=$ARGV[4];
my $cols_avg		=$ARGV[5];

my @RLabel=();
my @allFileNames=();
my @matrix = ();
my @row = ();

#for comparision, for creating matrix file...match the features exactly with its test file
#get the filenames from the .rlabel file
sub readTestInstances($)
{
    open(RLABELHandle,"< @_") or die("Could not open file.");
    foreach my $line (<RLABELHandle>)
	{
	    push(@RLabel,$line);
	  
	}
    close(RLABELHandle);
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub getPPLs()
{
 	opendir(DIR, $author_path);
       	#create a hash with keys as author names, values will be the training data
	my @authorlist= grep !/^\.\.?$/,readdir(DIR);

        #generate ppllabels.txt based on the order of author in the array
        use File::Basename;
	my($filename, $directories) = fileparse($matrix_file);
        open(PPLLabels, "> $pplalabels") or die (" Can't create $pplalabels");
        foreach my $pplAuthor(@authorlist)
	{
		 $pplAuthor =~ s/\.txt//i;
		# $pplAuthor =~ s/^\-+//i;
		# $pplAuthor =~ s/\-+$//i;
		 print PPLLabels "$pplAuthor\n";
	}
        close(PPLLabels);


        close(DIR);
    #loop through all instances (posts)
    foreach my $rlabels (@RLabel)
    {
	#open a file to write the ppl values to its corresponding posts
	#open(WRITEPPL,">> $matrix_file") or die("Could not open file.");
	
         my $total_ppl = 0;
         my @row = ();
	#loop through all the ppl files
	 foreach my $author(@authorlist)
	{
                
		my $author_2 = $author;
		$author_2 =~ s/\.txt//i;

                ###### this print information was originally used for finding ppl labels, but I have made it automatic###############
#	    	print "$author_2 $rlabels\t";	


		#retrieve the ppl values for the corresponding model and write it to the file
		open(PPL,"< $ppl_path$author_2"."_"."$rlabels") or die("Could not open $ppl_path$author_2"."_"."$rlabels");
               #
               # If the file is empty, it only has one line and second line might be blank, and does not contain any keyword "zeroprobs" on second line, so we assume ppl to be 0 for empty files.
               #
                my $pplValue = 0;
               foreach my $line (<PPL>)
		{   
		    my @pplVal=split(/ /,$line);
		    if($pplVal[1] eq "zeroprobs,")
		    {   
			$pplValue = $pplVal[5];	
                        $total_ppl += $pplValue; 
                     
		    }

		}
               # push @pplVector, $pplValue;	
		push @row, $pplValue;	              
         	close(PPL);  
	}
 
        push @matrix, [@row];
        undef (@row);
      }
}

sub writeToFile()
{
  #my @normalized_matrix = normalize($matrix_file, $cols_avg, @matrix);
my @normalized_matrix =  @matrix;
   undef (@matrix);
  open(VECTOR,"> $matrix_file") or die("Could not open $matrix_file");
 
   foreach my $i(0..$#normalized_matrix)
    {
	print VECTOR "@{$normalized_matrix[$i]}\n";
    }
    close(VECTOR);
    undef (@normalized_matrix);
}


sub unlinkFile($)
	{
	my  $target1= "@_";
	 if(-e "$target1")
		   {
		   unlink("$target1");
		  # print " Message: $target1 already existed and successfully deleted before crating new.\n";
		   }
	}
unlinkFile($matrix_file);
#This call pushes all file names into an array
readTestInstances($instances_path);


#this call
getPPLs();
writeToFile();
