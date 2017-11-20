use Pfizer::FastQC::Utils qw(parseSampleSheet);
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my $sample_file = "t/SampleSheet.csv"; # "/afs/grid.pfizer.com/alds/projects/btx/fastqc/SampleSheet.csv";
my $href= parseSampleSheet($sample_file);
print Dumper $href;
ok(1, 'SampleSheet');
