#!/usr/bin/perl 

require "NormalizeMatrixByFeatures.pl";
require "create_file_hierarchy.pl";
require "variable.pl";
use lib '/home/upendra/NLP/Softwares/Text-Ngrams/blib/lib';
use File::Basename;
use File::Find;
use Text::Ngrams;
my %unique_ngrams = ();

my $src           = $ARGV[0];
my $rlabel        = $ARGV[1];
my $vocab_file    = $ARGV[2];
my $fv_file       = $ARGV[3];
my $cols_avg      = $ARGV[4];

my @post_names = ();
my @matrix     = ();
my @row        = ();

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readRLabel()
{
	open( RLABEL, "< $rlabel" ) or die("Could not open log file:$!");
	foreach my $line (<RLABEL>)
	{
		push( @post_names, trim($line) );
	}
	close(RLABEL);
}

sub extractFV
{
	my @unique_ngrams = ();
	open( VECTOR, "< $vocab_file" ) or die("Could not open log file:$!");

	#print "$vocab_file\n";
	foreach (<VECTOR>)
	{
		push( @unique_ngrams, trim($_) );
	}
	close(VECTOR);

	foreach my $post (@post_names)
	{
		my %file_ngrams = ();
		my $string      = "";
		@row = ();
		my $counter = 0;

		open(FILE,"<$src$post") or die("Not exists $src$post\n");
		my ($file_contents) = do { local $/; <FILE> };
		$file_contents = trim($file_contents);
		close(FILE);
		my @contents = split(/\n{2,}/,$file_contents);  ## split the file contents by two new lines, that means one one blank line
		my  $sentenceCount = 1;

		for(my $i = 0; $i < $#contents; $i = $i+2) ## for each sentence
		{

			my %numberToWords = ();
			my %numberToTags = ();
			my %map = ();

			my $j = $i+1;
			my $tree = $contents[$i];
			my $dep = $contents[$j];
			%numberToWords = ();
			my @depSplit = split("\n",$dep);
			foreach my $d(@depSplit)  ## for each deptagency parsed line
			{
				$d =~ /(.*?)\((.*?)-(.*?),(.*?)-(.*?)\)/;

				my $relation = $1;
				my $headWord = $2;
				my $headPosition= $3;
				my $mainWord = $4;
				my $mainWordPosition = $5;
				$numberToWords{$mainWordPosition} = trim($mainWord);
				$numberToTags{$mainWordPosition} = trim($relation);
				my @values = ();
				@values = @{$map{$headPosition}} if exists $map{$headPosition};
				push (@values, "$mainWordPosition->$relation");
				$map{$headPosition}= \@values;
		
			}
			foreach my $headPosition(keys %map)
			{
				my @values = @{$map{$headPosition}};
			}
			my @allPaths = findPathsAll(\%map, 0,"NULL");
			foreach my $path_(@allPaths)
			{
				my @path = @$path_;
				for (my $i=0; $i<$#path; $i++)
				{	
					next if $i eq 0;
					my $element1 = $path[$i];
					my $element2 = $path[$i+1];
					#my $bigram = "$numberToTags{$element1}_$numberToTags{$element2}";		
					my $bigram = "$numberToWords{$element1}_$numberToWords{$element2}";	
					$file_ngrams{$bigram}++;
				}
			}

		}
		close(FILE);

		foreach my $unique (@unique_ngrams)
		{

			my $count = 0;
			$count = $file_ngrams{ trim($unique) } if defined $file_ngrams{ trim($unique) };
			push @row, $count;

		}
		push @matrix, [@row];
		undef(@row);
	}
}


sub findPathsAll {
          my ($graph,$node,$tag) = @_;

          my $findPaths_sub;
          $findPaths_sub = sub {
            my( $seen, $node, $tag ) = @_;
#            return [[$node]] if isLeaf($graph, $node);
            return [[]] if isLeaf($graph, $node);
            $seen->{ $node } = 1;
            my @paths;
            for my $child ( @{ $graph->{ $node } } ) {
		my @split = split(/->/,$child);
		$node = $split[0];
		$tag = $split[1];
              my %seen = %{$seen};
              next if exists $seen{ $node };
              push @paths, [ $node, @$_ ]
                  for @{ $findPaths_sub->( \%seen, $node, $tag ) };
            }
            return \@paths;
          };

          my @all;
          push @all,[@$_]  for @{ $findPaths_sub->( {}, $node, $tag )};
          return @all;
  }





sub isLeaf
{
	my ($mapRef, $node) = @_;
	my $isLeaf = 1;

	$isLeaf = 0 if exists($mapRef->{$node});
	return $isLeaf;
}


sub writeToFile()
{
	my @normalized_matrix = @matrix;
#	my @normalized_matrix = normalize($fv_file, $cols_avg, @matrix );
	undef(@matrix);

	open( VECTOR, "> $fv_file" ) or die("Could not open $fv_file.");
	foreach my $i ( 0 .. $#normalized_matrix )
	{
		print VECTOR "@{$normalized_matrix[$i]}\n";
	}
	close(VECTOR);

	undef(@normalized_matrix);
}

readRLabel();
createNewFolder($dest);
extractFV();
writeToFile();

