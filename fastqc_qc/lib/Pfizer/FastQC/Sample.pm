package Pfizer::FastQC::Sample;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::Sample

=head1 SYNOPSIS

    use Pfizer::FastQC::Sample;
    my $sg = new Pfizer::FastQC::Sample();

 
=head1 DESCRIPTION

A Sample object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Wyeth::Util::Utils qw(protlog);
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( SAMPLE_ID 
 SAMPLE_GROUP_ID
 LIMS_ID
 FASTQ_PREFIX
 SS_SAMPLE_NAME 
 SS_SAMPLE_ID  
 SS_SAMPLE_PLATE  
 SS_SAMPLE_WELL 
 SS_I7_INDEX_ID
 SS_INDEX 
 SS_SAMPLE_PROJECT
 SS_DESCRIPTION
 SS_ORDER
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $sg = new Pfizer::FastQC::Sample(); 
 Function: Returns a bare-bones Sample object
 Returns : a new Sample object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $sg->name;
 Function: Gets user name corresponding to this Sample
 Returns : user name

=cut

sub sample_name {
    my $self = shift;
    return $self->{'SS_SAMPLE_NAME'};
}    

sub set_sample_name {
    my $self = shift;
    my $un = shift;
    $self->{'SS_SAMPLE_NAME'} = $un;
}    

=head2 id

 Title   : id
 Usage   :  $sg->id;
 Function: Gets ID of this Sample
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'SAMPLE_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $sg->set_id;
 Function: Sets ID of this Sample
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'SAMPLE_ID'} = $id;
}    

sub lims_id {
    my $self = shift;
    return $self->{'LIMS_ID'};
}

sub sample_group_id {
    my $self = shift;
    return $self->{'SAMPLE_GROUP_ID'};
}    
sub set_sample_group_id {
    my $self = shift;
    my $id = shift;
    $self->{'SAMPLE_GROUP_ID'} = $id;
}    

sub sample_plate {
    my $self = shift;
    return $self->{'SS_SAMPLE_PLATE'};
}    
sub set_sample_plate {
    my $self = shift;
    my $id = shift;
    $self->{'SS_SAMPLE_PLATE'} = $id;
}

sub sample_well {
    my $self = shift;
    return $self->{'SS_SAMPLE_WELL'};
}    
sub set_sample_well {
    my $self = shift;
    my $id = shift;
    $self->{'SS_SAMPLE_WELL'} = $id;
}

sub i7_index_id {
    my $self = shift;
    return $self->{'SS_I7_INDEX_ID'};
}    
sub set_i7_index_id {
    my $self = shift;
    my $id = shift;
    $self->{'SS_I7_INDEX_ID'} = $id;
}

sub index {
    my $self = shift;
    return $self->{'SS_INDEX'};
}    
sub set_index {
    my $self = shift;
    my $id = shift;
    $self->{'SS_INDEX'} = $id;
}

sub sample_project {
    my $self = shift;
    return $self->{'SS_SAMPLE_PROJECT'};
}    
sub set_sample_project {
    my $self = shift;
    my $id = shift;
    $self->{'SS_SAMPLE_PROJECT'} = $id;
}

sub description {
    my $self = shift;
    return $self->{'SS_DESCRIPTION'};
}    
sub set_description {
    my $self = shift;
    my $id = shift;
    $self->{'SS_DESCRIPTION'} = $id;
}

sub sample_id {
    my $self = shift;
    return $self->{'SS_SAMPLE_ID'};
}    
sub set_sample_id {
    my $self = shift;
    my $id = shift;
    $self->{'SS_SAMPLE_ID'} = $id;
}

sub order {
    my $self = shift;
    return $self->{'SS_ORDER'};
}    
sub set_order {
    my $self = shift;
    my $id = shift;
    $self->{'SS_ORDER'} = $id;
}

sub fastq_name_for_read {
    my $self = shift;
    my $read = shift;
    my $sample_prefix;
    if (defined($self->sample_name) && $self->sample_name ne '') {
	($sample_prefix = $self->sample_name) =~ s/_/-/g;
    } else {
	$sample_prefix = $self->sample_id;
    }
    sprintf("%s_S%d_R%d_001.fastq.gz", 
	    $sample_prefix,
	    $self->order,
	    $read);
}

sub register {
    my $self = shift;
    my $sample_group_id = shift;
    $self->set_sample_group_id($sample_group_id);
    unless ($self->insert) {
	confess "failed to insert Sample with sample_group_id = $sample_group_id";
    }
    return 1;
}

sub insertSamples {
    my $type = shift;
    my $sg = shift;
    my $ss = shift;
    my $nsamp = @{$ss->samples};
    my @samps;
    my @sattrib;
    foreach my $is (0..$nsamp-1) {
	my $samp = $ss->samples->[$is];
	$samp->set_sample_group_id($sg->id);
	if ($samp->insert) {
	    protlog($LOG_FH, "inserted Sample ID = " . $samp->id . " for sample group ID = " . $sg->id);
	} else { 
	    confess "failed to insert Sample";
	}
	push @samps, $samp;
	my $sas = $ss->sample_attrib->[$is];
	foreach my $ia (0..@$sas-1) {
	    my $sa = $sas->[$ia];
	    $sa->set_sample_id($samp->id);
	    if ($sa->insert) {
		protlog($LOG_FH, "inserted SampleAttrib ID = " . $sa->id . " for sample ID = " . $samp->id . sprintf(" [%s => %s]", $sa->name || '', $sa->value || ''));
	    } else { 
		confess "failed to insert SampleAttrib for Sample ID " . $samp->id;
	    }
	}
	push @sattrib, $sas;
    }
    return ([@samps], [@sattrib]);
}

1;
