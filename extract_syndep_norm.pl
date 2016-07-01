#!/usr/bin/perl 
use strict;
require "NormalizeMatrixByFeatures.pl";
my %unique_syndeps=();
my @unique_syndeps=();
my $syndep_file_path=$ARGV[0];
my $rlabel=$ARGV[1];
my $vocab_file=$ARGV[2];
my $fv_file=$ARGV[3];
my $cols_avg=$ARGV[4];
my @post_names=();
my @matrix = ();
my @row = ();

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
sub readRLabel()
{
    open(RLABEL,"< $rlabel") or die("Could not open log file.");  
    foreach my $line(<RLABEL>)
    {
	    push(@post_names,trim($line));
    }
    close(RLABEL);
}

#sub extractPOS()
#{
#	foreach my $post (@post_names)
#	{
#		my %file_syndeps=();
#		my $string="";
#		print "$post\n";
#		open(SYNDEP,"< $syndep_file_path$post") or die("Could not open log file.");
#	   foreach my $line(<SYNDEP>)
#	   {
#		my @tokens= split(/\(/,$line);
#		my($initial_count)=0;
#		($initial_count)=$file_syndeps{$tokens[0]} if exists  $file_syndeps{$tokens[0]};
#		$file_syndeps{$tokens[0]} = $initial_count+ 1;
#		     #print "$getTag[1] $unique_tags{$getTag[1]}\n";
#	   }
#	   close(SYNDEP);
#		
#		foreach my $unique (keys %unique_syndeps)
#		{
#			my $flag=0;
#			foreach my $pos (keys %file_syndeps)
#			{
#				if(trim($unique) eq trim($pos))
#				{
#					$flag=1;
#					$string=$string." ".$file_syndeps{$pos};
#					last;
#				}
#			}
#			if($flag==0)
#			{
#			    $string=$string." 0";
#			}
#			
#		}
#		$string=trim($string);
#		open(VECTOR,">> syndep_FV_stanford.txt") or die("Could not open log file.");
#		print VECTOR "$string\n";
#		close(VECTOR);
#	}
#}
sub extractPOS()
{
    open(VECTOR,"< $vocab_file") or die("Could not open log file.");
	foreach(<VECTOR>)
	{
		push (@unique_syndeps, trim($_));
	}
	close(VECTOR);
	
	foreach my $post (@post_names)
	{
		my %file_syndeps=();
#		my $string="";
		@row = ();
		my $counter=0;
		#print "$post\n";
		open(SYNDEP,"< $syndep_file_path$post") or die("Could not open  $syndep_file_path$post.");
			   foreach my $line(<SYNDEP>)
			   {
					if($line =~ m/\(/g)
					{
						$counter=$counter+1;
					}
					my @tokens= split(/\(/,$line);
					$file_syndeps{trim($tokens[0])}++;
			   }
			  # print "counter: $counter\n";
			   close(SYNDEP);
		
			foreach my $unique (@unique_syndeps)
			{
			  my $count = 0;
		  	  $count =$file_syndeps{$unique} if defined $file_syndeps{$unique};
                 	  push @row, $count;

=pod
				my $flag=0;
				foreach my $pos (keys %file_syndeps)
				{
					if(trim($unique) eq trim($pos))
					{
						$flag=1;
#						my $countVal=($file_syndeps{$pos})/$counter;
						my $countVal=$file_syndeps{$pos};
#						$string=$string." ".$countVal;
                                      	        push @row, $countVal;
						last;
					}
				}
				if($flag==0)
				{
#				    $string=$string." 0";
				    push @row, 0;
				}
=cut
			
			}
#		$string=trim($string);
#		open(VECTOR,">> $fv_file") or die("Could not open log file.");
#		print VECTOR "$string\n";
#		close(VECTOR);
		 push @matrix, [@row];
		 undef (@row);
	}
}

sub writeToFile()
{
  my @normalized_matrix = normalize($fv_file, $cols_avg, @matrix);
  undef (@matrix);
  open(VECTOR,"> $fv_file") or die("Could not open $fv_file.");
   foreach my $i(0..$#normalized_matrix)
    {
	print VECTOR "@{$normalized_matrix[$i]}\n";
    }
     undef (@normalized_matrix);
    close(VECTOR);
}


sub unlinkFile($)
	{
	my  $target1= "@_";
	 if(-e "$target1")
		   {
		   unlink("$target1");
		   print " Message: $target1 already existed and successfully deleted before crating new.\n";
		   }
	}
unlinkFile($fv_file);
readRLabel();
extractPOS();
writeToFile();

