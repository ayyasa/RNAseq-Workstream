package Pfizer::FastQC::SampleGroup;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::SampleGroup

=head1 SYNOPSIS

    use Pfizer::FastQC::SampleGroup;
    my $sg = new Pfizer::FastQC::SampleGroup("myrawfile.RAW");

 
=head1 DESCRIPTION

A SampleGroup object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Data::Dumper;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::RawFastqFileFactory;
use Pfizer::FastQC::SampleSheet;
use Pfizer::FastQC::SampleFactory;
use Wyeth::Util::Utils qw(protlog);
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( SAMPLE_GROUP_ID 
 BCL_DIRECTORY_ID
 NAME
 USERNAME 
 SAMPLESHEET_CHECKSUM 
 DO_READCLEAN
 NUM_READS
 DATE_MODIFIED
);


=head1 METHODS

=head2 new

 Title   : new
 Usage   : $sg = new Pfizer::FastQC::SampleGroup(); 
 Function: Returns a bare-bones SampleGroup object
 Returns : a new SampleGroup object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 userName

 Title   : userName
 Usage   :  $sg->userName;
 Function: Gets user name corresponding to this SampleGroup
 Returns : user name

=cut

sub userName {
    my $self = shift;
    return $self->{'USERNAME'};
}    

sub set_userName {
    my $self = shift;
    my $un = shift;
    $self->{'USERNAME'} = $un;
}    

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
 Usage   :  $sg->id;
 Function: Gets ID of this SampleGroup
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'SAMPLE_GROUP_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $sg->set_id;
 Function: Sets ID of this SampleGroup
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'SAMPLE_GROUP_ID'} = $id;
}    

sub do_readclean {
    my $self = shift;
    return  $self->{'DO_READCLEAN'};
}

sub set_do_readclean {
    my $self = shift;
    my $rc = shift;
    $self->{'DO_READCLEAN'} = $rc;
}

=head2 checksum

 Title   : checksum
 Usage   :  $sg->checksum;
 Function: Gets CHECKSUM of this SampleGroup
 Returns : object CHECKSUM

=cut

sub checksum {
    my $self = shift;
    return $self->{'SAMPLESHEET_CHECKSUM'};
}    

=head2 set_checksum

 Title   : set_checksum
 Usage   : $sg->set_checksum;
 Function: Sets CHECKSUM of this SampleGroup
 Returns : 

=cut

sub set_checksum {
    my $self = shift;
    my $checksum = shift;
    $self->{SAMPLESHEET_CHECKSUM} = $checksum;
}    

=head2 bcl_directory_id

 Title   : bcl_directory_id
 Usage   :  $bd->bcl_directory_id;
 Function: Gets BCL_DIRECTORY_ID of this BCLDirectory
 Returns : object BCL_DIRECTORY_ID

=cut

sub bcl_directory_id {
    my $self = shift;
    return $self->{'BCL_DIRECTORY_ID'};
}    

=head2 set_bcl_directory_id

 Title   : set_bcl_directory_id
 Usage   :  $bd->set_bcl_directory_id;
 Function: Sets BCL_DIRECTORY_ID of this BCLDirectory
 Returns : object BCL_DIRECTORY_ID

=cut

sub set_bcl_directory_id {
    my $self = shift;
    my $bcl_directory_id = shift;
    $self->{'BCL_DIRECTORY_ID'} = $bcl_directory_id;
}    

sub set_num_reads {
    my $self = shift;
    my $num_reads = shift;
    $self->{'NUM_READS'} = $num_reads;
}

sub num_reads {
    my $self = shift;
    return $self->{'NUM_READS'};
}

=head2 findNewSampleSheets

 Title   : findNewSampleSheets
 Usage   : 
 Function: 
 Returns : List of SampleSheet objects

=cut


sub findNewSampleSheets {
    my $type = shift;
    my $rootdir = shift;
    my @entries = glob("$rootdir/*");
    if (! @entries) {
	warn "No BCL Directories found in $rootdir";
    }
    my @newSampleSheets;
    my @currentChecksums;
    foreach my $en (@entries) {
	if (-d $en) {
	    # protlog($LOG_FH, "entering $en...") if $VERBOSE>=2;
	    my @contents = glob("$en/*");
	    my @candidates = grep(/\/${SAMPLESHEET_FILE}$/i, @contents);
	    if (@candidates==1) {
		my $sample_csv = $candidates[0];
		# protlog($LOG_FH, "found $sample_csv") if $VERBOSE>=2;
		my $ss = new Pfizer::FastQC::SampleSheet($sample_csv);
		my $currChecksum = $ss->checksum;
		if (grep(/$currChecksum/, @currentChecksums)) {
		    protlog($LOG_FH, "identical samplesheet in the current batch") if $VERBOSE>=2;
		} else {
		    push @currentChecksums, $ss->checksum;
		    my @sgs = Pfizer::FastQC::SampleGroup->selectByCriteria( 
			SAMPLESHEET_CHECKSUM => join(" ", "= ", "'".$ss->checksum."'"));
		    if (@sgs) {
			# samplesheet is already known
			protlog($LOG_FH, "identical samplesheet already registered (ID=" . $sgs[0]->id . ")") 
			    if $VERBOSE>=2;
		    } elsif (grep(/$ss->checksum/, @currentChecksums)) {
			protlog($LOG_FH, "identical samplesheet in the current batch") if $VERBOSE>=2;
		    } else {
			# retain this new sampleSheet;
			protlog($LOG_FH, "samplesheet is new to the system") if $VERBOSE>=2;
			push @newSampleSheets, $ss;
		    }
		}
	    }
	}
    }
    @newSampleSheets;
}

