use Pfizer::FastQC::Config;
use Pfizer::FastQC::ReadCleanRun;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use strict;

my $rcr = new Pfizer::FastQC::ReadCleanRun();
$rcr->set_raw_fastq_file_1_id(14260);
print Dumper $rcr;

if ($rcr->insert) {
   ok(1, 'ReadCleanRun - insert');
}

if (Pfizer::FastQC::ReadCleanRun->selectByCriteria( 
   RAW_FASTQ_FILE_1_ID => join(" ", "=", "'". $rcr->raw_fastq_file_1_id . "'"))) {
    ok(1, 'ReadCleanRun - select by criteria');
}

if ($rcr->run) {
   ok(1, 'ReadCleanrun - run single read');
}



