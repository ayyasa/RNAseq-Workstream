package Pfizer::FastQC::ReadCleanRun;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::ReadCleanRun

=head1 SYNOPSIS

    use Pfizer::FastQC::ReadCleanRun;
    my $rcr = new Pfizer::FastQC::ReadCleanRun();

 
=head1 DESCRIPTION

A ReadCleanRun object represents one group of samples that have 
been sequenced. 

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::RawFastqFileFactory;
use Pfizer::FastQC::CleanFastqFile;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::Utils qw(recipient_list);
use Wyeth::Util::Utils qw(protlog sendmail);
use File::Path qw(make_path);
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( READCLEAN_RUN_ID
RAW_FASTQ_FILE_1_ID
RAW_FASTQ_FILE_2_ID
CLEAN_METHOD
OUTPUT_SELECTION
PARAM01
PARAM02
PARAM03
PARAM04
PARAM05
PARAM06
PARAM07
STATUS
DATE_MODIFIED
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $rcr = new Pfizer::FastQC::ReadCleanRun(); 
 Function: Returns a bare-bones ReadCleanRun object
 Returns : a new ReadCleanRun object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    bless $self, $type;
    $self->set_clean_method('Trimmomatic');
    $self->set_param01($Pfizer::FastQC::Config::DEFAULT_STEP[0]);
    $self->set_param02($Pfizer::FastQC::Config::DEFAULT_STEP[1]);
    $self->set_param03($Pfizer::FastQC::Config::DEFAULT_STEP[2]);
    $self->set_param04($Pfizer::FastQC::Config::DEFAULT_STEP[3]);
    $self->set_param05($Pfizer::FastQC::Config::DEFAULT_STEP[4]);
    $self->set_param06($Pfizer::FastQC::Config::DEFAULT_STEP[5]);
    $self->set_param07($Pfizer::FastQC::Config::DEFAULT_STEP[6]);
    return $self;
}

=head2 raw_fastq_file_1_id

 Title   : raw_fastq_file_1_id
 Usage   :  $rcr->raw_fastq_file_1_id;
 Function: Gets user raw_fastq_file_1_id corresponding to this ReadCleanRun
 Returns : user raw_fastq_file_1_id

=cut

sub raw_fastq_file_1_id {
    my $self = shift;
    return $self->{'RAW_FASTQ_FILE_1_ID'};
}    

sub set_raw_fastq_file_1_id {
    my $self = shift;
    my $un = shift;
    $self->{'RAW_FASTQ_FILE_1_ID'} = $un;
}    

=head2 id

 Title   : id
 Usage   :  $rcr->id;
 Function: Gets ID of this ReadCleanRun
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'READCLEAN_RUN_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $rcr->set_id;
 Function: Sets ID of this ReadCleanRun
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'READCLEAN_RUN_ID'} = $id;
}    

=head2 status

 Title   : status
 Usage   :  $rcr->status;
 Function: Gets STATUS of this ReadCleanRun
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $rcr->set_status;
 Function: Sets STATUS of this ReadCleanRun
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    


=head2 clean_method

 Title   : clean_method
 Usage   :  $rcr->clean_method;
 Function: Gets CLEAN_METHOD of this ReadCleanRun
 Returns : object CLEAN_METHOD

=cut

sub clean_method {
    my $self = shift;
    return $self->{'CLEAN_METHOD'};
}    

=head2 set_clean_method

 Title   : set_clean_method
 Usage   :  $rcr->set_clean_method;
 Function: Sets CLEAN_METHOD of this ReadCleanRun
 Returns : object CLEAN_METHOD

=cut

sub set_clean_method {
    my $self = shift;
    my $clean_method = shift;
    $self->{'CLEAN_METHOD'} = $clean_method;
}    

sub output_selection {
    my $self = shift;
    return $self->{'OUTPUT_SELECTION'};
}    

sub set_output_selection {
    my $self = shift;
    my $output_selection = shift;
    $self->{'OUTPUT_SELECTION'} = $output_selection;
}    

sub param01 {
    my $self = shift;
    return $self->{'PARAM01'};
}    

