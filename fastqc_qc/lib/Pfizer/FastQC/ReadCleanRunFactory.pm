package Pfizer::FastQC::ReadCleanRunFactory;

=head1 NAME

Pfizer::FastQC::ReadCleanRunFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::ReadCleanRunFactory;
    my $sg = Pfizer::FastQC::ReadCleanRunFactory->create();
    my $sg = Pfizer::FastQC::ReadCleanRunFactory->select($id);
    my @sgs = Pfizer::FastQC::ReadCleanRunFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A ReadCleanRunFactory is a parameterized factory class that generates ReadCleanRunFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::ReadCleanRun;
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
    return Pfizer::FastQC::ReadCleanRun->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::ReadCleanRun();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::ReadCleanRun->selectByCriteria(%criteria);
    @s;
}

1;
