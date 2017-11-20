use Pfizer::FastQC::Config;
use Pfizer::FastQC::CleanFastqFile;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use strict;

my $raw_fastq_id = 2157;
my $rcr_id = 1095;

my $cff = new Pfizer::FastQC::CleanFastqFile();
$cff->set_raw_fastq_file_id($raw_fastq_id);
$cff->set_readclean_run_id($rcr_id);
$cff->set_read_number(2);
$cff->set_name("foo.fa");
$cff->set_path("/bar/shoo");
$cff->set_status('PEN');
$cff->set_type('PAIRED');


print Dumper $cff;

if ($cff->insert) {
   ok(1, 'CleanFastqFile - insert');
}

if (Pfizer::FastQC::CleanFastqFile->selectByCriteria( 
   RAW_FASTQ_FILE_ID => join(" ", "=", "'". $cff->raw_fastq_file_id . "'"))) {
    ok(1, 'CleanFastqFile - select by criteria');
}

$cff = new Pfizer::FastQC::CleanFastqFile();
$cff->register($raw_fastq_id, $rcr_id, 1, 
'/hpc/grid/scratch/ayyasa/fastqc/raw/170607_NS500482_0299_AHVHNKBGX2_S3/D7_S13_1.fastq.gz');

print Dumper $cff;
ok(1, 'CleanFastqFile - register');
