package Pfizer::FastQC::SampleSheet;

=head1 NAME

Pfizer::FastQC::SampleSheet

=head1 SYNOPSIS

    use Pfizer::FastQC::SampleSheet;
    my $ss = new Pfizer::FastQC::SampleSheet();

=head1 DESCRIPTION

A SampleSheet object represents one group of samples that have 
been sequenced and parameters of the NextSeq500 for the run. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(parseSampleSheet validate_sample_name supportText recipient_list);
use Wyeth::Util::Utils qw(protlog sendmail);
use Pfizer::FastQC::Sample;
use Pfizer::FastQC::SampleAttrib;
use Digest::file qw(digest_file_hex);
use Data::Dumper;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $ss = new Pfizer::FastQC::SampleSheet(); 
 Function: Returns a bare-bones SampleSheet object
 Returns : a new SampleSheet object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    my $href;
    if (@args) {
	if (-e $args[0]) {
	    $href = parseSampleSheet($args[0]);
	} else {
	    confess "error: cannot parse file '$args[0]'";
	}
    } else {
	confess "you must specify a SampleSheet.csv file";
    }
    $self->{'FILENAME'} = $args[0];
    $self->{'CHECKSUM'}  = digest_file_hex( $self->{'FILENAME'}, "MD5");
    my $oref = _parsed2objs($href);
    $self->{'SAMPLES'} = $oref->{'samples'};
    $self->{'SAMPLE_ATTRIB'} = $oref->{'sample_attrib'};
    $self->{'PARAMS'} = $oref->{'params'};
    $self->{'READS'} = [ map { $_->[0]} @{$oref->{'reads'}} ];
    return bless $self, $type;
}

=head2 _parsed2objs

 Title   :  _parsed2objs
 Usage   : 
  Function: 
 Returns : Convenience object to convert parsed sample sheet to SampleSheet object

=cut

sub _parsed2objs {
    my $href = shift;
    my $saref = $href->{'Data'};
    my @samples;
    my %seenSampleName;
    my $k = 1;
    # print Dumper $href;
    my $headref = $saref->[0];
    my $ncols = @$headref;
    my @sample_attrib;
    foreach my $i (1..(scalar(@$saref)-1)) {
	if (!defined($seenSampleName{$saref->[$i]->[1]})) {
	    $seenSampleName{$saref->[$i]->[1]}++;
	    my $s = new Pfizer::FastQC::Sample;
	    $s->set_sample_id($saref->[$i]->[0]);
	    $s->set_sample_name($saref->[$i]->[1]);
	    $s->set_sample_plate($saref->[$i]->[2]);
	    $s->set_sample_well($saref->[$i]->[3]);
	    $s->set_i7_index_id($saref->[$i]->[4]);
	    $s->set_index($saref->[$i]->[5]);
	    # TODO: bug: for dual index, project is in col 8, description in 9
	    $s->set_sample_project($saref->[$i]->[6]);
	    $s->set_description($saref->[$i]->[7]);
	    $s->set_order($k++);
	    push @samples, $s;
	    # Sample attributes:
	    my @sas;
	    foreach my $j (6..$ncols) {
		if ($headref->[$j] && $headref->[$j] ne '') {
		    my $sa = new Pfizer::FastQC::SampleAttrib();
		    $sa->set_name($headref->[$j]);
		    $sa->set_value($saref->[$i]->[$j]);
		    push @sas, $sa;
		}
	    }
	    push @sample_attrib, [@sas];
	} else {
	    warn("Sample name '" . $saref->[$i]->[1] . "' is duplicated in sample sheet: skipping repeated records");
	}
    }
    unless (@samples == @sample_attrib) {
	confess "Number of samples " . scalar(@samples) . " does not match length of sample attrib vector " . scalar(@sample_attrib) . "\n";
    }
    my $pref = {};
    my @keys = qw(Settings Header);
    foreach my $k (@keys) {
	my $aref = $href->{$k};
	foreach my $el (@$aref) {
	    $pref->{$k}->{uc($el->[0])} = $el->[1]
	}
    }
    my $ret = { 
	'samples' => [@samples],
	'params' => $pref,
	'reads' => $href->{'Reads'},
	'sample_attrib' => [@sample_attrib]
    };
    $ret;
}

