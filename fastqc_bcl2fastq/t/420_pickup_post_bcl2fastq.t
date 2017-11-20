use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCL2FastqRunFactory;
use Wyeth::Util::Utils qw(protlog sendmail);
use Data::Dumper;
use Carp;
use strict;

my $bdid = shift;
my $bd = Pfizer::FastQC::BCL2FastqRunFactory->select($bdid);
my $b2f;
my @b2fs;

if (@b2fs = Pfizer::FastQC::BCL2FastqRun->getByBCLDirectoryID($bd->id)) {
            protlog($LOG_FH, "BCL Directory ID = " . $bd->id . " already has generated .fastq files");
            $b2f = $b2fs[0];
} else {
	confess "failed to find BCL2FastqRun";
}

print Dumper $b2f;

$b2f->concat_lane_fastq;
# insert the resulting raw fastq files
my @raw_fastqs = $b2f->_insertFastqs();
# run complete
$b2f->set_status('PAS');
unless ($b2f->update) {
	confess "failed to update BCL2FastQRun status (ID=" . $b2f->id . ")";
}

protlog($LOG_FH, "did lane concatenation and inserted " . scalar(@raw_fastqs) . " fastq files for BCL2FastQCRun = " . $b2f->id);

