package Pfizer::FastQC::DBInterface::SampleAttrib;
use base qw( Wyeth::DB::DBInterface);

=head1 NAME

Pfizer::FastQC::DBInterface::SampleAttrib

=head1 SYNOPSIS

    my $object;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($object), $DB_DRIVER);

=head1 DESCRIPTION

A database interface to enable persistent storage of SampleAttrib objects.  Default
implementation shall be Oracle.  Instances of his class are instantiated for specific
persistable objects that inherit from Wyeth::DB::Persistable, by calling the 
Wyeth::DB::DBInterfaceFactory->create method, passing in the type of the object.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::SampleAttrib;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub FIELDS {
    my $self = shift;
    @Pfizer::FastQC::SampleAttrib::FIELDS;
}

sub TABLE {
    'QT_SAMPLE_ATTRIB';
}

sub PRIMARY_KEY {
    'SAMPLE_ATTRIB_ID';
}

sub SEQUENCE {
    'SAMPLEATTRIBSEQ';
}

1;
