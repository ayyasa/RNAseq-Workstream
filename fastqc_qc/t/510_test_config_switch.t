use Pfizer::FastQC::Config;
use Test::Simple tests => 1;
use strict;
print join("\n", @Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS), "\n";
my @keys = qw(BCL_NUM_LANES);
foreach my $key (@keys) {
	print "$key:\n";
	foreach my $root (@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
	    print " $root => " . $Pfizer::FastQC::Config::env{$root}->{$key}, "\n";
	}
}
ok(1, 'config switch');
