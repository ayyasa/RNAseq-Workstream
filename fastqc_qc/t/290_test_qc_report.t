use Pfizer::FastQC::Config;
use Pfizer::FastQC::QCReport;
use Pfizer::FastQC::QCRep2FastqFactory;
use Pfizer::FastQC::CleanFastqFileFactory;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use strict;

my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_username($Pfizer::FastQC::Config::ADMIN_EMAIL);
$qcr->set_status('PEN');
$qcr->set_name('test_report_01.html');
$qcr->set_path($Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR);
$qcr->set_fastqc_extract(1);
unless ($qcr->insert) {
    confess "failed to insert QCReport";
}
ok(1, 'QCReport - insert');

my @infastqs;
 my @ids = (39, 40);
# my @ids = (21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40);
foreach my $id (@ids) {
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
ok(1, 'QCRep2Fastq - insert');

if ($qcr->run) {
    ok(1, 'QCReport - run');
}






