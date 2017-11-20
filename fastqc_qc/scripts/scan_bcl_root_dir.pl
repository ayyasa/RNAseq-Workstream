use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use File::Basename; 
use Data::Dumper;
use Carp;
use strict;

foreach my $FQ_BCL_ROOT_DIR (@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
    $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR = $FQ_BCL_ROOT_DIR;
    protlog($LOG_FH, '');
    protlog($LOG_FH, '=' x 50);
    protlog($LOG_FH, "Set configuration for root dir $FQ_BCL_ROOT_DIR");
    my @sampleSheets = Pfizer::FastQC::SampleGroup->findNewSampleSheets($FQ_BCL_ROOT_DIR);
    my $num = 0;
    print '-'x60, "\n";
    print "Below are listed all BCL directories with new sample sheets that are eligible to run.\n";
    print "To demultiplex and process one of these directories, run register_runs.pl as follows:\n";
    print "perl scripts/register_runs.pl <path_of_bcl_dir relative to $FQ_BCL_ROOT_DIR>\n";
    print "For example:\n";
    print "perl scripts/register_runs.pl 150803_NS500482_0052_AH27NYAFXX_IL4_13_mRNA_redo1";
    print "\n";
    print '-'x60, "\n";
    foreach my $ss (@sampleSheets) {
	print sprintf("(%d) %s (%d samples)\n", $num++, $ss->filename, scalar(@{$ss->samples}));
    }
}

    
