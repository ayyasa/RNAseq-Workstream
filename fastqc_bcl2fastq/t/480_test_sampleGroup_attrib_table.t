use Pfizer::FastQC::SampleGroup;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my $sgid = 6;
my $sg = Pfizer::FastQC::SampleGroupFactory->select($sgid);
my ($headsref, $recs) = $sg->attrib_table();
print Dumper $headsref;
print Dumper $recs;
ok(1, 'SampleGroup attrib table');

