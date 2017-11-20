use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCLDirectory;
use Test::Simple tests => 2;
use Carp;
use Data::Dumper;
use strict;

my $bd = new Pfizer::FastQC::BCLDirectory();
$bd->set_name('BCLDirectory1');
$bd->set_path("$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR/141212_NS500482_0005_AH14JJBGXX");

print Dumper $bd;

if ($bd->insert) {
   ok(1, 'BCLDirectory - insert');
}

if (Pfizer::FastQC::BCLDirectory->selectByCriteria( NAME => join(" ", "=", "'".$bd->name."'"))) {
    ok(1, 'BCLDirectory - select by criteria');
}


