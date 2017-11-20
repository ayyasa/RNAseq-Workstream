package Pfizer::FastQC::BCL2FastqRun;
use base qw(Wyeth::DB::Persistable);

=head1 NAME

Pfizer::FastQC::BCL2FastqRun

=head1 SYNOPSIS

    use Pfizer::FastQC::BCL2FastqRun;
    my $b2f = new Pfizer::FastQC::BCL2FastqRun();

 
=head1 DESCRIPTION

A BCL2FastqRun object represents one process that converts
BCL directory to a set of corresponding FASTQ files.

=head1 AUTHOR

Andrew Hill, Pfizer.

=cut

use Carp;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(supportText recipient_list renewCredentials);
use Pfizer::FastQC::BCLDirectoryFactory;
use Pfizer::FastQC::SampleGroupFactory;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::RawFastqFile;
use Wyeth::Util::Utils qw(protlog sendmail);
use File::Path qw(make_path);
use Data::Dumper;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

our @FIELDS = qw( BCL2FASTQ_RUN_ID
BCL_DIRECTORY_ID 
OUTPUT_DIR
LOADING_THREADS
DEMULTX_THREADS
PROC_THREADS
WRITE_THREADS
STATUS
COMMAND
DATE_MODIFIED
);

=head1 METHODS

=head2 new

 Title   : new
 Usage   : $b2f = new Pfizer::FastQC::BCL2FastqRun(); 
 Function: Returns a bare-bones BCL2FastqRun object
 Returns : a new BCL2FastqRun object

=cut

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 name

 Title   : name
 Usage   :  $b2f->name;
 Function: Gets user name corresponding to this BCL2FastqRun
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
 Usage   :  $b2f->id;
 Function: Gets ID of this BCL2FastqRun
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'BCL2FASTQ_RUN_ID'};
}    

=head2 set_id

 Title   : set_id
 Usage   :  $b2f->set_id;
 Function: Sets ID of this BCL2FastqRun
 Returns : object ID

=cut

sub set_id {
    my $self = shift;
    my $id = shift;
    $self->{'BCL2FASTQ_RUN_ID'} = $id;
}    

sub bcl_directory_id {
    my $self = shift;
    return $self->{'BCL_DIRECTORY_ID'};
}    

sub set_bcl_directory_id {
    my $self = shift;
    my $id = shift;
    $self->{'BCL_DIRECTORY_ID'} = $id;
}    

=head2 output_dir

 Title   : output_dir
 Usage   :  $b2f->output_dir;
 Function: Gets OUTPUT_DIR of this BCL2FastqRun
 Returns : object OUTPUT_DIR

=cut

sub output_dir {
    my $self = shift;
    return $self->{'OUTPUT_DIR'};
}    

=head2 set_output_dir

 Title   : set_output_dir
 Usage   :  $b2f->set_output_dir;
 Function: Sets OUTPUT_DIR of this BCL2FastqRun
 Returns : object OUTPUT_DIR

=cut

sub set_output_dir {
    my $self = shift;
    my $output_dir = shift;
    $self->{'OUTPUT_DIR'} = $output_dir;
}

=head2 loading_threads

 Title   : loading_threads
 Usage   :  $b2f->loading_threads;
 Function: Gets LOADING_THREADS of this BCL2FastqRun
 Returns : object LOADING_THREADS

=cut

sub loading_threads {
    my $self = shift;
    return $self->{'LOADING_THREADS'};
}    

=head2 set_loading_threads

 Title   : set_loading_threads
 Usage   :  $b2f->set_loading_threads;
 Function: Sets LOADING_THREADS of this BCL2FastqRun
 Returns : object LOADING_THREADS

=cut

sub set_loading_threads {
    my $self = shift;
    my $loading_threads = shift;
    $self->{'LOADING_THREADS'} = $loading_threads;
}    

=head2 demultx_threads

 Title   : demultx_threads
 Usage   :  $b2f->demultx_threads;
 Function: Gets DEMULTX_THREADS of this BCL2FastqRun
 Returns : object DEMULTX_THREADS

=cut

sub demultx_threads {
    my $self = shift;
    return $self->{'DEMULTX_THREADS'};
}    

