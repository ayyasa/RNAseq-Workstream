use Pfizer::FastQC::SampleGroupFactory;
use Wyeth::Util::Utils qw(protlog);
use Carp;
use strict;

my $sample_group_id = shift;

unless (defined($sample_group_id)) {
    print "usage: $0 <sample_group_id>\n";
    exit(-1);
}

my $sg = Pfizer::FastQC::SampleGroupFactory->select($sample_group_id);
if ($sg) {
    unless ($sg->delete) {
	confess "failed to delete SampleGroup ($sample_group_id)";
    }
} else {
    confess "failed to select SampleGroup ID = $sample_group_id";
}

			     
