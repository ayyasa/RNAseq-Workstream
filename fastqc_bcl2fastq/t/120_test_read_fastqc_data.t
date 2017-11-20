use Pfizer::FastQC::Utils qw(parseFastqcData);
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my $sample_root = '/afs/grid.pfizer.com/alds/users/ayyasa/test-fastqc-sets/A3_S2_1_fastqc';
#my $sample_root = '/afs/grid.pfizer.com/alds/projects/btx/fastqc/test-fastqc-sets/EAGC02_S1_1_fastqc';
my $href = parseFastqcData($sample_root);
print Dumper $href;
ok(1, 'test_parseFastqcData');
