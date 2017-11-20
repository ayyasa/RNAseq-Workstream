use Pfizer::FastQC::BCL2FastqRun;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use File::Path qw(make_path);
use strict;

my $b2f = new Pfizer::FastQC::BCL2FastqRun();
$b2f->select(578);
print Dumper $b2f;

my @samps;
if (@samps = $b2f->getSamples) {
   ok(1, 'BCL2FastqRun - samples');
}
print Dumper \@samps;

my @fastqs;
if (@fastqs = $b2f->getFastqFiles) {
   ok(1, 'BCL2FastqRun - fastqs');
}
print Dumper \@fastqs;

if (@fastqs = $b2f->getFastqFilesBySampleRead($samps[0], 1)) {
   ok(1, 'BCL2FastqRun - fastqsBySampleRead');
}
print Dumper \@fastqs;
