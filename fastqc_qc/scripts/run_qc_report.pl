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

my @cfq_ids = @ARGV;
if ($cfq_ids[0] =~ m/(\d+)\-(\d+)/) {
    my $min_id = $1;
    my $max_id = $2;
    @cfq_ids = ();
    foreach my $id ($min_id..$max_id) {
	push @cfq_ids, $id;
    }
}
# print join(",", @cfq_ids);

my $sg = Pfizer::FastQC::CleanFastqFileFactory->select($cfq_ids[0])->sampleGroup;
my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_username($Pfizer::FastQC::Config::ADMIN_EMAIL);
$qcr->set_status('PEN');
$qcr->set_name(join("_", $sg->name, $sg->do_readclean));
$qcr->set_path(join("/", $Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR, $qcr->name));
$qcr->set_fastqc_extract(1);
unless ($qcr->insert) {
    confess "failed to insert QCReport";
}
my @infastqs;
foreach my $id (@cfq_ids) {
    push @infastqs, Pfizer::FastQC::CleanFastqFileFactory->select($id);
}
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

    
