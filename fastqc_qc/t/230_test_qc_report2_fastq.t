use Pfizer::FastQC::Config;
use Pfizer::FastQC::QCRep2Fastq;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $qcr = new Pfizer::FastQC::QCRep2Fastq();
$qcr->set_qc_report_id(16);
$qcr->set_fastq_type('RAW');
$qcr->set_fastq_file_id(2);
print Dumper $qcr;

if ($qcr->insert) {
   ok(1, 'QCRep2Fastq - insert');
}

if (Pfizer::FastQC::QCRep2Fastq->selectByCriteria( QC_REPORT_ID => join(" ", "=", "'".$qcr->qc_report_id."'"))) {
    ok(1, 'QCRep2Fastq - select by criteria');
}


