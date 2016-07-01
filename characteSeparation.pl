#!/usr/bin/perl 
use strict;
use File::Find;
use File::Basename;
require "create_file_hierarchy.pl";
my $folder_path = $ARGV[0];#location of authorlevel folder like. Data/cluster_each_modality/5Author
my $src_folder  = $ARGV[1];
my $dest_folder = $ARGV[2];#destination folder i.e. processed folder where files will be stored.
$folder_path.='/' if($folder_path !~ /\/$/);
my $src = "${folder_path}${src_folder}";
my $dst = "${folder_path}${dest_folder}";
createNewFolder("$dst");

require "create_file_hierarchy.pl";

sub characterSeparation
{
	   my $file_name = $File::Find::name;
	   return unless -f $file_name;
	   my ( $fname, $folder ) = fileparse($file_name);
           my $target_file = "$dst/$fname";

	   open(INFILE,"< $file_name") or die("Could not open log file:$!");
	   my @file_contents = ();
	   foreach my $line (<INFILE>)
	   {
		push (@file_contents, $line);
	   }
	   close(INFILE);
	   open(OUTFILE, "> $target_file") or die "open $target_file: $!";
	   foreach my $line (@file_contents)
	   {
	   my @splitline = split(//,$line);
	   foreach my $char(@splitline)
	   {
			if(!($char =~ m/\s/))
			{
			print OUTFILE "$char ";
      			}
	   }
			print OUTFILE "\n";
	   }
	  close(OUTFILE);
 	  close(INFILE);
}



finddepth(\&characterSeparation, $src);