=head2 set_demultx_threads

 Title   : set_demultx_threads
 Usage   :  $b2f->set_demultx_threads;
 Function: Sets DEMULTX_THREADS of this BCL2FastqRun
 Returns : object DEMULTX_THREADS

=cut

sub set_demultx_threads {
    my $self = shift;
    my $demultx_threads = shift;
    $self->{'DEMULTX_THREADS'} = $demultx_threads;
}    

=head2 proc_threads

 Title   : proc_threads
 Usage   :  $b2f->proc_threads;
 Function: Gets PROC_THREADS of this BCL2FastqRun
 Returns : object PROC_THREADS

=cut

sub proc_threads {
    my $self = shift;
    return $self->{'PROC_THREADS'};
}    

=head2 set_proc_threads

 Title   : set_proc_threads
 Usage   :  $b2f->set_proc_threads;
 Function: Sets PROC_THREADS of this BCL2FastqRun
 Returns : object PROC_THREADS

=cut

sub set_proc_threads {
    my $self = shift;
    my $proc_threads = shift;
    $self->{'PROC_THREADS'} = $proc_threads;
}    

=head2 write_threads

 Title   : write_threads
 Usage   :  $b2f->write_threads;
 Function: Gets WRITE_THREADS of this BCL2FastqRun
 Returns : object WRITE_THREADS

=cut

sub write_threads {
    my $self = shift;
    return $self->{'WRITE_THREADS'};
}    

=head2 set_write_threads

 Title   : set_write_threads
 Usage   :  $b2f->set_write_threads;
 Function: Sets WRITE_THREADS of this BCL2FastqRun
 Returns : object WRITE_THREADS

=cut

sub set_write_threads {
    my $self = shift;
    my $write_threads = shift;
    $self->{'WRITE_THREADS'} = $write_threads;
}    

=head2 status

 Title   : status
 Usage   :  $b2f->status;
 Function: Gets STATUS of this BCL2FastqRun
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $b2f->set_status;
 Function: Sets STATUS of this BCL2FastqRun
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    

=head2 command

 Title   : command
 Usage   :  $b2f->command;
 Function: Gets COMMAND of this BCL2FastqRun
 Returns : object COMMAND

=cut

sub command {
    my $self = shift;
    return $self->{'COMMAND'};
}    

=head2 set_command

 Title   : set_command
 Usage   :  $b2f->set_command;
 Function: Sets COMMAND of this BCL2FastqRun
 Returns : object COMMAND

=cut

sub set_command {
    my $self = shift;
    my $command = shift;
    $self->{'COMMAND'} = $command;
}    

=head2 run

 Title   : run
 Usage   : 
  Function: 
 Returns : 

=cut

