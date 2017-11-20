use Pfizer::FastQC::Config;
use Pfizer::FastQC::RawFastqFile;
use Test::Simple tests => 4;
use Carp;
use Data::Dumper;
use strict;

my $sample_id = 252;
my $rff = new Pfizer::FastQC::RawFastqFile();
$rff->set_sample_id($sample_id);
$rff->set_read_number(2);
$rff->set_name("foo.fa");
$rff->set_path("/bar/shoo");
$rff->set_status('PEN');

print Dumper $rff;

if ($rff->insert) {
   ok(1, 'RawFastqFile - insert');
}

$rff = new Pfizer::FastQC::RawFastqFile();
my $b2f_id = 6;
$rff->register($b2f_id, $sample_id, 1, '/hpc/grid/scratch/tbi/fastqc/raw/150420_NS500482_0019_AH04K2AFXX/P2G11_S87_R2_001.fastq.gz');
# hpc/grid/scratch/tbi/fastqc/raw/my_directory/my_fastq_file.fastq.gz');
print Dumper $rff;
ok(1, 'RawFastqFile - register');

if (Pfizer::FastQC::RawFastqFile->selectByCriteria( 
   SAMPLE_ID => join(" ", "=", "'". $rff->sample_id . "'"))) {
    ok(1, 'RawFastqFile - select by criteria');
}

if (Pfizer::FastQC::RawFastqFile->selectByCriteria( 
   SAMPLE_ID => join(" ", "=", "'". $rff->sample_id . "'"))) {
    ok(1, 'RawFastqFile - select by criteria');
}

my $rfq = Pfizer::FastQC::RawFastqFile->select_by_sample_read($sample_id,1);
print Dumper $rfq;
$rfq = Pfizer::FastQC::RawFastqFile->select_by_sample_read($sample_id,2);
print Dumper $rfq;
ok(1, 'RawFastqFile - select by sample_read');
