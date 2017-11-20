package Pfizer::FastQC::RawFastqFile;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::RawFastqFile

=head1 SYNOPSIS

    use Pfizer::FastQC::RawFastqFile;
    my $qcr = new Pfizer::FastQC::RawFastqFile();

 
=head1 DESCRIPTION

A RawFastqFile object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::CleanFastqFileFactory;
use File::Basename;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( RAW_FASTQ_FILE_ID
SAMPLE_ID
BCL2FASTQ_RUN_ID
READ_NUMBER
NAME
PATH
STATUS
DATE_MODIFIED
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $bd = new Pfizer::FastQC::RawFastqFile(); 
 Function: Returns a bare-bones RawFastqFile object
 Returns : a new RawFastqFile object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $bd->name;
 Function: Gets user name corresponding to this RawFastqFile
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
 Function: Gets ID of this RawFastqFile
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'RAW_FASTQ_FILE_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $bd->set_id;
 Function: Sets ID of this RawFastqFile
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'RAW_FASTQ_FILE_ID'} = $id;
}    

sub bcl2fastq_run_id {
    my $self = shift;
    return $self->{'BCL2FASTQ_RUN_ID'};
}    

sub set_bcl2fastq_run_id {
    my $self = shift;
    my $bcl2fastq_run_id = shift;
    $self->{'BCL2FASTQ_RUN_ID'} = $bcl2fastq_run_id;
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

sub sample_id {
    my $self = shift;
    return $self->{'SAMPLE_ID'};
}    

sub set_sample_id {
    my $self = shift;
    my $sample_id = shift;
    $self->{'SAMPLE_ID'} = $sample_id;
}    

=head2 path

 Title   : path
 Usage   :  $bd->path;
 Function: Gets PATH of this RawFastqFile
 Returns : object PATH

=cut

sub path {
    my $self = shift;
    return $self->{'PATH'};
}    


=head2 set_path

 Title   : set_path
 Usage   :  $bd->set_path;
 Function: Sets PATH of this RawFastqFile
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
 Function: Gets STATUS of this RawFastqFile
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $bd->set_status;
 Function: Sets STATUS of this RawFastqFile
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    

sub full_path {
    my $self = shift;
    join("/", $self->path, $self->name);
}

=head2 sampleGroup

 Title   : sampleGroup
 Usage   : 
 Function: 
 Returns : the parent SampleGroup object corresponding to the RawFastqFile 

=cut

sub sampleGroup {
    my $self = shift;
    my $samp = Pfizer::FastQC::SampleFactory->select($self->sample_id);
    my $sg = Pfizer::FastQC::SampleGroupFactory->select($samp->sample_group_id);
    $sg;
}

sub exists {
    my $self = shift;
    if (-r $self->full_path) {
	return 1;
    }
    return 0;
}

sub fastq_name_2_parts {
    my $type = shift;
    my $fname = shift;
    my ($bname, $fdir, $suffix) = fileparse($fname);
    $bname = $bname . $suffix;
    my ($sample_id, $sample_order, $lane, $read, $oh1);
    if ($bname =~ m/^([^_]+)_S([^_]+)_R(\d+)_([^_]+)\.fastq\.gz$/) {
	($sample_id, $sample_order, $read, $oh1) = ($1, $2, $3, $4);
    } else {
	warn "failed to match Illumina fastq naming convention for file with basename '$bname'";
	($sample_id, $sample_order, $lane, $read, $oh1) = (undef, undef, undef, undef, undef);
    }
    return ($sample_id, $sample_order, $lane, $read, $oh1);
}

sub register {
    my $self = shift;
    my ($b2f_id, $sample_id, $read_number, $full_path) = @_;
    $self->set_bcl2fastq_run_id($b2f_id);
    $self->set_sample_id($sample_id);
    $self->set_read_number($read_number);
    my ($fname, $fdir, $suffix) = fileparse($full_path);
    $self->set_name($fname . $suffix);
    $fdir =~ s/\/$//;
    $self->set_path($fdir);
    $self->set_status('PAS');
    unless (-e $self->full_path) {
	confess "Fastq file " . $self->full_path . " does not exist.  An existing file is required for registration.";
    }
    unless ($self->insert) {
		confess "failed to insert RawFastqFile for BCL2FastqRun ID = " . $self->bcl2fastq_run_id;
    }  
    return 1;
}


sub get_clean_fastqs {
    my $self = shift;
    my @cfqs = Pfizer::FastQC::CleanFastqFileFactory->selectByCriteria(RAW_FASTQ_FILE_ID => ' = ' . $self->id);
}

sub select_by_sample_read {
    my $type = shift;
    my $sample_id = shift;
    my $read_num = shift;

print "type = $type\nSample ID=$sample_id & Read number = $read_num\n";
    my @rfqs = $type->selectByCriteria(SAMPLE_ID => ' = ' . $sample_id, READ_NUMBER => ' = ' . $read_num);
    $rfqs[0];
}

1;
