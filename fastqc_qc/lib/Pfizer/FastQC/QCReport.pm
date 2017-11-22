package Pfizer::FastQC::QCReport;
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

our @FIELDS = qw( QC_REPORT_ID
USERNAME
STATUS
NAME
PATH
FASTQC_OUTDIR
FASTQC_EXTRACT
DATE_MODIFIED
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
 Function: Gets ID of this QCReport
 Returns : object ID

=cut

sub id {
    my $self = shift;
    return $self->{'QC_REPORT_ID'};
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
    $self->{'QC_REPORT_ID'} = $id;
}    

=head2 path

 Title   : path
 Usage   :  $bd->path;
 Function: Gets PATH of this QCReport
 Returns : object PATH

=cut

sub path {
    my $self = shift;
    return $self->{'PATH'};
}    

=head2 set_path

 Title   : set_path
 Usage   :  $bd->set_path;
 Function: Sets PATH of this QCReport
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
 Function: Gets STATUS of this QCReport
 Returns : object STATUS

=cut

sub status {
    my $self = shift;
    return $self->{'STATUS'};
}    

=head2 set_status

 Title   : set_status
 Usage   :  $bd->set_status;
 Function: Sets STATUS of this QCReport
 Returns : object STATUS

=cut

sub set_status {
    my $self = shift;
    my $status = shift;
    $self->{'STATUS'} = $status;
}    

=head2 username

 Title   : username
 Usage   :  $bd->username;
 Function: Gets USERNAME of this QCReport
 Returns : object USERNAME

=cut

sub username {
    my $self = shift;
    return $self->{'USERNAME'};
}    

=head2 set_username

 Title   : set_username
 Usage   :  $bd->set_username;
 Function: Sets USERNAME of this QCReport
 Returns : object USERNAME

=cut

sub set_username {
    my $self = shift;
    my $username = shift;
    $self->{'USERNAME'} = $username;
}    

=head2 run

 Title   : run
 Usage   : 
 Function:  Execute the QC Report
 Returns : 

=cut

sub run {
    my $self = shift;
    $self->sendStartMessage;
    $self->set_update_status('WOR');
    my @infastqs = Pfizer::FastQC::QCRep2FastqFactory->selectByCriteria(QC_REPORT_ID => '= ' . $self->id);
    my @fastq_ids = map { $_->fastq_file_id } @infastqs;
    my @infqs = map { Pfizer::FastQC::CleanFastqFileFactory->select($_) } @fastq_ids;
    my @infiles = map { $_->full_path } @infqs;
    print join("\n", @infiles), "\n";
    my $output_dir = $self->path;

    unless (-e $output_dir) {
	unless(make_path($output_dir)) {
	    $self->set_update_status('FAI');
	    warn "failed to create directory $output_dir";
	    return(0);
	}
    }
    my @outfdirs;
    foreach my $in (@infiles) {
	push @outfdirs, join("/", $output_dir, _fastq2fastqc_dir($in));
    }
    my $all_already_complete = 1;
    foreach my $ofd (@outfdirs) {
	if (! -e $ofd) {
	    $all_already_complete = 0;
	}
    }
    # Execute FASTQC on each of the target .fastq.gz files
    my @fastqc_dirs;
    if (! $all_already_complete) {
	my $log_stub = join("/", $output_dir, $self->id);
	unless (@fastqc_dirs = run_fastqc($output_dir, 1, 'fastq', \@infiles, $log_stub)) {
	    $self->set_update_status('FAI');
	    warn "failed to run-fastqc for QC Report ID = " . $self->id;
	    return 0;
	}
    } else {
	@fastqc_dirs = @outfdirs;
    }

    # Execute contamination alignment on each of the target .fastq.gz files
    my @trefs = contamAlignParallel(\@infqs, $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE, 
				    $Pfizer::FastQC::Config::FQ_TMPDIR);
    # write contamination reports for each input fastq to corresponding FASTQC directory
    my @fastqc_dirs_exist;
    foreach my $i (0..(@trefs-1)) {
	if (-e $fastqc_dirs[$i]) {
	    push @fastqc_dirs_exist, $fastqc_dirs[$i];
	    my $output_report = join("/", $fastqc_dirs[$i], "contam_report.txt");
	    my $short_fname = $infqs[$i]->name;
	    $short_fname =~ s/^.+\///;
	    unless (open OUT, ">$output_report") {
		$self->set_update_status('FAI');
		warn "cannot open $output_report: $!";
		return(0);
	    }
	    print OUT join("\t", 'Filename', $short_fname), "\n";
	    foreach my $ordered_token (@Pfizer::FastQC::Config::CONTAM_SPECIES_ORDERED) {
		if (defined($trefs[$i]->{$ordered_token})) {
		    print OUT join("\t", $ordered_token, $trefs[$i]->{$ordered_token}), "\n";
		}
	    }
	    protlog($LOG_FH, "wrote contamination report: $output_report");
	    close OUT;
	} else {
	    $self->set_update_status('FAI');
	    protlog($LOG_FH, "warning: directory '$fastqc_dirs[$i]' does not exist, skipping");
	    return(0);
	}
    }

    # merge the individual FASTQC reports into the single
    # final aggregate report
    my $html_report = generate_qc_report(@fastqc_dirs_exist);
    my $outfile = join("/", $output_dir , ($self->id . ".html"));
    unless (open OUT, ">$outfile") {
	$self->set_update_status('FAI');
	warn "cannot open $outfile: $!";
	return(0);
    }
    print OUT $html_report;
    close OUT;

    #Code inserted - Multiqc
    print "fastqc_dir is $fastqc_dirs[0]\n";
    my $input_dir = dirname($fastqc_dirs[0]);
    print "multiqc input dir is $input_dir\n";

    my $report_name = basename($input_dir);

    my $multiqc_cmd = "multiqc -f $input_dir/* -c $Pfizer::FastQC::Config::MULTIQC_CONFIG_PATH -n $report_name  -o /hpc/grid/scratch/ayyasa/";
    print "multiqc cmd : $multiqc_cmd\n";
    system($multiqc_cmd);


    # Update the status of the QC report
    $self->set_update_status('PAS');
    $self->sendCompleteMessage;
    return 1;
}

=head2 fastqc_extract

 Title   : fastqc_extract
 Usage   :  $bd->fastqc_extract;
 Function: Gets FASTQC_EXTRACT of this QCReport
 Returns : object FASTQC_EXTRACT

=cut

sub fastqc_extract {
    my $self = shift;
    return $self->{'FASTQC_EXTRACT'};
}    

=head2 set_fastqc_extract

 Title   : set_fastqc_extract
 Usage   :  $bd->set_fastqc_extract;
 Function: Sets FASTQC_EXTRACT of this QCReport
 Returns : object FASTQC_EXTRACT

=cut

sub set_fastqc_extract {
    my $self = shift;
    my $fastqc_extract = shift;
    $self->{'FASTQC_EXTRACT'} = $fastqc_extract;
}    

=head2 fastqc_outdir

 Title   : fastqc_outdir
 Usage   :  $bd->fastqc_outdir;
 Function: Gets FASTQC_OUTDIR of this QCReport
 Returns : object FASTQC_OUTDIR

=cut

sub fastqc_outdir {
    my $self = shift;
    return $self->{'FASTQC_OUTDIR'};
}    

=head2 set_fastqc_outdir

 Title   : set_fastqc_outdir
 Usage   :  $bd->set_fastqc_outdir;
 Function: Sets FASTQC_OUTDIR of this QCReport
 Returns : object FASTQC_OUTDIR

=cut

sub set_fastqc_outdir {
    my $self = shift;
    my $fastqc_outdir = shift;
    $self->{'FASTQC_OUTDIR'} = $fastqc_outdir;
}    

sub sendStartMessage {
    my $self = shift;
    my $msg = $self->startMessage();
    protlog($LOG_FH, $self->startMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($self->username),
	     "Started QC Report " . $self->name,
	     $self->startMessage);
}

sub startMessage {
    my $self = shift;
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    $msg .= "FastQC User,\n" . 
		"<p>Your QC Report <strong>" . 
		$self->name . "</strong> has been queued " .
		"(ID = <strong>" . $self->id . "</strong>)." . 
		"<br/>" .
		"<hr/>" . supportText();
    $msg .= "</body></html>";
    $msg;
}

sub url {
    my $self = shift;
    my $url = join("/", $self->path, $self->id) . '.html';
    print "qc url = '$url'\n";
    $url =~ s/$Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR/$Pfizer::FastQC::Config::QC_REPORT_ROOT_URL/;
    print "qc url after = '$url'\n";
    $url;
}

sub multiqc_url {
   my $self = shift;
   my $url = $self->path . '.html';
   print "multiqc url = $url \n";
   $url =~s/$Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR/$Pfizer::FastQC::Config::MULTIQC_REPORT_ROOT_URL/;
   print "multiqc url after subs = $url \n";
   $url;	
}


sub sendCompleteMessage {
    my $self = shift;
    my $msg = $self->completeMessage();
    protlog($LOG_FH, $self->completeMessage);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($self->username),
	     "Completed QC Report " . $self->name,
	     $self->completeMessage);
}

sub completeMessage {
    my $self = shift;
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    $msg .= "FastQC User,\n" . 
		"<p>Your QC Report (ID = <strong>" . $self->id . "</strong>) " . 
		"is complete.  Your report can be found in the directory: <br/><strong>" . $self->path.
		"</strong>.</p>" .
		"<p>You can view your report <strong><a href='" . $self->url . "'>here</a></strong>  (" . $self->url . ")" . 
		".</p>" .
                 "<p>You can view MultiQC report <strong><a href='" . $self->multiqc_url . "'>here</a></strong> (" . $self->multiqc_url .")" .
                 ".</p>" . 
		"<p>Note: Reports are best viewed in Google Chrome browser.</p><hr/>" . 
		supportText(); 
     $msg .= "</body></html>";
    $msg;
}

sub _fastq2fastqc_dir {
    my $fastq = shift;
    my $dir;
    ($dir = $fastq) =~ s/\.f(ast)?q.gz$/_fastqc/;
    $dir;
    
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
	confess("failed to update QCReport ID = " . $self->id);
    }
}

1;
