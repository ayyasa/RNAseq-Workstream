use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use File::Basename; 
use Data::Dumper;
use Carp;
use strict;

my $sample_group_id = shift;
my $sample_sheet = shift;
my $do_readclean = shift || 'None';

my $sg = Pfizer::FastQC::SampleGroupFactory->select($sample_group_id);
unless (defined($sg)) {
    print "usage: $0 <sample_group_id>\n";
    exit(-1);
}

my $ss = new Pfizer::FastQC::SampleSheet($sample_sheet);
my @rcrs = Pfizer::FastQC::ReadCleanRun->run_for_sample_group($sg, $do_readclean, $ss);

if (@rcrs) {
    protlog($LOG_FH, "Succesfully completed ReadCleanRuns for SampleGroup = " . $sg->id);
} else {
    confess "failed to run ReadCleanRuns for SampleGroup ID = " . $sg->id;
}

    
