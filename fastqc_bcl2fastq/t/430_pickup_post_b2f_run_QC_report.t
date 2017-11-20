use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCLDirectoryFactory;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::ReadCleanRunFactory;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use Data::Dumper;
use Carp;
use strict;

my $sgid = shift;
my $bdid = shift;

my $sg = Pfizer::FastQC::SampleGroupFactory->select($sgid);
my $bd = Pfizer::FastQC::BCLDirectoryFactory->select($bdid);

#my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;
#my @sampleSheets = Pfizer::FastQC::SampleGroup->findNewSampleSheets($FQ_BCL_ROOT_DIR);
#unless (@sampleSheets) {
#    exit(1);
#}

my $sample_csv = join("/", $bd->path, "SampleSheet.csv");
#unless (-e $sample_csv) {
#	confess "cannot read sample csv '$sample_csv'";
#}
protlog($LOG_FH, "using CSV $sample_csv");
 
my $ss = new Pfizer::FastQC::SampleSheet($sample_csv);

print Dumper $ss;
print Dumper $sg;

# my @rcrs = Pfizer::FastQC::ReadCleanRun->run_for_sample_group($sg, $sg->do_readclean, $ss);

my @rcrids = (2322..2333);
my @rcrs;
foreach my $rid (@rcrids) {
	push @rcrs, Pfizer::FastQC::ReadCleanRunFactory->select($rid);
}

print Dumper \@rcrs;

# insert and run the QC Report
my $qcr = new Pfizer::FastQC::QCReport();
$qcr->set_username($sg->userName);
$qcr->set_status('PEN');
$qcr->set_name(join("_", $sg->name, $sg->do_readclean));
$qcr->set_path(join("/", $Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR, $qcr->name));
$qcr->set_fastqc_extract(1);
unless ($qcr->insert) {
	confess "failed to insert QCReport";
}
my @infastqs;
foreach my $rcr (@rcrs) {
	push @infastqs, Pfizer::FastQC::CleanFastqFileFactory->selectByCriteria(READCLEAN_RUN_ID => ' = ' . $rcr->id);
}
foreach my $inf (@infastqs) {
        my $q2f = new Pfizer::FastQC::QCRep2Fastq();
        $q2f->set_qc_report_id($qcr->id);
        $q2f->set_fastq_file_id($inf->id);
        $q2f->set_fastq_type('CLEAN');
        unless ($q2f->insert) {
              confess "failed to insert QCRep2Fastq";
        }
}                      
if ($qcr->run) {
	protlog($LOG_FH, "Succesfully completed QCReport ID = " . $qcr->id);
} else {
        confess "failed to run QCReport ID = " . $qcr->id;
}

