use File::Basename;
use Carp;
use strict;

my $dir1 = shift;
my $dir2 = shift;
my $execute = shift || 0;

my @f1 = <$dir1/*.fastq.gz>;

foreach my $f1 (@f1) {
    my ($bname, $fdir, $suffix) = fileparse($f1);
    my $fname = $bname . $suffix;
    my ($samplename, $index, $read);
    ($samplename, $index, $read) = ($fname =~ m/^(.+)_S(\d+)_(\d+)/);
    print "---\nlooking for '$fname' in $dir2\n";
    my $f1 = "$dir1/$fname";
    my @f2_cands = <$dir2/${samplename}_S*_${read}.fastq.gz>;
    unless (@f2_cands==1) {
        print "skipping: failed to find unique match for $fname\n";
	next;
    }
    print "found match: $f2_cands[0]\n"; # (original index='$index' read='$read')\n";
    my $f2 = $f2_cands[0];
    unless (-e $f1) {
	warn "failed to find $f1";
    } 
    unless (-e $f2) {
	warn "failed to find $f2";
    }
    my $fbase = sprintf("%s_%d.fastq.gz", $samplename, $read);
    if (-e $f1 && -e $f2 && @f2_cands==1) {
	my $cmd = "cat $f1 \\\n$f2 > $fbase";
	print "$cmd\n";
	if ($execute) {
	     unless (system($cmd)==0) {
		 confess "failed to run: $cmd";
	     }
	}
    } else {
	warn "skipping missing or partial pair";
    }
}
