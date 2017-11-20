use Pfizer::FastQC::BCL2FastqRun;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use File::Path qw(make_path);
use strict;

my $b2f = new Pfizer::FastQC::BCL2FastqRun();
$b2f->set_bcl_directory_id(580);
$b2f->set_loading_threads(16);
$b2f->set_demultx_threads(16);
$b2f->set_proc_threads(32);
$b2f->set_write_threads(16);
$b2f->set_status('PEN');
$b2f->set_output_dir("$Pfizer::FastQC::Config::RAW_FASTQ_FILE_DIR/test");

print Dumper $b2f;

if ($b2f->insert) {
   ok(1, 'BCL2FastqRun - insert');
}

if (Pfizer::FastQC::BCL2FastqRun->selectByCriteria( STATUS => join(" ", "=", "'".$b2f->status."'"))) {
    ok(1, 'BCL2FastqRun - select by criteria');
}

print Dumper $b2f;

unless (-e $b2f->output_dir) {
       	   unless(make_path($b2f->output_dir)) {
	       confess "failed to create directory: " . $b2f->output_dir;
	   }
}

if ($b2f->run) {
   ok(1, 'BCL2FastqRun - run');
}