=head2 name

 Title   : name
 Usage   :  $ss->name;
 Function: Gets user name corresponding to this SampleSheet
 Returns : user name

=cut

sub filename {
    my $self = shift;
    return $self->{'FILENAME'};
}    

sub set_filename {
    my $self = shift;
    my $un = shift;
    $self->{'FILENAME'} = $un;
}    

sub params {
    my $self = shift;
    return $self->{'PARAMS'};
}

sub set_params {
    my $self = shift;
    my $p = shift;
    $self->{'PARAMS'} = $p;
}

sub reads {
    my $self = shift;
    my $p = shift;
    $self->{'READS'};
}

sub num_reads {
    my $self = shift;
    scalar(@{$self->{'READS'}});
}

sub samples {
    my $self = shift;
    return $self->{'SAMPLES'};
}    

sub set_samples {
    my $self = shift;
    my $un = shift;
    $self->{'SAMPLES'} = $un;
}

sub sample_attrib {
    my $self = shift;
    return $self->{'SAMPLE_ATTRIB'};
}


=head2 checksum

 Title   : checksum
 Usage   :  $ss->checksum;
 Function: Gets CHECKSUM of this SampleSheet
 Returns : object CHECKSUM

=cut

sub checksum {
    my $self = shift;
    return $self->{'CHECKSUM'};
}    

=head2 set_checksum

 Title   : set_checksum
 Usage   :  $ss->set_checksum;
 Function: Sets CHECKSUM of this SampleSheet
 Returns : object CHECKSUM

=cut

sub set_checksum {
    my $self = shift;
    my $checksum = shift;
    $self->{'CHECKSUM'} = $checksum;
}    

sub trim_step {
    my $self = shift;
    my $step = shift;
    my $tstep = $self->params->{'Header'}->{sprintf("TRIM_STEP%02d", $step)} ||
	$Pfizer::FastQC::Config::DEFAULT_STEP[$step-1];
}

sub email {
    my $self = shift;
    $self->params->{'Header'}->{'EMAIL'} ||  $Pfizer::FastQC::Config::ADMIN_EMAIL;
}

sub do_read_clean {
    my $self = shift;
     $self->params->{'Header'}->{'DOREADCLEANING'} || $Pfizer::FastQC::Config::DO_READCLEAN_DEFAULT;
}

sub validate_sample_names {
    my $self = shift;
    my @failing_names = ();
    foreach my $samp (@{$self->samples}) {
	my $name = $samp->sample_name;
	if (!validate_sample_name($samp->sample_name)) {
	    push @failing_names, $samp->sample_name;
	}
    }
    @failing_names;
}

sub sendBadNamesMsg {
    my $self = shift;
    my $bnames = shift;
    my $msg = $self->badNamesMsg;
    protlog($LOG_FH, $self->badNamesMsg);
    my $bcl_dir_name;
    ($bcl_dir_name) = $self->filename =~ m/$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR\/([^\/]+)/;
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($self->email),
	     "Validation errror for BCL directory $bcl_dir_name",
	     $self->badNamesMsg($bnames));
}

sub badNamesMsg {
    my $self = shift;
    my $bnameref = shift;
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    my $bcl_dir_name;
    ($bcl_dir_name) = $self->filename =~ m/$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR\/([^\/]+)/;
    my $nice_bad_chars =  $Pfizer::FastQC::Config::BAD_CHARS;
    $nice_bad_chars =~ s/\\//g;
    $msg .= "FastQC User,\n" . 
		"<p>Your Sample sheet in directory <strong>$bcl_dir_name</strong>" . 
		" includes either missing sample names or sample names with illegal characters.  " .  
		"Please do not include any of following characters in your sample names: " .
		"<p><strong> " . $nice_bad_chars . " (this includes space characters/empty sample names)</strong></p>";
    $msg .= "<p>The following sample names contained illegal characters: <ul>";
    foreach my $bn (@$bnameref) {
	$msg .= "<li> $bn </li>";
    }
    $msg .= "</ul>";
    $msg .= "<p>The safest approach is to include only letters, numbers, underscores, or dashes in your sample names.</p>";
    $msg .= "<p> Please correct the sample names listed above, and then re-save your sample sheet to re-trigger processing</p>";
    $msg .= "<br/><hr/>" . supportText();
    $msg .= "</body></html>";
    $msg;
}

1;
