use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(contamAlignParallel);
use Pfizer::FastQC::CleanFastqFileFactory;
use Test::Simple tests => 1;
use Data::Dumper;
use Carp;
use strict;

my @ids = (1174, 1175);
my @infastqs;
foreach my $id (@ids) {
	push @infastqs, Pfizer::FastQC::CleanFastqFileFactory->select($id);
}

my @trefs = contamAlignParallel(\@infastqs, 20000, $Pfizer::FastQC::Config::FQ_TMPDIR);
print Dumper @trefs;				
ok(1, 'contamAlignParallel');
