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
my $sg = Pfizer::FastQC::SampleGroupFactory->select($sample_group_id);
unless (defined($sg)) {
    print "usage: $0 <sample_group_id>\n";
    exit(-1);
}

my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_username($Pfizer::FastQC::Config::ADMIN_EMAIL);
$qcr->set_status('PEN');
$qcr->set_name(join("_", $sg->name, $sg->do_readclean));
$qcr->set_path(join("/", $Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR, $qcr->name));
$qcr->set_fastqc_extract(1);
unless ($qcr->insert) {
    confess "failed to insert QCReport";
}
my @infastqs = $sg->get_clean_fastqs;
foreach my $inf (@infastqs) {
    my $q2f = new Pfizer::FastQC::QCRep2Fastq();
    $q2f->set_qc_report_id($qcr->id);
    $q2f->set_fastq_file_id($inf->id);
    $q2f->set_fastq_type('CLEAN');
    unless ($q2f->insert) {
	confess "failed to insert QCRep2Fastq";
    }	       	       
}
if ($qcr->run) {
    protlog($LOG_FH, "Succesfully completed QCReport ID = " . $qcr->id);
} else {
    confess "failed to run QCReport ID = " . $qcr->id;
}

    
