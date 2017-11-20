use Test::Simple tests => 1;
use Pfizer::FastQC::Utils qw(generate_qc_report);
use Carp;
use Data::Dumper;
use strict;

my @dirlist = glob('/afs/grid.pfizer.com/alds/projects/btx/fastqc/test-fastqc-sets/*_fastqc');
my $html = generate_qc_report(@dirlist);
print $html, "\n\n";
ok(1, 'test_insertModulePlots');


