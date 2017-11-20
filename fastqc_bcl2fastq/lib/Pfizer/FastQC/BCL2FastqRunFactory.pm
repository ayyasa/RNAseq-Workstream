package Pfizer::FastQC::BCL2FastqRunFactory;

=head1 NAME

Pfizer::FastQC::BCL2FastqRunFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::BCL2FastqRunFactory;
    my $sg = Pfizer::FastQC::BCL2FastqRunFactory->create();
    my $sg = Pfizer::FastQC::BCL2FastqRunFactory->select($id);
    my @sgs = Pfizer::FastQC::BCL2FastqRunFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A BCL2FastqRunFactory is a parameterized factory class that generates BCL2FastqRunFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::BCL2FastqRun;
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
    return Pfizer::FastQC::BCL2FastqRun->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::BCL2FastqRun();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::BCL2FastqRun->selectByCriteria(%criteria);
    @s;
}

1;
