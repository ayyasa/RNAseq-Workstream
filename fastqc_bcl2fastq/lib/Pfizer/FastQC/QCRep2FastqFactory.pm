package Pfizer::FastQC::QCRep2FastqFactory;

=head1 NAME

Pfizer::FastQC::QCRep2FastqFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::QCRep2FastqFactory;
    my $sg = Pfizer::FastQC::QCRep2FastqFactory->create();
    my $sg = Pfizer::FastQC::QCRep2FastqFactory->select($id);
    my @sgs = Pfizer::FastQC::QCRep2FastqFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A QCRep2FastqFactory is a parameterized factory class that generates QCRep2FastqFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::QCRep2Fastq;
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
    return Pfizer::FastQC::QCRep2Fastq->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::QCRep2Fastq();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::QCRep2Fastq->selectByCriteria(%criteria);
    @s;
}

1;
