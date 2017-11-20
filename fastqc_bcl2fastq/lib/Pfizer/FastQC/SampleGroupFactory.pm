package Pfizer::FastQC::SampleGroupFactory;

=head1 NAME

Pfizer::FastQC::SampleGroupFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::SampleGroupFactory;
    my $sg = Pfizer::FastQC::SampleGroupFactory->create();
    my $sg = Pfizer::FastQC::SampleGroupFactory->select($id);
    my @sgs = Pfizer::FastQC::SampleGroupFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A SampleGroupFactory is a parameterized factory class that generates SampleGroupFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::SampleGroup;
use Carp;
use strict;

my $BASE_CLASS = 'Pfizer::FastQC';

sub _toClass {
    my $fully_qualified_name = shift;
    my ($class) = ( $fully_qualified_name =~ m/$BASE_CLASS::(.+)$/ );
    if ($class) {
	return $class;
    } else {
	confess "failed to parse Class from string: \'$fully_qualified_name\'";
    }
}

sub create {
    my $type = shift;
    return Pfizer::FastQC::SampleGroup->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::SampleGroup();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::SampleGroup->selectByCriteria(%criteria);
    @s;
}

1;
