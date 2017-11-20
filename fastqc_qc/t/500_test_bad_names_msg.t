use Pfizer::FastQC::SampleSheet;
use Pfizer::FastQC::Config;
use Wyeth::Util::Utils qw(protlog);
use Test::Simple tests => 1;
use strict;

my $sample_file = '/hpc/grid/omics_data04/appsdev/fastqc/t/SampleSheet.csv';
my $ss= new Pfizer::FastQC::SampleSheet($sample_file);
my @failing_names = $ss->validate_sample_names;
if (@failing_names) {
    protlog($LOG_FH, "File " . $ss->filename . " contains illegal sample names, skipping this directory");
    print join("\n", @failing_names);
    print $ss->badNamesMsg(\@failing_names);
    $ss->sendBadNamesMsg(\@failing_names);
}	
ok(1, 'Test bad sample names');

