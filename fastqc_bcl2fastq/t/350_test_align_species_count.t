use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(parse_bowtie_summary_table);
use Test::Simple tests => 1;
use Data::Dumper;
use Carp;
use strict;

my $intable = 'junk.seqtk.out.bowtie';
my $tref = parse_bowtie_summary_table($intable,  
				      $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE);
print Dumper $tref;				     
ok(1, 'parse_bowtie_summary_table');
