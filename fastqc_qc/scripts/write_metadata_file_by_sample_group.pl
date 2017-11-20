use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Wyeth::Util::Utils qw(protlog);
use Data::Dumper;
use strict;

my $sgid = shift;
my $sg = Pfizer::FastQC::SampleGroupFactory->select($sgid);
my ($headsref, $recs) = $sg->attrib_table();
my $bd = new Pfizer::FastQC::BCLDirectory();
$bd->select($sg->bcl_directory_id);
my @b2fs = Pfizer::FastQC::BCL2FastqRun->selectByCriteria(BCL_DIRECTORY_ID => ' = ' . $bd->id);
my $dest_file = join('/', $b2fs[0]->output_dir, 'metadata.txt');
open OUT, ">$dest_file" or die "cannot open $dest_file: $!";
my ($headsref, $recs) = $sg->attrib_table();
print OUT join("\t", @$headsref), "\n";
foreach my $rec (@$recs) {
    print OUT join("\t", @$rec), "\n";
}
close OUT;
protlog($LOG_FH, "wrote metadata to $dest_file");
