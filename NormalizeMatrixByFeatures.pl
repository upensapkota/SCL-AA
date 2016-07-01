#!/usr/bin/perl 
use strict;
use File::Basename;

sub normalize($)
{
	my ($fv_file, $cols_avg , @matrix) = @_;
        # print "fv_file: $fv_file\n";
        # print "avg_folder: $cols_avg\n";
	#print "Matrix:@matrix\n";
      
	my @result_matrix = ();
	my @col_norm      = ();
        my $col_norm_string = "";
	my ($fname, $folder) = fileparse($fv_file);
       # print "fname: $fname\n";
       #  print "folder: $folder\n";

	if ( $fname =~ /test/ )
	{
			
			$fname =~ s/test/train/;    #column average of only train files are used. So, replace test by train and search in folder $cols_avg.
       #                print "fname: $fname\n";
			open( COLS, "<${cols_avg}/colsAvg_${fname}" ) or die("Not found:${cols_avg}/colsAvg_${fname}");
			my ($file_contents) = do { local $/; <COLS> };
			@col_norm = split( /\s+/, $file_contents );
			close(COLS);
	}
	else
	{
		my @cols = @{ $matrix[0] };        # it gives first row and its size is the total columns present in the two dimensional array.

		######################################################################################
		## The first loop finds the average of the columns and second loop divides          ##
		## each value by its corresponding column average found on first loop.		    ##
		######################################################################################
                my @col_sum = ();

		foreach my $j ( 0 .. $#cols )
		{
			my $col_sum = 0;
			foreach my $i ( 0 .. $#matrix )
			{
				$col_sum += $matrix[$i][$j];
			}
			if ( $col_sum == 0 )    # prevents illegal division by zero.
			{
				$col_sum = 1;
			}
                        
			push @col_norm, ( $col_sum / ( $#matrix + 1 ) );    # average of each column.
####			push @col_norm, $col_sum;
#			push @col_norm, 1;
		}
		##stores the average of each column of train file inside $cols_avg folder. If train file name is 'fv_train', new file will have name 'colsAvg_fv_train'.
		open( COLS, ">${cols_avg}/colsAvg_${fname}" ) or die("Not found:${cols_avg}/colsAvg_${fname}");
                foreach (@col_norm)
		{
		  print COLS "$_ ";
		}

=pod              
		  print COLS "\n";
		foreach (@col_sum)
		{
		  print COLS "$_ ";
		}
	#	print COLS @col_norm;
=cut
		close(COLS);
	}
	
	my @cols = @{ $matrix[0] };
	foreach my $i ( 0 .. $#matrix )
	{
		my @new_row = ();
		foreach my $j ( 0 .. $#cols )
		{

			my $value = $matrix[$i][$j] / $col_norm[$j];
			$value = sprintf("%.4f", $value);
			push @new_row, $value;     # we normalize each value after diving by the average of corresponding column sum.

#		push @new_row, $matrix[$i][$j];		       # non normalized value
		}
		push @result_matrix, [@new_row];
	}
	undef(@matrix);
	return @result_matrix;
}

sub test_norm($)
{

 my ($fv_file, $cols_avg , @matrix) = @_;
 print "fv_file: $fv_file\n";
 print "avg_folder: $cols_avg\n";
print "mat: @{$matrix[0]}\n";

}
1;


