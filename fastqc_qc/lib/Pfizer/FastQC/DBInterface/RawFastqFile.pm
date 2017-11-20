package Pfizer::FastQC::DBInterface::RawFastqFile;
use base qw( Wyeth::DB::DBInterface);

=head1 NAME

Pfizer::FastQC::DBInterface::RawFastqFile

=head1 SYNOPSIS

    my $object;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($object), $DB_DRIVER);

=head1 DESCRIPTION

A database interface to enable persistent storage of RawFastqFile objects.  Default
implementation shall be Oracle.  Instances of his class are instantiated for specific
persistable objects that inherit from Wyeth::DB::Persistable, by calling the 
Wyeth::DB::DBInterfaceFactory->create method, passing in the type of the object.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::RawFastqFile;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub FIELDS {
    my $self = shift;
    @Pfizer::FastQC::RawFastqFile::FIELDS;
}

sub TABLE {
    'QT_RAW_FASTQ_FILE';
}

sub PRIMARY_KEY {
    'RAW_FASTQ_FILE_ID';
}

sub SEQUENCE {
    'RAWFASTQFILESEQ';
}

1;
