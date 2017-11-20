package Pfizer::FastQC::DBInterface::SampleGroup;
use base qw( Wyeth::DB::DBInterface);

=head1 NAME

Pfizer::FastQC::DBInterface::SampleGroup

=head1 SYNOPSIS

    my $object;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($object), $DB_DRIVER);

=head1 DESCRIPTION

A database interface to enable persistent storage of SampleGroup objects.  Default
implementation shall be Oracle.  Instances of his class are instantiated for specific
persistable objects that inherit from Wyeth::DB::Persistable, by calling the 
Wyeth::DB::DBInterfaceFactory->create method, passing in the type of the object.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::SampleGroup;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub FIELDS {
    my $self = shift;
    @Pfizer::FastQC::SampleGroup::FIELDS;
}

sub TABLE {
    'QT_SAMPLE_GROUP';
}

sub PRIMARY_KEY {
    'SAMPLE_GROUP_ID';
}

sub SEQUENCE {
    'SAMPLEGROUPSEQ';
}

1;
