package Pfizer::FastQC::CleanFastqFile;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::CleanFastqFile

=head1 SYNOPSIS

    use Pfizer::FastQC::CleanFastqFile;
    my $qcr = new Pfizer::FastQC::CleanFastqFile();

 
=head1 DESCRIPTION

A CleanFastqFile object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Pfizer::FastQC::Config;
use Pfizer::FastQC::RawFastqFileFactory;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::SampleFactory;
use File::Basename;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( CLEAN_FASTQ_FILE_ID
RAW_FASTQ_FILE_ID
READCLEAN_RUN_ID
READ_NUMBER
TYPE
NAME
PATH
STATUS
DATE_MODIFIED
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $bd = new Pfizer::FastQC::CleanFastqFile(); 
 Function: Returns a bare-bones CleanFastqFile object
 Returns : a new CleanFastqFile object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $bd->name;
 Function: Gets user name corresponding to this CleanFastqFile
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
 Usage   :  $bd->id;
 Function: Gets ID of this CleanFastqFile
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'CLEAN_FASTQ_FILE_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $bd->set_id;
 Function: Sets ID of this CleanFastqFile
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'CLEAN_FASTQ_FILE_ID'} = $id;
}    

=head2 path

 Title   : path
 Usage   :  $bd->path;
 Function: Gets PATH of this CleanFastqFile
 Returns : object PATH

=cut

sub path {
    my $self = shift;
    return $self->{'PATH'};
}    

=head2 set_path

 Title   : set_path
 Usage   :  $bd->set_path;
 Function: Sets PATH of this CleanFastqFile
 Returns : object PATH

=cut

sub set_path {
    my $self = shift;
    my $path = shift;
    $self->{'PATH'} = $path;
}    

sub readclean_run_id {
    my $self = shift;
    return $self->{'READCLEAN_RUN_ID'};
}

sub set_readclean_run_id {
    my $self = shift;
    my $readclean_run_id = shift;
    $self->{'READCLEAN_RUN_ID'} = $readclean_run_id;
}
 
sub read_number {
    my $self = shift;
    return $self->{'READ_NUMBER'};
}

sub set_read_number {
    my $self = shift;
    my $read_number = shift;
    $self->{'READ_NUMBER'} = $read_number;
}

sub type {
    my $self = shift;
    return $self->{'TYPE'};
}

sub set_type {
    my $self = shift;
    my $type = shift;
    $self->{'TYPE'} = $type;
}

=head2 status

 Title   : status
 Usage   :  $bd->status;
 Function: Gets STATUS of this CleanFastqFile
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $bd->set_status;
 Function: Sets STATUS of this CleanFastqFile
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    

=head2 raw_fastq_file_id

 Title   : raw_fastq_file_id
 Usage   :  $bd->raw_fastq_file_id;
 Function: Gets RAW_FASTQ_FILE_ID of this CleanFastqFile
 Returns : object RAW_FASTQ_FILE_ID

=cut

sub raw_fastq_file_id {
    my $self = shift;
    return $self->{'RAW_FASTQ_FILE_ID'};
}    

=head2 set_raw_fastq_file_id

 Title   : set_raw_fastq_file_id
 Usage   :  $bd->set_raw_fastq_file_id;
 Function: Sets RAW_FASTQ_FILE_ID of this CleanFastqFile
 Returns : object RAW_FASTQ_FILE_ID

=cut

sub set_raw_fastq_file_id {
    my $self = shift;
    my $raw_fastq_file_id = shift;
    $self->{'RAW_FASTQ_FILE_ID'} = $raw_fastq_file_id;
}    

sub full_path {
    my $self = shift;
    join("/", $self->path, $self->name);
}

=head2 sampleGroup

 Title   : sampleGroup
 Usage   : 
 Function: 
 Returns : The parent sampleGroup for this CleanFastqFile

=cut

sub sampleGroup {
    my $self = shift;
    my $rfq = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_id);
    my $samp = Pfizer::FastQC::SampleFactory->select($rfq->sample_id);
    my $sg = Pfizer::FastQC::SampleGroupFactory->select($samp->sample_group_id);
    $sg;
}

sub register {
    my $self = shift;
    my ($rfq_id, $readclean_run_id, $read_number, $full_path) = @_;
    $self->set_raw_fastq_file_id($rfq_id);
    $self->set_readclean_run_id($readclean_run_id);
    $self->set_read_number($read_number);
    my ($fname, $fdir, $suffix) = fileparse($full_path);
    $self->set_name($fname . $suffix);
    $fdir =~ s/\/$//;
    $self->set_path($fdir);
    $self->set_status('PAS');
    $self->set_type('CLEAN');
    unless (-e $self->full_path) {
	confess "Fastq file " . $self->full_path . " does not exist.  An existing file is required for registration.";
    }
    unless ($self->insert) {
		confess "failed to insert CleanFastqFile for RawFastqFile ID = " . $self->raw_fastq_file_id;
    }  
    return 1;
}

1;
