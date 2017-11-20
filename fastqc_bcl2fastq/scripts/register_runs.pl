use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::SampleAttrib;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use Pfizer::FastQC::RegistrarController qw(register_core);
use File::Basename; 
use Data::Dumper;
use Carp;
use strict;

my $root_dir_index = shift;
my $target_bcl_dir = shift;

sub usage {
    print "register_runs.pl <root_dir_index> <target BCL directory name> e.g. 150803_NS500482_0052_AH27NYAFXX_IL4_13_mRNA_redo1\n";
    print "\t target BCL directory name is relative to the root dirs\n";
    foreach my $i (0..@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS-1) {
	print "\t index = $i root dir = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS[$i]\n";
    }
    print "\t so to run directory $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS[0]/150803_NS500482_0052_AH27NYAFXX_IL4_13_mRNA_redo1\n";
    print "\t specify root_dir_index 0 and target BCL directory name '150803_NS500482_0052_AH27NYAFXX_IL4_13_mRNA_redo1'\n";
}

unless (defined($target_bcl_dir)) {
    usage();
    exit(-1);
}
unless ($root_dir_index >= 0 && $root_dir_index < @Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
    usage();
    exit(-1);
}
$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS[$root_dir_index];
my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;
my $sample_csv= join("/", $FQ_BCL_ROOT_DIR, $target_bcl_dir, $SAMPLESHEET_FILE);
print "sample -> $sample_csv\n";

unless (-e $sample_csv) {
    warn "The sample sheet file '$sample_csv' does not exist";
    exit(-1);
}
my @sampleSheets = (new Pfizer::FastQC::SampleSheet($sample_csv));
unless (@sampleSheets) {
    exit(1);
}
register_core(@sampleSheets);
    
    