sub set_param01 {
    my $self = shift;
    my $param01 = shift;
    $self->{'PARAM01'} = $param01;
}    

sub param02 {
    my $self = shift;
    return $self->{'PARAM02'};
}    

sub set_param02 {
    my $self = shift;
    my $param02 = shift;
    $self->{'PARAM02'} = $param02;
}    

sub param03 {
    my $self = shift;
    return $self->{'PARAM03'};
}    

sub set_param03 {
    my $self = shift;
    my $param03 = shift;
    $self->{'PARAM03'} = $param03;
}    

sub param04 {
    my $self = shift;
    return $self->{'PARAM04'};
}    

sub set_param04 {
    my $self = shift;
    my $param04 = shift;
    $self->{'PARAM04'} = $param04;
}    

sub param05 {
    my $self = shift;
    return $self->{'PARAM05'};
}    

sub set_param05 {
    my $self = shift;
    my $param05 = shift;
    $self->{'PARAM05'} = $param05;
}    

sub param06 {
    my $self = shift;
    return $self->{'PARAM06'};
}    

sub set_param06 {
    my $self = shift;
    my $param06 = shift;
    $self->{'PARAM06'} = $param06;
}    

sub param07 {
    my $self = shift;
    return $self->{'PARAM07'};
}    

sub set_param07 {
    my $self = shift;
    my $param07 = shift;
    $self->{'PARAM07'} = $param07;
}    

sub raw_fastq_file_2_id {
    my $self = shift;
    return $self->{'RAW_FASTQ_FILE_2_ID'};
}    

sub set_raw_fastq_file_2_id {
    my $self = shift;
    my $raw_fastq_file_2_id = shift;
    $self->{'RAW_FASTQ_FILE_2_ID'} = $raw_fastq_file_2_id;
}

=head2 run

 Title   : run
 Usage   : my $sucess = $rcr->run 
 Function:  Executes the ReadCleanRun using Trimmomatic
 Returns : 1 on success, 0 on failure

=cut
sub _out_base {
    my $self = shift;
    my $infastq1 = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_1_id);
    my $sg = $infastq1->sampleGroup; 
    my $out_base = join("/", $Pfizer::FastQC::Config::CLEAN_FASTQ_FILE_DIR,
			sprintf("%s_%05d", $sg->name, $sg->id));
    $out_base;
}

sub run {
    my $self = shift;
    # java -jar <path to trimmomatic.jar> PE 
    # [-threads <threads] [-phred33 | -phred64] [-trimlog <logFile>] 
    # <input 1> <input 2> <paired output 1> <unpaired output 1> 
    # <paired output 2> <unpaired output 2> <step 1> ... 

    my $infastq1 = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_1_id);
    $self->set_status('WOR');
    unless ($self->update) {
	confess "failed to update ReadCleanRun ID = " . $self->id;
    }
    my $msg = $self->startMessage();
    my $sg = $infastq1->sampleGroup;
    
    protlog($LOG_FH, $self->startMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     $sg->userName,
	     "Started ReadCleanRun ID = " . $self->id,
	     $self->startMessage) if $VERBOSE>=3;
    
    if (defined($self->raw_fastq_file_2_id)) {
	# 2-read case
	my $infastq2 = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_2_id);
	if ($self->clean_method eq 'Trimmomatic') {
	    unless ($self->_run_trimmomatic($infastq1, $infastq2)) {
		$self->set_status('FAI');
		unless ($self->update) {
		    confess "failed to update ReadCleanRun ID = " . $self->id;
		}
		confess "failed to _run_trimmomatic";
	    }
	} elsif ($self->clean_method eq 'None' || $self->clean_method eq 'No') {
	    unless ($self->_run_passthrough($infastq1, $infastq2)) {
		$self->set_status('FAI');
		unless ($self->update) {
		    confess "failed to update ReadCleanRun ID = " . $self->id;
		}
		confess "failed to _run_passthrough";
	    }
	} else {
	    confess "Unknown clean_method '" . $self->clean_method . "'";
	}
	$self->set_status('PAS');
	unless ($self->update) {
	    confess "failed to update ReadCleanRun ID = " . $self->id;
	}
    } else {
	# 1-read case
	if ($self->clean_method eq 'Trimmomatic') {
	    unless ($self->_run_trimmomatic1($infastq1)) {
		$self->set_status('FAI');
		unless ($self->update) {
		    confess "failed to update ReadCleanRun ID = " . $self->id;
		}
		confess "failed to _run_trimmomatic";
	    }
	} elsif ($self->clean_method eq 'None') {
	    unless ($self->_run_passthrough($infastq1)) {
		$self->set_status('FAI');
		unless ($self->update) {
		    confess "failed to update ReadCleanRun ID = " . $self->id;
		}
		confess "failed to _run_passthrough";
	    }
	} else {
	    confess "Unknown clean_method '" . $self->clean_method . "'";
	}
	$self->set_status('PAS');
	unless ($self->update) {
	    confess "failed to update ReadCleanRun ID = " . $self->id;
	}
    }
    protlog($LOG_FH, $self->completeMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     $sg->userName,
	     "Completed ReadCleanRun ID = " . $self->id,
	     $self->completeMessage) if $VERBOSE >=3;
    return 1;
} # end sub

