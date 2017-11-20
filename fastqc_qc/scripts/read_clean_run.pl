use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use Pfizer::FastQC::Utils qw(_trim1_cmd);
use File::Basename; 
use Data::Dumper;
use Carp;
use strict;

my $in = shift;
my $out = shift;
my $cmd = join(" ", _trim1_cmd($in, $out));
print "$cmd\n";
system($cmd);


