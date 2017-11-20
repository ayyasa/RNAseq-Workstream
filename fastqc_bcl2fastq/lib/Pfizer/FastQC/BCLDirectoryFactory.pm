package Pfizer::FastQC::BCLDirectoryFactory;

=head1 NAME

Pfizer::FastQC::BCLDirectoryFactory

=head1 SYNOPSIS

    use Pfizer::FastQC::BCLDirectoryFactory;
    my $bd = Pfizer::FastQC::BCLDirectoryFactory->create();
    my $bd = Pfizer::FastQC::BCLDirectoryFactory->select($id);
    my @bds = Pfizer::FastQC::BCLDirectoryFactory->selectByCriteria(OUTDIR => '/boo/bar/zap');
 
=head1 DESCRIPTION

A BCLDirectoryFactory is a parameterized factory class that generates BCLDirectoryFactory objects.

=head1 AUTHOR

Andrew Hill, Pfizer

=cut

use warnings 'all';
use Pfizer::FastQC::BCLDirectory;
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
    return Pfizer::FastQC::BCLDirectory->new();
}

sub select {
    my $type = shift;
    my $id = shift;
    my $bd = new Pfizer::FastQC::BCLDirectory();
    unless ($bd->select($id)) {
	confess "error: cannot select id = $id";
    }
    return $bd;
}

sub selectByCriteria {
    my $type = shift;
    my %criteria = @_;
    my @s = Pfizer::FastQC::BCLDirectory->selectByCriteria(%criteria);
    @s;
}

1;
