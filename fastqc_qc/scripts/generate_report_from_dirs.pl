use Pfizer::FastQC::Utils qw(generate_qc_report);
use Carp;
use strict;

unless (@ARGV>0) {
    print "usage: $0 <list_of_fastqc_directories>\n";
    exit(-1);
}

my @dirlist = @ARGV;
my $html_report = generate_qc_report(@dirlist);
print $html_report;


##store html report in a dir
my $outfile = "/hpc/grid/scratch/tbi/fastqc/temp/ying_fastqc_reports/60.html";

unless (open OUT, ">$outfile") {
        warn "cannot open $outfile: $!";
}

print OUT $html_report;
close OUT;


