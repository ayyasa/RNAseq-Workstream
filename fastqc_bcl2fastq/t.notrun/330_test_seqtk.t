use Pfizer::FastQC::Config;
use Pfizer::FastQC::RawFastqFileFactory;
use Pfizer::FastQC::Utils qw(seqtk_cmd);
use Test::Simple tests => 1;
use Carp;
use strict;

my $raw_fastq = Pfizer::FastQC::RawFastqFileFactory->select(20);
my @cmd = seqtk_cmd($raw_fastq->fullPath, 
   $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE, "junk.seqtk.out");
print join(" ", @cmd), "\n";
unless (system(join(" ", @cmd))==0) {
   ok(0, 'seqtk_cmd');
}
ok(1, 'seqtk_cmd');
