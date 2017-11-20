use Pfizer::FastQC::Config;
# use Pfizer::FastQC::RawFastqFileFactory;
use Pfizer::FastQC::Utils qw(bowtie_cmd);
use Test::Simple tests => 1;
use Carp;
use strict;

# my $raw_fastq = Pfizer::FastQC::RawFastqFileFactory->select(20);
my @cmd = bowtie_cmd('junk.seqtk.out', 'junk.seqtk.out.bowtie');
print join(" ", @cmd), "\n";
unless (system(join(" ", @cmd))==0) {
   ok(0, 'bowtie_cmd');
}
ok(1, 'bowtie_cmd');
