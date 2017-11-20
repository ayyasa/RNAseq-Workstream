package Pfizer::FastQC::BCLDirectory;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::BCLDirectory

=head1 SYNOPSIS

    use Pfizer::FastQC::BCLDirectory;
    my $bd = new Pfizer::FastQC::BCLDirectory();

 
=head1 DESCRIPTION

A BCLDirectory object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use File::Basename; 
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( BCL_DIRECTORY_ID 
 NAME 
 PATH
 STATUS
 DATE_MODIFIED
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $bd = new Pfizer::FastQC::BCLDirectory(); 
 Function: Returns a bare-bones BCLDirectory object
 Returns : a new BCLDirectory object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $bd->name;
 Function: Gets user name corresponding to this BCLDirectory
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
 Function: Gets ID of this BCLDirectory
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'BCL_DIRECTORY_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $bd->set_id;
 Function: Sets ID of this BCLDirectory
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'BCL_DIRECTORY_ID'} = $id;
}    

=head2 path

 Title   : path
 Usage   :  $bd->path;
 Function: Gets PATH of this BCLDirectory
 Returns : object PATH

=cut

sub path {
    my $self = shift;
    return $self->{'PATH'};
}    

=head2 set_path

 Title   : set_path
 Usage   :  $bd->set_path;
 Function: Sets PATH of this BCLDirectory
 Returns : object PATH

=cut

sub set_path {
    my $self = shift;
    my $path = shift;
    $self->{'PATH'} = $path;
}    

=head2 status

 Title   : status
 Usage   :  $bd->status;
 Function: Gets STATUS of this BCLDirectory
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $bd->set_status;
 Function: Sets STATUS of this BCLDirectory
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    

=head2 date_modified

 Title   : date_modified
 Usage   :  $bd->date_modified;
 Function: Gets DATE_MODIFIED of this BCLDirectory
 Returns : object DATE_MODIFIED

=cut

sub date_modified {
    my $self = shift;
    return $self->{'DATE_MODIFIED'};
}    

=head2 set_date_modified

 Title   : set_date_modified
 Usage   :  $bd->set_date_modified;
 Function: Sets DATE_MODIFIED of this BCLDirectory
 Returns : object DATE_MODIFIED

=cut

sub set_date_modified {
    my $self = shift;
    my $date_modified = shift;
    $self->{'DATE_MODIFIED'} = $date_modified;
}    

sub buildFromSampleSheet {
    my $type = shift;
    my $ss = shift; # SampleSheet
    my ($name, $path, $suffix) = fileparse($ss->filename);
    my $bcl_dir_name;
    ($bcl_dir_name) = $path =~ m/$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR\/([^\/]+)/;
    my $bd = new Pfizer::FastQC::BCLDirectory();
    $bd->set_path($path);
    $bd->set_name($bcl_dir_name);
    $bd->set_status('PEN');
    $bd;
}

sub set_fail {
    my $self = shift;
    $self->set_update_status('FAI');
}

sub set_pass {
     my $self = shift;
    $self->set_update_status('PAS');
}

sub set_wor{
     my $self = shift;
    $self->set_update_status('WOR');
}

sub set_update_status {
    my $self = shift;
    my $stat = shift;
    $self->set_status($stat);
    unless ($self->update) {
	confess("failed to update BCLDirectory ID = " . $self->id);
    }
}

1;
