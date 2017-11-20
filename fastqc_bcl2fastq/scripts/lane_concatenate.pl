use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCL2FastqRunFactory;
use Wyeth::Util::Utils qw(protlog);
use Carp;
use strict;

my $self = Pfizer::FastQC::BCL2FastqRunFactory->select(shift);
if ($self->concat_lane_fastq) {
    print "succesfully ran concat_lane_fastq for BCL2FastqRun = " . $self->id . "\n";
} else {
    $self->set_status('FAI');
    if ($self->update) {
	warn "failed to run concat_lane_fastq";
	confess "failed to update BCL2FastQRun status (ID=" . $self->id . ")";
    } else {
	confess "failed to update BCL2FastQRun status (ID=" . $self->id . ")";
    }
}

# insert the resulting raw fastq files
my @raw_fastqs = $self->_insertFastqs();

# run complete
$self->set_status('PAS');
unless ($self->update) {
    confess "failed to update BCL2FastQRun status (ID=" . $self->id . ")";
}
my $num_fq = @raw_fastqs;
print "succesfully lane concatenated for BCL2FastqRun = " . $self->id . " ($num_fq fastq files registered)\n";


