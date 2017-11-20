use Pfizer::FastQC::SampleSheet;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;

my $sample_file = shift;
#my $sample_file = '/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/NextSeq500_bcl_folder/150310_NS500482_0009_AH04DNAFXX/SampleSheet.csv';
#my $sample_file = '/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/NextSeq500_bcl_folder/160505_NS500482_0117_AH3CMKBGXY/SampleSheet.csv';
# '/151103_NS500482_0069_AHK75NBGXX_Theresa_miR/SampleSheet.csv';
# my $sample_file = "/afs/grid.pfizer.com/alds/projects/dev/fastqc/test-bcl-root/141212_NS500482_0005_AH14JJBGXX/SampleSheet.csv";
# 1-read run
# my $sample_file = "/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/NextSeq500_bcl_folder/150320_NS500482_0013_AH04CLAFXX/SampleSheet.csv";
# 2-read run
# "/hpc/grid/wip_cmg_prec_med/Nucleic_Acid_Group/NextSeq500_bcl_folder/150116_NS500482_0006_AH14B4BGXX/SampleSheet.csv";
my $ss= new Pfizer::FastQC::SampleSheet($sample_file);
# print Dumper $ss;
print "Num reads: " . $ss->num_reads . "\n";
print "Samples:\n";
print Dumper $ss->samples;
print "Sample attribs:\n";
print Dumper $ss->sample_attrib;
ok(1, 'SampleSheet');
