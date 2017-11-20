package Pfizer::FastQC::RawFastqFileFactory;

=head1 NAME

Pfizer::FastQC::RawFastqFileFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::RawFastqFileFactory;
    my $sg = Pfizer::FastQC::RawFastqFileFactory->create();
    my $sg = Pfizer::FastQC::RawFastqFileFactory->select($id);
    my @sgs = Pfizer::FastQC::RawFastqFileFactory->selectByCriteria(SAMPLESHEET_CHECKSUM => '= fffx');
 
=head1 DESCRIPTION

A RawFastqFileFactory is a parameterized factory class that generates RawFastqFileFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::RawFastqFile;
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
    return Pfizer::FastQC::RawFastqFile->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $sg = new Pfizer::FastQC::RawFastqFile();
    unless ($sg->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $sg;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::RawFastqFile->selectByCriteria(%criteria);
    @s;
}

1;
