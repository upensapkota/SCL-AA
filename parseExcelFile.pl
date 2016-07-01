#!/usr/bin/perl –w

use strict;
my $genre = $ARGV[0];

############### for cross-topic, single genre #####################
#my $file = "/home/upendra/CROSS-DOMAIN/RESULTS/textResultsCrossTopic/$genre.txt";
#my @crossTopicOrder  = ('Privacy','Marijuana','Church','Gay','Iraqwar','Sexdisc');


############### for single-topic, two genres #####################
my $file = "/home/upendra/CROSS-DOMAIN/RESULTS/testResultsCrossGenre/$genre.txt";
my @crossTopicOrder  = ('Email','Essay','Blog','Chat','Discussion','PhoneInterview');


open(FILE,"<$file") or die("Not exists $file\n");
my ($file_contents) = do { local $/; <FILE> };
$file_contents = trim($file_contents);
my @contents = split(/\n{1,}/,$file_contents);

my $genre = $contents[0];
my $features = $contents[1];
print "$genre\n";#$features\n";

my %maxRows=();


findAverageOrBestAccuracyPerGenre();
#parseIntraTopicAccuracy();

sub findAverageOrBestAccuracyPerGenre
{
	for(my $i = 2; $i <= $#contents; $i = $i+7) ## for each test topic (7 lines including average)
	{
		my %columns = ();
		my $testTopic = ();
		for (my $j = $i; $j <= $i+5; $j++)  ## ignore last two lines, last line is average, second last line is intra-topic
		{
			my @split = split("\t",$contents[$j]);
			$testTopic = $split[0] 	if($j == $i);
			for (my $k = 2, my $j = 0; $k <= $#split; $k++,$j++)
			{
				my @column = ();
				@column = @{$columns{$j}} if exists $columns{$j};
				push (@column, "$split[$k]");
				$columns{$j}= \@column;
				#print "@column\n";
				#print "$split[$k]\t";
			}
		
		}
		#print "$testTopic\t";
		my @maxValues = ();
		for my $key (sort {$a <=> $b}keys %columns) 
		{
			my @column = @{$columns{$key}};
			#print "@column\t";
			my $max = &findMax(\@column);
			my $average = &average(\@column);
=pod
			my $max = -10000;
			for my $y (@column) 
			{
				$max = $y if ($y > $max);
			}
=cut
			#print "$max\t";


	#		push @maxValues, $max;
			push @maxValues, $average;
		}
		$maxRows{$testTopic} = \@maxValues;
	
		#print "\n";
	}
}


sub parseIntraTopicAccuracy
{
	for(my $i = 2; $i <= $#contents; $i = $i+7) ## for each test topic (7 lines including average)
	{
		my %columns = ();
		my $testTopic = ();
		my $j = $i+5;


		my @splitForTestTopic = split("\t",$contents[$i]);
		$testTopic = $splitForTestTopic[0];


		my @split = split("\t",$contents[$j]);
		for (my $k = 2, my $j = 0; $k <= $#split; $k++,$j++)
		{
			my @column = ();
			@column = @{$columns{$j}} if exists $columns{$j};
			push (@column, "$split[$k]");
			$columns{$j}= \@column;
		}

		#print "$testTopic\t";
		my @maxValues = ();
		for my $key (sort {$a <=> $b}keys %columns) 
		{
			my @column = @{$columns{$key}};
			my $average = &average(\@column);
			push @maxValues, $average;
		}
		$maxRows{$testTopic} = \@maxValues;
	
		#print "\n";
	}
}

sub findMax
{
	my($column) = @_;
	if (not @$column) 
	{
		die("Empty array\n");
	}
	my $max = -1000000000;
	for my $y (@$column) 
	{
		$max = $y if ($y > $max);
	}
	return $max;
		
}

sub average
{
	my($data) = @_;
	if (not @$data) 
	{
		die("Empty array\n");
	}
	my $total = 0;
	foreach (@$data) 
	{
		$total += $_;
	}
	my $average = $total / @$data;
	$average = sprintf "%.2f", $average;
	return $average;
}

foreach my $topic(@crossTopicOrder)
{
	my @values = @{$maxRows{$topic}};
	print "$topic\t".join("\t\t",@values)."\n";
}



sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