sub _run_trimmomatic {
    my $self = shift;
    my $infastq1 = shift;
    my $infastq2 = shift;

    my $sg = $infastq1->sampleGroup;
    my $out_base = $self->_out_base;
    unless (-e $out_base) {
	unless(make_path($out_base)) {
	    confess "failed to create directory: " . $out_base;
	}
    }
    my $clean_paired_fastq_1 = join("/", $out_base, $infastq1->name);
    (my $clean_unpaired_fastq_1 = $clean_paired_fastq_1) =~ s/\.gz$/\.unpaired\.gz/;
    my $clean_paired_fastq_2 =  join("/", $out_base, $infastq2->name);
    (my $clean_unpaired_fastq_2 = $clean_paired_fastq_2) =~ s/\.gz$/\.unpaired\.gz/;

    my $threads = 4;
    my $trim_log = join("/", $out_base, "trim_" . $self->id . ".log");
    my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-K",
	       "-n 16",
	       "-J TRIM" . $self->id,
	       "-o $trim_log.out",
	       "-e $trim_log.err",
	       $Pfizer::FastQC::Config::TRIM_EXE_STUB,
	       'PE',
	       # "-threads $threads",
	       # "-phred64",
	       # "-trimlog $trim_log",
	       $infastq1->full_path,
	       $infastq2->full_path,
	       $clean_paired_fastq_1,
	       $clean_unpaired_fastq_1,
	       $clean_paired_fastq_2,
	       $clean_unpaired_fastq_2,
	       $self->param01,
	       $self->param02,
	       $self->param03,
	       $self->param04,
	       $self->param05,
	       $self->param06,
	       $self->param07);
    if ((! -e $clean_paired_fastq_1) && (! -e $clean_paired_fastq_2)) {
	protlog($LOG_FH, "Executing command: " . join(" \\\n", @cmd)) if $VERBOSE>=1;
	unless(system(join(" ", @cmd))==0) {
	    confess "failed to run command: " . join(" ", @cmd);
	}
    } else {
	protlog($LOG_FH, "Found clean fastq files already exist for ReadCleanRun ID = " . $self->id);
	protlog($LOG_FH, "Proceeding without re-generating files");
    }

   # register the output 'clean' fastq files as CleanFastqFiles
    # each linked to corresponding RawFastqFile
    if (! -e $clean_paired_fastq_1) {
	confess "failed to generate file $clean_paired_fastq_1";
    }
    my $cfq1 = new Pfizer::FastQC::CleanFastqFile();
    $cfq1->register($infastq1->id, $self->id, 1, $clean_paired_fastq_1);
    
    if (! -e $clean_paired_fastq_2) {
	confess "failed to generate file $clean_paired_fastq_1";
    }
    my $cfq2 = new Pfizer::FastQC::CleanFastqFile();
    $cfq2->register($infastq2->id, $self->id, 2, $clean_paired_fastq_2);
    return 1;
}

