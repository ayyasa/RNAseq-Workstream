use Test::Simple tests => 1;
use strict;

my $path = "/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/NextSeq500_bcl_folder/Theresa's cell free tests/150513_NS500482_0026_AH7KL7BGXX/";
my $escaped_path = $path;
 $escaped_path =~ s/([\' ])/\\\1/g;
print "$path\n";
print "$escaped_path\n";
ok(1);
