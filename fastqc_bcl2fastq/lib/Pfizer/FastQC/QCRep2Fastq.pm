package Pfizer::FastQC::QCRep2Fastq;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::QCRep2Fastq

=head1 SYNOPSIS

    use Pfizer::FastQC::QCRep2Fastq;
    my $qcr = new Pfizer::FastQC::QCRep2Fastq();

 
=head1 DESCRIPTION

A QCRep2Fastq object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( QCREP_2_FASTQ_ID
QC_REPORT_ID
FASTQ_TYPE
FASTQ_FILE_ID
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $bd = new Pfizer::FastQC::QCRep2Fastq(); 
 Function: Returns a bare-bones QCRep2Fastq object
 Returns : a new QCRep2Fastq object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $bd->name;
 Function: Gets user name corresponding to this QCRep2Fastq
 Returns : user name

=cut

sub qc_report_id {
    my $self = shift;
    return $self->{'QC_REPORT_ID'};
}    

sub set_qc_report_id {
    my $self = shift;
    my $un = shift;
    $self->{'QC_REPORT_ID'} = $un;
}    

=head2 id

 Title   : id
 Usage   :  $bd->id;
 Function: Gets ID of this QCRep2Fastq
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'QCREP_2_FASTQ_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $bd->set_id;
 Function: Sets ID of this QCRep2Fastq
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'QCREP_2_FASTQ_ID'} = $id;
}    

=head2 fastq_file_id

 Title   : fastq_file_id
 Usage   :  $bd->fastq_file_id;
 Function: Gets FASTQ_FILE_ID of this QCRep2Fastq
 Returns : object FASTQ_FILE_ID

=cut

sub fastq_file_id {
    my $self = shift;
    return $self->{'FASTQ_FILE_ID'};
}    

=head2 set_fastq_file_id

 Title   : set_fastq_file_id
 Usage   :  $bd->set_fastq_file_id;
 Function: Sets FASTQ_FILE_ID of this QCRep2Fastq
 Returns : object FASTQ_FILE_ID

=cut

sub set_fastq_file_id {
    my $self = shift;
    my $fastq_file_id = shift;
    $self->{'FASTQ_FILE_ID'} = $fastq_file_id;
}    

=head2 fastq_type

 Title   : fastq_type
 Usage   :  $bd->fastq_type;
 Function: Gets FASTQ_TYPE of this QCRep2Fastq
 Returns : object FASTQ_TYPE

=cut

sub fastq_type {
    my $self = shift;
    return $self->{'FASTQ_TYPE'};
}    

=head2 set_fastq_type

 Title   : set_fastq_type
 Usage   :  $bd->set_fastq_type;
 Function: Sets FASTQ_TYPE of this QCRep2Fastq
 Returns : object FASTQ_TYPE

=cut

sub set_fastq_type {
    my $self = shift;
    my $fastq_type = shift;
    $self->{'FASTQ_TYPE'} = $fastq_type;
}    

1;