sub samples {
    my $self = shift;
    my @samps = Pfizer::FastQC::SampleFactory->selectByCriteria(SAMPLE_GROUP_ID => "= '" . $self->id . "'");
    @samps;
}

sub toHTMLTable {
    my $self = shift;
    my @samps = $self->samples;
    my $html = "<table border=1 cellpadding='0' bgcolor='#EEEEEE'><tr>";
    my @heads = qw(NAME ID I7_INDEX_ID INDEX I5_INDEX_ID INDEX2 ORDER LIMS_ID);
    my $style = ""; # style='padding:1px 0 1px 0;'";
    foreach my $h (@heads) {
	$html .= "<th $style>$h</th>";
    }
    $html .= "</tr>";
    @samps = sort { $a->order <=> $b->order} @samps;
    foreach my $s (@samps) {
	my @sas = Pfizer::FastQC::SampleAttrib->selectByCriteria(SAMPLE_ID => "= '" . $s->id . "'");
	my %sah;
	foreach my $sa (@sas) {
	    $sah{$sa->name} = $sa->value;
	}
	$html .= "<tr>";
	$html .= "<td>" . join("</td><td>", $s->sample_name || 'NA',
			       $s->sample_id || 'NA',
			       $s->i7_index_id,
			       $s->index || 'NA',
			       $sah{'I5_Index_ID'} || 'NA',
			       $sah{'index2'} || 'NA',
			       $s->order || 'NA',
			       $s->lims_id || 'NA');
	$html .= "</td></tr>";
    }
    $html .= "</table>";
    $html;
}

sub register {
    my $self = shift;
    my ($bcl_dir_id, $name, $username, $checksum, $do_readclean, $num_reads) = @_;
    $self->set_bcl_directory_id($bcl_dir_id);
    $self->set_name($name);
    $self->set_userName($username);
    $self->set_checksum($checksum);
    $self->set_do_readclean($do_readclean);
    $self->set_num_reads($num_reads);
    unless ($self->insert) {
	confess "failed to insert SampleGroup with name '$name'";
    }
    return 1;
}

sub get_raw_fastqs {
    my $self = shift;
    my @rfqs = ();
    foreach my $s ($self->samples) {
	push @rfqs, Pfizer::FastQC::RawFastqFileFactory->selectByCriteria(SAMPLE_ID => ' = ' . $s->id);
    }
    @rfqs;
}

sub get_clean_fastqs {
    my $self = shift;
    my @rfqs = $self->get_raw_fastqs;
    my @cfqs;
    foreach my $rfq (@rfqs) {
	push @cfqs, $rfq->get_clean_fastqs;
    }
    @cfqs;
}

sub insertSampleGroup {
    my $type = shift;
    my $bd = shift; # bclDirectory
    my $ss = shift; # sampleSheet
    my $sg = new Pfizer::FastQC::SampleGroup();
    $sg->set_bcl_directory_id($bd->id);
    $sg->set_userName($ss->email);
    $sg->set_do_readclean($ss->do_read_clean);
    $sg->set_name($bd->name);
    $sg->set_checksum($ss->checksum);
    $sg->set_num_reads($ss->num_reads);
    # insert the SampleGroup
    unless ($sg->insert) {
	confess "failed to insert Sample Group";
    }
    protlog($LOG_FH, "Sample group ID=" . $sg->id . " inserted");
    $sg;
}

sub attrib_table {
    my $self = shift;
    my @samples = $self->samples;
    #my @sa;
    #my $sa = new Pfizer::SampleAttrib();
    my @recs;
    foreach my $samp (@samples) {
	my @sas = Pfizer::FastQC::SampleAttrib->selectByCriteria(SAMPLE_ID => "= '" . $samp->id . "'");
	my @rfqs = Pfizer::FastQC::RawFastqFileFactory->selectByCriteria(SAMPLE_ID => ' = ' . $samp->id);
	foreach my $rfq (@rfqs) {
	    push @recs, [( $rfq->name,
			   $samp->sample_name,
			   $samp->index
			 )];
	}
    }
    my @heads = qw(FILENAME SAMPLE_NAME INDEX);
    (\@heads, \@recs);
}

1;
