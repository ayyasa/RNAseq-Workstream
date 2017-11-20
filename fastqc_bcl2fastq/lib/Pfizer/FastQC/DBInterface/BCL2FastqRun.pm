package Pfizer::FastQC::DBInterface::BCL2FastqRun;
use base qw( Wyeth::DB::DBInterface);

=head1 NAME

Pfizer::FastQC::DBInterface::BCL2FastqRun

=head1 SYNOPSIS

    my $object;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($object), $DB_DRIVER);

=head1 DESCRIPTION

A database interface to enable persistent storage of BCL2FastqRun objects.  Default
implementation shall be Oracle.  Instances of his class are instantiated for specific
persistable objects that inherit from Wyeth::DB::Persistable, by calling the 
Wyeth::DB::DBInterfaceFactory->create method, passing in the type of the object.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::BCL2FastqRun;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub FIELDS {
    my $self = shift;
    @Pfizer::FastQC::BCL2FastqRun::FIELDS;
}

sub TABLE {
    'QT_BCL2FASTQ_RUN';
}

sub PRIMARY_KEY {
    'BCL2FASTQ_RUN_ID';
}

sub SEQUENCE {
    'BCL2FASTQRUNSEQ';
}

1;
