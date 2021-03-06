
#!/usr/bin/perl 
use strict;
require "variable.pl";#require "fileNameFormat.pl";

my $feature_vector_file	= $ARGV[0];
my $rlabel_file	 	= $ARGV[1];
my $rclass_file	 	= $ARGV[2];
my $features_file	= $ARGV[3];
my $dataset 		= $ARGV[4];
my $dest_path 		= $ARGV[5];
my $uniqueClassesFile	= $ARGV[6];
my @class=();
my @fvs=();
my @rlabel=();
my @clabel=();
my $authorMap = ();
my $uniqueClasses = "";

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readUniqueClasses
{
	open(UNIQUE,"< $uniqueClassesFile") or die("Could not open $uniqueClassesFile file:$!"); 
        my ($file_contents) = do { local $/; <UNIQUE> };
	$uniqueClasses = trim($file_contents);
}

## read file name as well its corresponding author and store in a hash.
sub readRLabel
{
	my ($rlabel_file, $rclass_file) = @_;
	my %hash = ();
	open(RLABEL,"< $rlabel_file") or die("Could not open $rlabel_file file:$!");  

	foreach my $line(<RLABEL>)
	{
	    push(@rlabel,trim($line));	
	}
	close(RLABEL);

	open(RCLASS,"< $rclass_file") or die("Could not open $rclass_file file:$!");  
	foreach my $line(<RCLASS>)
	{
	    push(@class,trim($line));
	}
	close(RLABEL);


	foreach my $i(0..$#rlabel)
	{
		$hash{$rlabel[$i]} = $class[$i];
	}
	return \%hash;    
}


sub readFVs($)
{
    
    my $FULL_FILE_NAME= "@_";

    open(FV,"< $FULL_FILE_NAME") or die("Could not open $FULL_FILE_NAME: $!");
   
   foreach my $line (<FV>)
   {
	 $line= trim($line);
    $line =~ s/\s+/,/g;
       push(@fvs,trim($line));
   }
   close(FV);    
}
sub readclabel($)
{
   open(CLABEL,"< $features_file") or die("Could not open $features_file:$!");
   
   my $featureCount = 0;
   foreach my $line(<CLABEL>)
  {
##   push(@clabel,$line);
   push(@clabel,$featureCount++);
   
   }
   close(CLABEL); 
}

sub arff()
{

        # delete the file if already exists before creating new one.
        if(-e "$dest_path$dataset.arff")
	{
	 unlink("$dest_path$dataset.arff");
	}

        open(MERGE,"> $dest_path$dataset.arff") or die("Could not open $dest_path$dataset.arff:$!");
	print MERGE "\@relation $dataset\n";
	for (my $i=0; $i<scalar(@clabel); $i++)
	{
	
		$clabel[$i]= trim($clabel[$i]);
                $clabel[$i] =~ s/\s+//g;
		print MERGE "\@attribute $clabel[$i] numeric\n";

	}
	
	print MERGE "\@attribute class {$uniqueClasses}\n\@data\n";
	 for (my $i=0;$i<scalar(@fvs);$i++)
	{
		print MERGE "$fvs[$i],$class[$i]\n";	
	}
	close(MERGE);
}
readFVs($feature_vector_file);
$authorMap = readRLabel($rlabel_file, $rclass_file);
readUniqueClasses();
readclabel($features_file);
arff();
