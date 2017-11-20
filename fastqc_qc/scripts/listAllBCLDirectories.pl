use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::SampleGroupFactory;
use Wyeth::Util::Utils qw(protlog);
use Data::Dumper;
use Carp;
use strict;

my @bclds = Pfizer::FastQC::BCLDirectory->getAll;
foreach my $bcl (@bclds) {
    my @sg = Pfizer::FastQC::SampleGroupFactory->selectByCriteria(BCL_DIRECTORY_ID => " = " . $bcl->id);
    if (@sg) {
	print join("\t", $bcl->id,
		   $bcl->status,
		   $sg[0]->userName,
		   $bcl->path,
		   $bcl->date_modified), "\n";
    }
}

