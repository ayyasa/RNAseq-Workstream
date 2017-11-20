package Pfizer::FastQC::QCReportFactory;

=head1 NAME

Pfizer::FastQC::QCReportFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::QCReportFactory;
    my $sg = Pfizer::FastQC::QCReportFactory->create();
    my $sg = Pfizer::FastQC::QCReportFactory->select($id);
    my @sgs = Pfizer::FastQC::QCReportFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A QCReportFactory is a parameterized factory class that generates QCReportFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::QCReport;
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
    return Pfizer::FastQC::QCReport->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::QCReport();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::QCReport->selectByCriteria(%criteria);
    @s;
}

1;
