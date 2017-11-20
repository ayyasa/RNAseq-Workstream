use Test::Simple tests => 1;
use strict;

my $fastqref = [ 'foo/bar/abc.fq.gz', 'bat/zap/def.fastq.gz', '/larg/map/ghi.faq.gz'];
my $output_dir = '/my/output/dir';

my @output_dirs = map { $_ =~ s/(^.+\/)([^\/]+)\.f(ast)?q.gz$/$output_dir\/$2_fastqc/; $_ } @$fastqref;
print join("\n", @output_dirs), "\n";
ok(1, 'fq substitute');