sub _run_trimmomatic1 {
    my $self = shift;
    my $infastq1 = shift;

    my $sg = $infastq1->sampleGroup;
    my $out_base = $self->_out_base;
    unless (-e $out_base) {
	unless(make_path($out_base)) {
	    confess "failed to create directory: " . $out_base;
	}
    }
    my $clean_paired_fastq_1 = join("/", $out_base, $infastq1->name);
    (my $clean_unpaired_fastq_1 = $clean_paired_fastq_1) =~ s/\.gz$/\.unpaired\.gz/;

    my $threads = 4;
    my $trim_log = join("/", $out_base, "trim_" . $self->id . ".log");
    my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-K",
	       "-n 16",
	       "-J TRIM" . $self->id,
	       "-o $trim_log.out",
	       "-e $trim_log.err",
	       $Pfizer::FastQC::Config::TRIM_EXE_STUB,
	       'SE',
	       # "-threads $threads",
	       # "-phred64",
	       # "-trimlog $trim_log",
	       $infastq1->full_path,
	       $clean_paired_fastq_1,
	       $self->param01,
	       $self->param02,
	       $self->param03,
	       $self->param04,
	       $self->param05,
	       $self->param06,
	       $self->param07);
    if ((! -e $clean_paired_fastq_1)) {
	protlog($LOG_FH, "Executing command: " . join(" \\\n", @cmd)) if $VERBOSE>=1;
	unless(system(join(" ", @cmd))==0) {
	    confess "failed to run command: " . join(" ", @cmd);
	}
    } else {
	protlog($LOG_FH, "Found clean fastq file already exists for ReadCleanRun ID = " . $self->id);
	protlog($LOG_FH, "Proceeding without re-generating file");
    }

   # register the output 'clean' fastq files as CleanFastqFiles
    # each linked to corresponding RawFastqFile
    if (! -e $clean_paired_fastq_1) {
	confess "failed to generate file $clean_paired_fastq_1";
    }
    my $cfq1 = new Pfizer::FastQC::CleanFastqFile();
    $cfq1->set_raw_fastq_file_id($infastq1->id);
    $cfq1->set_readclean_run_id($self->id);
    $cfq1->set_read_number(1);
    $cfq1->set_type('CLEAN');
    $cfq1->set_path($out_base);
    $cfq1->set_name($clean_paired_fastq_1);
    $cfq1->set_status('PAS');
    unless ($cfq1->insert) {
	confess "failed to insert CleanFastqFile for ReadCleanRun ID = " . $self->id;
    }
    return 1;
}

sub _run_passthrough {
    my $self = shift;
    my $infastq1 = shift;
    my $infastq2 = shift;
    my $sg = $infastq1->sampleGroup;
    my $out_base = $self->_out_base;
    unless (-e $out_base) {
	unless(make_path($out_base)) {
	    confess "failed to create directory: " . $out_base;
	}
    }
    # First read
    my $clean_paired_fastq_1 = join("/", $out_base, $infastq1->name);
    # Create symlinks raw_fastq <- clean_fastq
    my $symlink_exists = eval { symlink("",""); 1 };
    unless (symlink($infastq1->full_path, $clean_paired_fastq_1)) {
	confess "failed to symlink for CleanFastqFile $clean_paired_fastq_1";
    }
    # Register the symlink as new CleanFastqFile
    if (! -e $clean_paired_fastq_1) {
	confess "failed to generate file $clean_paired_fastq_1";
    }
    my $cfq1 = new Pfizer::FastQC::CleanFastqFile();
    $cfq1->register($infastq1->id, $self->id, 1, $clean_paired_fastq_1);

    if (defined($infastq2)) {
	# two-read case
	my $clean_paired_fastq_2 =  join("/", $out_base, $infastq2->name);
	unless (symlink($infastq2->full_path, $clean_paired_fastq_2)) {
	    confess "failed to symlink for CleanFastqFile $clean_paired_fastq_2";
	}
	if (! -e $clean_paired_fastq_2) {
	    confess "failed to generate file $clean_paired_fastq_1";
	}
	my $cfq2 = new Pfizer::FastQC::CleanFastqFile();
	$cfq2->register($infastq2->id, $self->id, 2, $clean_paired_fastq_2);
    }
    return 1;
}

