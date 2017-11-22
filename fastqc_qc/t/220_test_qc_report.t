use Pfizer::FastQC::Config;
use Pfizer::FastQC::QCReport;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_name('QCReport1');
$qcr->set_username($Pfizer::FastQC::Config::ADMIN_EMAIL);
$qcr->set_status('PAS');
$qcr->set_path('/home/ayyasa/fastqc_dev/reports/170313_NS500482_0235_AHJFV2AFXX_JLRDP3_4_None/*.html');

print Dumper $qcr;

if ($qcr->insert) {
   ok(1, 'QCReport - insert');
}

if (Pfizer::FastQC::QCReport->selectByCriteria( NAME => join(" ", "=", "'".$qcr->name."'"))) {
    ok(1, 'QCReport - select by criteria');
}


