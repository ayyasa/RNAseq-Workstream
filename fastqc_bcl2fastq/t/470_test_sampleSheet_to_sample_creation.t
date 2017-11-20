use Pfizer::FastQC::SampleSheet;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::Sample;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;
my $sample_file = '/afs/grid.pfizer.com/alds/users/ayyasa/perl/t/SampleSheet.csv';
my $ss= new Pfizer::FastQC::SampleSheet($sample_file);
print Dumper $ss;
my $bd = Pfizer::FastQC::BCLDirectory->buildFromSampleSheet($ss);
print Dumper $bd;
unless ($bd->insert) { 
    confess "failed to insert BCL Directory";
}
my $sg = Pfizer::FastQC::SampleGroup->insertSampleGroup($bd, $ss);
print Dumper $sg;
my ($sref, $saref) = Pfizer::FastQC::Sample->insertSamples($sg, $ss);
print Dumper $sref;
print Dumper $saref;
ok(1, 'SampleSheet to sample creation');
