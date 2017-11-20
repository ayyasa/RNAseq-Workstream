# use Test::Simple tests => 1;

use Pfizer::FastQC::Utils qw(buildListMapper);
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my @dirlist = glob('/afs/grid.pfizer.com/alds/users/ayyasa/test-fastqc-sets/*_fastqc');
#my @dirlist = glob('/afs/grid.pfizer.com/alds/projects/btx/fastqc/test-fastqc-sets/*_fastqc');
my $lmapper= buildListMapper(@dirlist);
print Dumper $lmapper;
ok(1, 'test_listmapper');
