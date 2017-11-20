use Pfizer::FastQC::Sample;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $samp = new Pfizer::FastQC::Sample();
$samp->select(1869);
print Dumper $samp;
__END__


$samp->set_sample_name('Sample1');
$samp->set_sample_group_id(16);
$samp->set_order(9);

print Dumper $samp;

if ($samp->insert) {
   ok(1, 'Sample - insert');
}

if (Pfizer::FastQC::Sample->selectByCriteria( SS_SAMPLE_NAME => join(" ", "=", "'".$samp->sample_name."'"))) {
    ok(1, 'Sample - select by criteria');
}


