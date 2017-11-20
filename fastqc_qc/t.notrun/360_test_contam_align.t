use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(contamAlign);
use Test::Simple tests => 1;
use Data::Dumper;
use Carp;
use strict;

my @infastq = `cat ../R/sample_input_file`;

foreach my $infq (@infastq) {
    chomp $infq;
    my $tref = contamAlign($infq,  $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE*100, $$);
    print Dumper $tref;				
}	     
ok(1, 'contamAlign');
