
#!/usr/bin/perl
use strict;
#character n-gram feature
require "variable.pl";
require "create_file_hierarchy.pl";

my $rlabel 	= $ARGV[0];
my $rclass 	= $ARGV[1];
my $file_path 	= $ARGV[2];
my $train_path 	= $ARGV[3];

my @post_names = ();
my $authorMap = ();

createNewFolder("$train_path");
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub readRLabel
{
	my ($rlabel, $rclass) = @_;
	my %hash = ();
	my @classes = ();
	open(RLABEL,"< $rlabel") or die("Could not open log file:$!");  

	foreach my $line(<RLABEL>)
	{
	    push(@post_names,trim($line));
	}
	close(RLABEL);

	open(RCLASS,"< $rclass") or die("Could not open log file:$!");  
	foreach my $line(<RCLASS>)
	{
	    push(@classes,trim($line));
	}
	close(RLABEL);


	foreach my $i(0..$#post_names)
	{
		$hash{$post_names[$i]} = $classes[$i];
	}
	undef (@classes);
	return \%hash;    
}


sub createTraining()
{
	foreach (@post_names)
       {
		my $authorname = $authorMap->{$_};
		open(INFILE,"< $file_path"."$_") or die("Could not open  $file_path"."$_");
		my($file_contents) = do { local $/; <INFILE> };
		close(INFILE);
	   
		open(OUTFILE, ">> $train_path$authorname.txt") or die("error :$!"); 
		print OUTFILE "$file_contents\n";
		close(OUTFILE);
	}
}

$authorMap = readRLabel($rlabel, $rclass);
createTraining();
