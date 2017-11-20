use Pfizer::FastQC::Utils qw(getIconSrc);
use Test::Simple tests => 3;
use Carp;
use strict;

foreach my $icon_name (sort keys %Pfizer::FastQC::Config::IMG_SRC) {
    print join ("\t", $icon_name, getIconSrc($icon_name)), "\n";
    ok(1, "getIconSrc $icon_name");
}
