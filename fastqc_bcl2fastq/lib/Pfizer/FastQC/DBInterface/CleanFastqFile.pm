package Pfizer::FastQC::DBInterface::CleanFastqFile;
use base qw( Wyeth::DB::DBInterface);

=head1 NAME

Pfizer::FastQC::DBInterface::CleanFastqFile

=head1 SYNOPSIS

    my $object;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($object), $DB_DRIVER);

=head1 DESCRIPTION

A database interface to enable persistent storage of CleanFastqFile objects.  Default
implementation shall be Oracle.  Instances of his class are instantiated for specific
persistable objects that inherit from Wyeth::DB::Persistable, by calling the 
Wyeth::DB::DBInterfaceFactory->create method, passing in the type of the object.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::CleanFastqFile;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub FIELDS {
    my $self = shift;
    @Pfizer::FastQC::CleanFastqFile::FIELDS;
}

sub TABLE {
    'QT_CLEAN_FASTQ_FILE';
}

sub PRIMARY_KEY {
    'CLEAN_FASTQ_FILE_ID';
}

sub SEQUENCE {
    'CLEANFASTQFILESEQ';
}

1;
