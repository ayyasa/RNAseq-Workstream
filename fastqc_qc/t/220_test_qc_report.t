use Pfizer::FastQC::Config;
use Pfizer::FastQC::QCReport;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_name('QCReport1');
$qcr->set_username($Pfizer::FastQC::Config::ADMIN_EMAIL);
$qcr->set_status('PEN');
$qcr->set_path('/foo/bar/zap.html');

print Dumper $qcr;

if ($qcr->insert) {
   ok(1, 'QCReport - insert');
}

if (Pfizer::FastQC::QCReport->selectByCriteria( NAME => join(" ", "=", "'".$qcr->name."'"))) {
    ok(1, 'QCReport - select by criteria');
}


