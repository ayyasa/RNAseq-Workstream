use Pfizer::FastQC::BCLDirectoryFactory;
use Wyeth::Util::Utils qw(protlog);
use Carp;
use strict;

my $bcl_directory_id = shift;

unless (defined($bcl_directory_id)) {
    print "usage: $0 <bcl_directory_id>\n";
    exit(-1);
}

my $sg = Pfizer::FastQC::BCLDirectoryFactory->select($bcl_directory_id);
if ($sg) {
    unless ($sg->delete) {
	confess "failed to delete BCLDirectory ($bcl_directory_id)";
    }
} else {
    confess "failed to select BCLDirectory ID = $bcl_directory_id";
}

			     