sub run {
    my $self = shift;
    my $bd = Pfizer::FastQC::BCLDirectoryFactory->select($self->bcl_directory_id);
    my $blog = join("/", $self->output_dir, $self->id . ".out");
    my $berr = join("/", $self->output_dir, $self->id . ".err");
    my $threads = $self->loading_threads + $self->demultx_threads + $self->proc_threads + $self->write_threads;
    my $escaped_path = $bd->path;
    $escaped_path =~ s/([\' ])/\\$1/g;
    my @base_command = ($Pfizer::FastQC::Config::BSUB_CMD,
		   "-K", "-n $threads", "-o $blog", "-e $berr", $Pfizer::FastQC::Config::B2Q_EXE, 
			"--runfolder-dir \"" . $escaped_path . "\"");
    my @b2f_cmd = (@base_command, 
		   "--output-dir " . $self->output_dir,
		   "--loading-threads " . $self->loading_threads,
		   "--demultiplexing-threads " . $self->demultx_threads,
		   "--processing-threads " . $self->proc_threads,
		   "--writing-threads " . $self->write_threads);
    $self->set_command(join(" ", @base_command));
    # begin work
    $self->set_update_status('WOR');
    unless (-e $self->output_dir) {
       	   unless(make_path($self->output_dir)) {
	       $self->set_update_status('FAI');
	       warn("failed to create directory: " . $self->output_dir);
	       return 0;
	   }
    }
    protlog($LOG_FH, "will execute command:\n" . join("\n", @b2f_cmd)) if $VERBOSE>=1;
   unless (system(join(" ", @b2f_cmd))==0) {
 	$self->set_update_status('FAI');
  	warn("failed to run command: " . join("\n", @b2f_cmd));
	return(0);
    }

    protlog($LOG_FH, "BCL2Fastq run complete") if $VERBOSE>=1;

    my @raw_fastqs = ();
    unless(renewCredentials($Pfizer::FastQC::Config::PROCESS_USER, $Pfizer::FastQC::Config::KEYTAB_FILE)) {
    	$self->set_update_status('FAI');
    	warn "failed to renew credentials";
    	return(0);
  }
    unless ($self->concat_lane_fastq) {
	$self->set_update_status('FAI');
	warn "failed to run concat_lane_fastq";
	return @raw_fastqs;
    }

    # insert the resulting raw fastq files
    @raw_fastqs = $self->_insertFastqs();
    unless (@raw_fastqs && $raw_fastqs[0] != 0) {
	$self->set_update_status('FAI');
	warn "failed to run concat_lane_fastq";
	return 0;
    }
    # run complete
    $self->set_update_status('PAS');
    return @raw_fastqs;
}

sub sendStartMessage {
    my $self = shift;
    my $msg = $self->startMessage;
    my $bd = new Pfizer::FastQC::BCLDirectory();
    unless ($bd->select($self->bcl_directory_id)) {
	confess "cannot select bcl directory id = " . $self->bcl_directory_id;
    }
    my $sg = $self->getSampleGroup;
    protlog($LOG_FH, $self->startMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($sg->userName),
	     "Started fastq extraction for BCL directory " . $bd->name,
	     $self->startMessage);
}

sub startMessage {
    my $self = shift;
    my $bname = Pfizer::FastQC::BCLDirectoryFactory->select($self->bcl_directory_id)->name;
    my $sg = $self->getSampleGroup;
    my $num_samples = scalar($sg->samples);
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    $msg .= "FastQC User,\n" . 
		"<p>Your BCL Directory <strong>" . 
		$bname . "</strong> has been queued for FASTQC analysis (ID = <strong>" .
		$self->id .
		"</strong>).</p>" .
		"<p>You will be notified again when the QC report is ready.  Typical run times are about 2 hours.</p>";
    $msg .= "<p>The number of reads for this directory is <strong>" . $sg->num_reads . "</strong>.</p>";
    $msg .= "<p>The table below shows the $num_samples sample-runs in this directory.</p>";
    $msg .= "<p>" . $sg->toHTMLTable . "</p>";
    $msg .= "<br/><hr/>" . supportText();
    $msg .= "</body></html>";
    $msg;
}

sub completeMessage {
    my $self = shift;
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    $msg .= "FastQC User,\n" . 
		"<p>Your BCL Directory extraction (ID = <strong>" . $self->id . "</strong>) to .fastq.gz files has completed succesfully. " . 
		"Your .fastq.gz files are in the directory: <br/><strong>" . $self->output_dir .
		"</strong>.<br/>" .
		"<hr/>" . 
		supportText(); 
    $msg .= "</body></html>";
    $msg;
}

sub sendCompleteMessage {
    my $self = shift;
    my $msg = $self->completeMessage();
    my $bd = new Pfizer::FastQC::BCLDirectory();
    unless ($bd->select($self->bcl_directory_id)) {
	confess "cannot select bcl directory id = " . $self->bcl_directory_id;
    }
    my $sg = $self->getSampleGroup;
    protlog($LOG_FH, $self ->completeMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($sg->userName),
	     "Completed fastq extraction for BCL directory " . $bd->name,
	     $self->completeMessage);
}

sub _insertFastqs {
    my $self = shift;
    my @samps = $self->getSamples;
    @samps = sort { $a->order <=> $b->order } @samps;
    my @fastqs;
    my $i =1;
    foreach my $s (@samps) {
	foreach my $read (1..$self->num_reads) {
	    my $fqo = new Pfizer::FastQC::RawFastqFile();
	    unless ($fqo->register($self->id, $s->id, $read, 
				   join("/", $self->output_dir, $self->_sr2name($s, $read)))) {
		warn "failed to register RawFastqFile for BCL2FastqRun ID = " . $self->id;
		return 0;
	    }
	    push @fastqs, $fqo;
	}
    }
    @fastqs;
}

sub getSamples {
    my $self = shift;
    my @sg = $self->getSampleGroup;
    my @samps = Pfizer::FastQC::SampleFactory->selectByCriteria(SAMPLE_GROUP_ID => "= '" . $sg[0]->id . "'");
    @samps;
}

sub num_reads {
    my $self = shift;
    my @sg = $self->getSampleGroup;
    $sg[0]->num_reads;
}

sub getSampleGroup {
    my $self = shift;
     my $bd = new Pfizer::FastQC::BCLDirectory();
    unless ($bd->select($self->bcl_directory_id)) {
	confess "cannot select bcl directory id = " . $self->bcl_directory_id;
    }
    print Dumper $bd;
    my @sg = Pfizer::FastQC::SampleGroupFactory->selectByCriteria(BCL_DIRECTORY_ID => "= " . $bd->id);
    unless (@sg) {
	confess "cannot select Samplegroup id = " . $self->bcl_directory_id;
    }
    $sg[0];
}

=head2 _slr2name

 Title      : _slr2name
 Usage    :  my $bcl2fasq_output_fastq_name = $b2q->_slr2name($sample, $lane, $read)
 Function: Construct the bcl2fastq name for a sample, lane, read (%s_S%d_L%03d_R%d_001.fastq.gz)
                  (Note: this is before lane-concatenation).
 Returns  : The bcl2fastq standard fastq name

=cut


sub _slr2name {
    my $self = shift;
    my $s = shift;
    my $lane = shift;
    my $read = shift;
    my $sample_prefix;

    if (defined($s->sample_name) && $s->sample_name ne '') {
	$sample_prefix = $s->sample_name;
	#$sample_prefix  =~ s/[_\.]/-/g;
    } else {
	$sample_prefix = $s->sample_id;
    }

    sprintf("%s_S%d_L%03d_R%d_001.fastq.gz", 
	    $sample_prefix,
	    $s->order,
	    $lane,
	    $read);
}

sub _slr2name_undetermined {
    my $self = shift;
    my $lane = shift;
    my $read = shift;
    my $sample_prefix = 'Undetermined';
    my $order = 0;
    sprintf("%s_S%d_L%03d_R%d_001.fastq.gz", 
	    $sample_prefix,
	    $order,
	    $lane,
	    $read);
}

=head2 _sr2name

 Title      : _sr2name
 Usage    : my $fastq_name = $b2q->_sr2name($sample, $read)
 Function: Construct the standard fastq.gz file name in the form (sample_<order>_<read>.fastq.gz)
 Returns  : A standard fastq.gz file name corresponding to ($sample, $read)

=cut


sub _sr2name {
    my $self = shift;
    my $s = shift;
    my $read = shift;
    my $sample_prefix;

    if (defined($s->sample_name) && $s->sample_name ne '') {
	$sample_prefix = $s->sample_name;
	#$sample_prefix =~ s/[_\.]/-/g;

    } else {
	$sample_prefix = $s->sample_id;
    }
    sprintf("%s_S%d_%d.fastq.gz", 
	    $sample_prefix,
	    $s->order,
	    $read);
}

sub _sr2name_undetermined {
    my $self = shift;
    my $read = shift;
    my $sample_prefix = 'Undetermined';
    sprintf("%s_S%d_R%d_001.fastq.gz", 
	    $sample_prefix,
	    0,
	    $read);
}

sub _slr2fastq {
    my $self = shift;
    my $s = shift;
    my $lane = shift;
    my $read = shift;
    my $sample_prefix;
    if (defined($s->sample_name) && $s->sample_name ne '') {
		
	$sample_prefix = $s->sample_name;
	#$sample_prefix  =~ s/[_\.]/-/g;
    } else {
	$sample_prefix = $s->sample_id;
    }
    sprintf("%s/%s", 
	    $self->output_dir,
	    $self->_slr2name($s, $lane, $read));
}

sub _slr2fastq_undetermined {
    my $self = shift;
    my $lane = shift;
    my $read = shift;
    my $sample_prefix = 'Undetermined';
    sprintf("%s/%s", 
	    $self->output_dir,
	    $self->_slr2name_undetermined($lane, $read));
}

sub getFastqFiles {
    my $self = shift;
    my @samps = $self->getSamples;
    @samps = sort { $a->order <=> $b->order } @samps;
    my @fastqs;
    my $i =1;
    foreach my $s (@samps) {
	foreach my $lane (1..$Pfizer::FastQC::Config::env{$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR}->{BCL_NUM_LANES}) {
	    foreach my $read (1..$self->num_reads) {
		push @fastqs, $self->_slr2fastq($s, $lane, $read)
	    }
	}
    }		    
    @fastqs;
}

sub getFastqFilesBySampleRead {
    my $self = shift;
    my $sobj = shift;
    my $readnum = shift;
    my @fastqs;
    foreach my $lane (1..$Pfizer::FastQC::Config::env{$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR}->{BCL_NUM_LANES}) {
	push @fastqs, $self->_slr2fastq($sobj, $lane, $readnum)
    }
    @fastqs;
}

sub getFastqFilesBySampleReadUndetermined {
    my $self = shift;
    my $readnum = shift;
    my @fastqs;
    foreach my $lane (1..$Pfizer::FastQC::Config::env{$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR}->{BCL_NUM_LANES}) {
	push @fastqs, $self->_slr2fastq_undetermined($lane, $readnum)
    }
    @fastqs;
}

sub concat_lane_fastq {
    my $self = shift;
    my @samps = $self->getSamples;
    # First: all the sample reads
    foreach my $s (@samps) {
	# DONE this breaks for single-ended read
	foreach my $read (1..$self->num_reads) {
		
	    my @infastqs = getFastqFilesBySampleRead($self, $s, $read);
	    #print "concat-lane : @infastqs \n";
	    my $outfastq = join("/", $self->output_dir, $self->_sr2name($s, $read));
	    if (! -e $outfastq) {
		my @cmd = ("$Pfizer::FastQC::Config::BSUB_CMD -Is 'cat ", @infastqs, " > ", $outfastq, "'");
		protlog($LOG_FH, "will execute command:\n" . join(" ", @cmd)) if $VERBOSE>=1;
		unless (system(join(" ", @cmd))==0) {
		    warn "failed to run: " . join(" ", @cmd);
		    return 0;
		}
		foreach my $f (@infastqs) {
		    unlink $f or warn "failed to remove file $f: $!";
		}
	    } else {
		protlog($LOG_FH, "merged fastq '$outfastq' already exists: skipping") if $VERBOSE>=1;
	    }
	}
   }
   # finally, do the Undetermined reads
    foreach my $read (1..$self->num_reads) {
	my @infastqs = getFastqFilesBySampleReadUndetermined($self, $read);
	    my $outfastq = join("/", $self->output_dir, $self->_sr2name_undetermined($read));
	    if (! -e $outfastq) {
		my @cmd = ("$Pfizer::FastQC::Config::BSUB_CMD -Is 'cat ", @infastqs, " > ", $outfastq, "'");
		protlog($LOG_FH, "will execute command:\n" . join(" ", @cmd)) if $VERBOSE>=1;
		unless (system(join(" ", @cmd))==0) {
		    warn "failed to run: " . join(" ", @cmd);
		    return 0;
		}
		foreach my $f (@infastqs) {
		    unlink $f or warn "failed to remove file $f: $!";
		}
	    } else {
		protlog($LOG_FH, "merged fastq '$outfastq' already exists: skipping") if $VERBOSE>=1;
	    }
    }
    return 1;
}

=head2 getByBCLDirectoryID 

 Title   : getByBCLDirectoryID 
 Usage   : 
 Function: 
 Returns : Array of BCL2FastRun having the requested BCL_DIRECTORY_ID

=cut

sub getByBCLDirectoryID {
    my $type = shift;
    my $bcl_dir_id = shift;
    my @b2fs = $type->selectByCriteria('BCL_DIRECTORY_ID' => ' = ' . $bcl_dir_id);
    @b2fs;
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
	confess("failed to update BCL2FastqRun ID = " . $self->id);
    }
}

1;
