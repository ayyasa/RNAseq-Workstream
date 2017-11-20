use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use Pfizer::FastQC::Utils qw(_trim1_cmd run_fastqc  generate_qc_report);
use File::Basename; 
use Data::Dumper;
use Carp;
use strict;

my $output_dir = shift;
my @infiles = @ARGV;
my $log_stub = $$;

my @fastqc_dirs;

unless (@fastqc_dirs = run_fastqc($output_dir, 1, 'fastq', \@infiles, $log_stub)) {
    confess "failed to run-fastqc for QC Report ID";
}

