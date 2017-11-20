use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCL2FastqRunFactory;
use Test::Simple tests => 1;
use Data::Dumper;
use Carp;
use strict;

my $b2q = Pfizer::FastQC::BCL2FastqRunFactory->select(4);

foreach my $lane (1..4) {
    foreach my $read (1..2) {
    print $b2q->_slr2fastq_undetermined($lane, $read), "\n";
    }   
}

my @infastqs = $b2q->getFastqFilesBySampleReadUndetermined(1);
print(join("\n", @infastqs), "\n");

ok(1, 'undetermined fastq names');
