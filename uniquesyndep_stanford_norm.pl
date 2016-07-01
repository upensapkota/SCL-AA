#!/usr/bin/perl 
use strict;

my %unique_syndeps=();
my @unique_syndeps=();
my $syndep_file_path=$ARGV[0];
my $rlabel = $ARGV[1];
my $vocab_file=$ARGV[2];
my @post_names=();

sub readRLabel()
{
    open(RLABEL,"< $rlabel") or die("Could not open log file.");  
    foreach my $line(<RLABEL>)
    {
        push(@post_names,trim($line));
    }
    close(RLABEL);
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub uniqueSynDep()
{
       
	opendir(DIR,$syndep_file_path);
	my @files = grep !/^\.\.?$/,readdir(DIR);
	closedir(DIR);
        foreach my $file (@post_names)
      #foreach my $file (@files)
	{
	   open(SYNDEP,"< $syndep_file_path$file") or die("Could not open log file.");
	   foreach my $line(<SYNDEP>)
	   {
		my @tokens= split(/\(/,$line);
		if(!($tokens[0] eq "") || !($tokens[0] eq "\n"))
		{
	          $unique_syndeps{trim($tokens[0])}++;
		}
	   }
	   close(SYNDEP);
	}
	open(UNIQUE,"> $vocab_file") or die("Could not open log file.");
	my $count=0;
	foreach my $token (keys %unique_syndeps)
	{
			print UNIQUE "$token\n";
			$count=$count+1;
	}
	close (UNIQUE);
}

sub spaceDelete()
{
	open(UNIQUE,"< $vocab_file") or die("Could not open log file.");
	my $tmp="tmp.txt";
	open(NEW, "> $tmp") or die "open $tmp: $!";
	foreach my $line(<UNIQUE>)
	{
		if(!($line =~ m/^\n$/))
		{
			print NEW "$line";
		}
	}
	
	close (UNIQUE);
	close (NEW);

	 unlink($vocab_file);
	 rename($tmp, $vocab_file);
}
readRLabel();
uniqueSynDep();
spaceDelete();


