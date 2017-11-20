use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCL2FastqRunFactory;
use Pfizer::FastQC::BCLDirectoryFactory;
use Pfizer::FastQC::SampleGroupFactory;
use Test::Simple tests => 1;
use Data::Dumper;
use Carp;
use strict;

my $b2q = Pfizer::FastQC::BCL2FastqRunFactory->select(4);
my $bcldir = Pfizer::FastQC::BCLDirectoryFactory->select($b2q->bcl_directory_id);
my @sgs = Pfizer::FastQC::SampleGroupFactory->selectByCriteria(BCL_DIRECTORY_ID => "= " . $bcldir->id);
my @samples= $sgs[0]->samples;

foreach my $lane (1..4) {
    foreach my $read (1..2) {
    print $b2q->_slr2fastq_undetermined($lane, $read), "\n";
    print $b2q->_slr2name($samples[0], $lane, $read), "\n";
    }   
}

my @infastqs = $b2q->getFastqFilesBySampleReadUndetermined(1);
print(join("\n", @infastqs), "\n");
@infastqs =  $b2q->getFastqFilesBySampleRead($samples[0], 1);
print(join("\n", @infastqs), "\n");
ok(1, 'fastq names');
