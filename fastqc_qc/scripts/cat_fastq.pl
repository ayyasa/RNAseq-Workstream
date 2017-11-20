use File::Basename;
use Carp;
use strict;

my $dir1 = shift;
my $dir2 = shift;

my @f1 = <$dir1/*.fastq.gz>;

foreach my $f1 (@f1) {
    my ($bname, $fdir, $suffix) = fileparse($f1);
    my $fname = $bname . $suffix;
    my $f1 = "$dir1/$fname";
    my $f2 = "$dir2/$fname";
    my $fbase = $fname;
    unless (-e $f1) {
	warn "failed to find $f1";
    } 
    unless (-e $f2) {
	warn "failed to find $f2";
    }
    if (-e $f1 && -e $f2) {
	my $cmd = "cat $f1 $f2 > $fbase";
	print "$cmd\n";
	unless (system($cmd)==0) {
	    confess "failed to run: $cmd";
	}
    } else {
	warn "skipping missing or partial pair";
    }
}
