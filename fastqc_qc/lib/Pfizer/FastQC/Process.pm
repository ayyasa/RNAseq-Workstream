package Pfizer::FastQC::Process;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::QCReport

=head1 SYNOPSIS

    use Pfizer::FastQC::QCReport;
    my $qcr = new Pfizer::FastQC::QCReport();
 
=head1 DESCRIPTION

A QCReport object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Wyeth::Util::Utils qw(protlog sendmail);
use Pfizer::FastQC::Utils qw(run_fastqc  generate_qc_report contamAlignParallel supportText recipient_list);
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2FastqFactory;
use File::Path qw(make_path);
use Data::Dumper;
use File::Basename;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( PROCESS_ID
PROCESS_NAME
PROCESS_VERSION
CREATED_BY
CREATED_DATE
MODIFIED_BY
MODIFIED_DATE
PROCESS_STATE
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $bd = new Pfizer::FastQC::QCReport(); 
 Function: Returns a bare-bones QCReport object
 Returns : a new QCReport object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $bd->name;
 Function: Gets user name corresponding to this QCReport
 Returns : user name

=cut

sub process_name {
    my $self = shift;
    return $self->{'PROCESS_NAME'};
}    

sub set_process_name {
    my $self = shift;
    my $un = shift;
    $self->{'PROCESS_NAME'} = $un;
}    

=head2 id

 Title   : id
 Usage   :  $bd->id;
 Function: Gets ID of this QCReport
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'PROCESS_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $bd->set_id;
 Function: Sets ID of this QCReport
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'PROCESS_ID'} = $id;
}    



































































































































































































































































































1;
