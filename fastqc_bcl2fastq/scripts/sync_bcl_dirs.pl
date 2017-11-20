use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::RegistrarController qw(addBCLDirectory setupSampleGroup);
use Wyeth::Util::Utils qw(protlog);
use Carp;
use strict;

if (@ARGV != 1) {
    print STDERR "usage $0 <verbosity level (0..Inf)\n";
    exit(-1);
}

$VERBOSE = shift || 0;
my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;

foreach my $FQ_BCL_ROOT_DIR (@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
    $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR = $FQ_BCL_ROOT_DIR;
    protlog($LOG_FH, "Set configuration for root dir $FQ_BCL_ROOT_DIR");
    my @sampleSheets = Pfizer::FastQC::SampleGroup->findNewSampleSheets($FQ_BCL_ROOT_DIR);
    foreach my $ss (@sampleSheets) { 
	my $bd, $ss;
	if ($bd = addBCLDirectory($ss)) {
	    if (setupSampleGroup($bd, $ss)) {
		protlog($LOG_FH, "Synced BCL directory " . $bd->name);
	    }
	}
    }
}


