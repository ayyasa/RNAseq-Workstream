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

my $qc_report_id = shift;
my $qcr = new Pfizer::FastQC::QCReport();
unless ($qcr->select($qc_report_id)) {
    confess "failed to select QCReport ID = $qc_report_id";
}
if ($qcr->run) {
    protlog($LOG_FH, "Succesfully completed QCReport ID = " . $qcr->id);
} else {
    confess "failed to run QCReport ID = " . $qcr->id;
}

    
