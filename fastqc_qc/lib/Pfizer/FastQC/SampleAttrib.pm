package Pfizer::FastQC::SampleAttrib;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::SampleAttrib

=head1 SYNOPSIS

    use Pfizer::FastQC::SampleAttrib;
    my $sa = new Pfizer::FastQC::SampleAttrib();

 
=head1 DESCRIPTION

A SampleAttrib object represents one name:value attribute for a Sample.

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( SAMPLE_ATTRIB_ID 
 SAMPLE_ID
NAME 
VALUE
AORDER
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $sa = new Pfizer::FastQC::SampleAttrib(); 
 Function: Returns a bare-bones SampleAttrib object
 Returns : a new SampleAttrib object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $sa>name;
 Function: Gets user name corresponding to this SampleAttrib
 Returns : user name

=cut

sub name {
    my $self = shift;
    return $self->{'NAME'};
}    

sub set_name {
    my $self = shift;
    my $un = shift;
    $self->{'NAME'} = $un;
}    

=head2 id

 Title   : id
 Usage   :  $sa->id;
 Function: Gets ID of this SampleAttrib
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'SAMPLE_ATTRIB_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $sa->set_id;
 Function: Sets ID of this SampleAttrib
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'SAMPLE_ATTRIB_ID'} = $id;
}    

sub sample_id {
    my $self = shift;
    return $self->{'SAMPLE_ID'};
}

sub set_sample_id {
    my $self = shift;
    my $id = shift;
    $self->{'SAMPLE_ID'} = $id;
}    

sub value {
    my $self = shift;
    return $self->{'VALUE'};
}

sub set_value {
    my $self = shift;
    my $id = shift;
    $self->{'VALUE'} = $id;
}    

sub order {
    my $self = shift;
    return $self->{'AORDER'};
}    

sub set_order {
    my $self = shift;
    my $id = shift;
    $self->{'AORDER'} = $id;
}

1;
