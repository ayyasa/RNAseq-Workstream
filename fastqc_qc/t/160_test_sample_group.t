use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::SampleGroupFactory;
use Test::Simple tests => 3;
use Carp;
use Data::Dumper;
use strict;

my $sg = Pfizer::FastQC::SampleGroupFactory->create();
ok(1, 'SampleGroupFactory->create');
$sg->set_userName('archana.ayyaswamy@pfizer.com');
$sg->set_checksum('xfff70b');

if ($sg->insert) {
   ok(1, 'SampleGroup - insert');
}

$sg = Pfizer::FastQC::SampleGroupFactory->select($sg->id);

if (Pfizer::FastQC::SampleGroup->selectByCriteria( SAMPLESHEET_CHECKSUM => join(" ", "= ", "'".$sg->checksum."'"))) {
    ok(1, 'SampleGroup');
}


