package Pfizer::FastQC::SampleFactory;

=head1 NAME

Pfizer::FastQC::SampleFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::SampleFactory;
    my $sg = Pfizer::FastQC::SampleFactory->create();
    my $sg = Pfizer::FastQC::SampleFactory->select($id);
    my @sgs = Pfizer::FastQC::SampleFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A SampleFactory is a parameterized factory class that generates SampleFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::Sample;
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
    return Pfizer::FastQC::Sample->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::Sample();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::Sample->selectByCriteria(%criteria);
    @s;
}

1;
