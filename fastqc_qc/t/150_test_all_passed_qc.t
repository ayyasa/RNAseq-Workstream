# use Test::Simple tests => 1;

use Pfizer::FastQC::Utils qw(buildListMapper buildMultiFastqcDataStruct 
 allSamplesPassedModule getGroupQcStatus);
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my @dirlist = glob('/afs/grid.pfizer.com/alds/users/ayyasa/test-fastqc-sets/*_fastqc');
#my @dirlist = glob('/afs/grid.pfizer.com/alds/projects/btx/fastqc/test-fastqc-sets/*_fastqc');
# my $lmapper= buildListMapper(@dirlist);
my $mref = buildMultiFastqcDataStruct(@dirlist);
foreach my $mod (qw/M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11/) {
	my $all_passed = allSamplesPassedModule($mod, $mref); 
	print join("\t", $mod, $all_passed), "\n";
	my $grp_status = getGroupQcStatus($mod, $mref);
	print join("\t", $mod, $grp_status), "\n"; 
}

ok(1, 'test_all_passed_qc');
