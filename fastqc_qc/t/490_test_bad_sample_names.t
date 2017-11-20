use Pfizer::FastQC::Utils qw(validate_sample_name);
use Test::Simple tests => 1;
use strict;

my @names = (
    'my_sample_name_1',
    'my sample name 1',
    'my_samp_&_1',
    'my_samp_comma,1'
    );

foreach my $name (@names) {
    print join("\t", $name, validate_sample_name($name)), "\n";
}
ok(1, 'Bad sample names');

