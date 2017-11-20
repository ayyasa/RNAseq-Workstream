use Pfizer::FastQC::Config;
use Pfizer::FastQC::ReadCleanRun;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $rcr = new Pfizer::FastQC::ReadCleanRun();
$rcr->set_raw_fastq_file_1_id(14263);
$rcr->set_raw_fastq_file_2_id(14263);
$rcr->set_clean_method('Trimmomatic');
$rcr->set_param01($Pfizer::FastQC::Config::DEFAULT_STEP01);
$rcr->set_param02($Pfizer::FastQC::Config::DEFAULT_STEP02);
$rcr->set_param03($Pfizer::FastQC::Config::DEFAULT_STEP03);
$rcr->set_param04($Pfizer::FastQC::Config::DEFAULT_STEP04);
$rcr->set_param05($Pfizer::FastQC::Config::DEFAULT_STEP05);
$rcr->set_param06($Pfizer::FastQC::Config::DEFAULT_STEP06);
$rcr->set_param07($Pfizer::FastQC::Config::DEFAULT_STEP07);
$rcr->set_status('PEN');

if ($rcr->insert) {
       ok(1, 'ReadCleanRun - insert');
}

print Dumper $rcr;


if ($rcr->run) {
   ok(1, 'ReadCleanRun - run');
}
