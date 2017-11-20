use Pfizer::FastQC::Config;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::Sample;
use Pfizer::FastQC::CleanFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Test::Simple tests => 2;
use Data::Dumper;
use Carp;
use File::Glob 'bsd_glob';	
use strict;

my $indir = "/hpc/grid/scratch/ayyasa/fastqc/raw/170607_NS500482_0299_AHVHNKBGX2_S3";
# "/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/MiSeq_TREX_2H_fastq files";
my @infastqs = bsd_glob("$indir/Undetermined_S0_R1_001.fastq.gz");
# print(join("\n", @infastqs), "\n");

my $sg = new Pfizer::FastQC::SampleGroup();
unless ($sg->register(581, 'nextseq_test_4', $Pfizer::FastQC::Config::ADMIN_EMAIL,
	      undef, 'None', 2)) {
    confess "failed to register sample group";
}


my $s = new Pfizer::FastQC::Sample();
$s->register($sg->id);
ok(1,'Registered samples');

foreach my $f (@infastqs) {
    my $fq = new Pfizer::FastQC::RawFastqFile();
    my ($sample_id, $sample_order, $lane, $read, $oh1) = Pfizer::FastQC::RawFastqFile->fastq_name_2_parts($f);
    # print join(":", $sample_id, $sample_order, $lane, $read, $oh1), "\n";
    $fq->register(undef, $s->id, $read, $f);
    my $rcr = new Pfizer::FastQC::ReadCleanRun();
    $rcr->register_passthrough($fq->id);
    my $cfq = new Pfizer::FastQC::CleanFastqFile();
    $cfq->register($fq->id, $rcr->id, $read, $f);
}
print "registered " . scalar(@infastqs) . " fastq files for SampleGroup '" . $sg->name . "'\n";
print "Sample group has " . scalar $sg->get_raw_fastqs . " raw fastqs\n";
print "Sample group has " . scalar $sg->get_clean_fastqs . " clean fastqs\n";

ok(1, 'RawFastq files - register');
