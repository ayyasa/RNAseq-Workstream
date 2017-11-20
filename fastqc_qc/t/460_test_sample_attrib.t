use Pfizer::FastQC::SampleAttrib;
use Test::Simple tests => 3;
use Data::Dumper;
use strict;

my $sa = new Pfizer::FastQC::SampleAttrib();
$sa->set_id(13579);
$sa->set_sample_id(10043);
$sa->set_name('foo');
$sa->set_value('bar');
$sa->set_order(5);

print join(",", $sa->id,
	   $sa->sample_id,
	   $sa->name,
	   $sa->value,
	   $sa->order), "\n";

ok(1, 'SampleAttrib - set/get');

if ($sa->insert) {
   ok(1, 'SampleAttrib - insert');
}
if ($sa->delete) {
    ok(1, 'SampleAttrib - delete');
}