sub startMessage {
    my $self = shift;
    my $infastq1 = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_1_id);
    my $infastq2 = undef;
    if (defined($self->raw_fastq_file_2_id)) {
	$infastq2 = Pfizer::FastQC::RawFastqFileFactory->select($self->raw_fastq_file_2_id);
    }
    my $msg = "FastQC User,\n" . 
		"<p>Your Read Cleaning run (ID = <strong>" . 
		$self->id . "</strong>) has been queued, using the <strong>" . $self->clean_method . "</strong> method.  " . 
		" <p> The input .fastq.gz files for this run are:" .
		" <br/><strong>" . $infastq1->full_path . "</strong>";
    if (defined($infastq2)) {
	$msg .= 
	    "<br/><strong>" . $infastq2->full_path . "</strong>";
    }
    $msg .= "<br/>" .
		"<hr/>" . 
		"<p>For help, contact <strong>$Pfizer::FastQC::Config::ADMIN_EMAIL<strong>";
     $msg;
}

sub completeMessage {
    my $self = shift;
     my $msg = "FastQC User,\n" . 
		"<p>Your Read Cleaning run (ID = <strong>" . $self->id . "</strong>)" . 
		" is complete.  Your trimmed .fastq.gz files are in the directory: " . 
		"<br/><strong>" . $self->_out_base .
		"</strong>.<br/>" .
		"<hr/>" . 
		"<p>For help, contact <strong>$Pfizer::FastQC::Config::ADMIN_EMAIL<strong>";
     $msg;
}

sub register_passthrough {
    my $self = shift;
    my $raw_fastq_file_id = shift;
    $self->set_raw_fastq_file_1_id($raw_fastq_file_id);
    $self->set_clean_method('None');
    $self->set_status('PAS');
    unless ($self->insert) {
	confess "failed to insert ReadCleanRun";
    }
    return(1);
}

sub run_for_sample_group {
    my $type = shift;
    my $sg = shift;
    my $rcr_method = shift;
    my $ss = shift;
    
    my @rcrs;
    my @samps = Pfizer::FastQC::SampleFactory->selectByCriteria(SAMPLE_GROUP_ID => ' = ' . $sg->id);
    unless (@samps) {
	confess "failed to look up samples for SampleGroup ID = " . $sg->id;
    }
    my $rfq = new Pfizer::FastQC::RawFastqFile();
    foreach my $samp (@samps) {
	my $rcr = new Pfizer::FastQC::ReadCleanRun();

	if ($rfq = Pfizer::FastQC::RawFastqFile->select_by_sample_read($samp->id, 1)) {
	    $rcr->set_raw_fastq_file_1_id($rfq->id);
	} else {
	    confess "failed to find RawFastqFile for Read 1, Sample ID = " . $samp->id;
	}
	if ($sg->num_reads > 1) {
	    if ($rfq =  Pfizer::FastQC::RawFastqFile->select_by_sample_read($samp->id, 2)) {
		$rcr->set_raw_fastq_file_2_id($rfq->id);
	    } else {
		confess "failed to find RawFastqFile for Read 2, Sample ID = " . $samp->id;
	    }
	}
	$rcr->set_clean_method($rcr_method);
	if ($rcr_method eq 'Trimmomatic') {
	    $rcr->set_param01($ss->trim_step(1));
	    $rcr->set_param02($ss->trim_step(2));
	    $rcr->set_param03($ss->trim_step(3));
	    $rcr->set_param04($ss->trim_step(4));
	    $rcr->set_param05($ss->trim_step(5));
	    $rcr->set_param06($ss->trim_step(6));
	    $rcr->set_param07($ss->trim_step(7));
	}
	$rcr->set_status('PEN');
	unless ($rcr->insert) {
	    confess "Failed to insert ReadCleanRun";
	}
	unless ($rcr->run) {
	    confess "failed to run ReadCleanRun ID = " . $rcr->id;
	}
	push @rcrs, $rcr;
    } # end all samples
    return @rcrs;    
}

1;
