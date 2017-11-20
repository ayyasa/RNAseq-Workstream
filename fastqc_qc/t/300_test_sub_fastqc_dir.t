use Pfizer::FastQC::SampleSheet;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my @fastqs = glob(" /hpc/grid/scratch/ayyasa/fastqc/raw/170607_NS500482_0299_AHVHNKBGX2_S3/.fastq.gz");
my $output_dir = 'foobar';
my @output_dirs = map { $_ =~ s/(^.+\/)([^\/]+)\.fastq.gz$/$output_dir\/\2_fastqc/; $_ } @fastqs;
print join("\n", @output_dirs), "\n";
ok(1, 'fastqc_directory regex');
