use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCL2FastqRun;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my $sample_file = "/afs/grid.pfizer.com/alds/projects/dev/fastqc/test-bcl-root/141212_NS500482_0005_AH14JJBGXX/SampleSheet.csv";
my $ss= new Pfizer::FastQC::SampleSheet($sample_file);
ok(1, 'SampleSheet creation');

