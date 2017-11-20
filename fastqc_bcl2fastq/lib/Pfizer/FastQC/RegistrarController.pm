package Pfizer::FastQC::RegistrarController;

use warnings 'all';
use strict;
use Exporter;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(renewCredentials sendBailMsg);
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::BCLDirectory;
use Pfizer::FastQC::BCL2FastqRun;
use Pfizer::FastQC::SampleFactory;
use Pfizer::FastQC::SampleAttrib;
use Pfizer::FastQC::RawFastqFile;
use Pfizer::FastQC::ReadCleanRun;
use Pfizer::FastQC::CleanFastqFileFactory;
use Pfizer::FastQC::QCRep2Fastq;
use Pfizer::FastQC::QCReport;
use Wyeth::Util::Utils qw(protlog sendmail);
use Carp;


our $VERSION = '1.0.0';
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/register_core addBCLDirectory setupSampleGroup/;

my $PROCESSING = $Pfizer::FastQC::Config::PROCESSING; # for debug; 0 = no processing will be done, only monitoring
my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;

sub register_core {
    my @sampleSheets = @_;
    ## CORE f(@sampleSheets)
    my $num_sample_sheets = @sampleSheets;
    protlog($LOG_FH, "found $num_sample_sheets new SampleSheet(s) in $FQ_BCL_ROOT_DIR");
    if ($PROCESSING) {
	foreach my $ss (@sampleSheets) {
	    my $bd = new Pfizer::FastQC::BCLDirectory();
	    unless ($bd = addBCLDirectory($ss)) {
		next;
	    }
	    my $username = $ss->email;
	    my $do_readclean = $ss->do_read_clean;
	    # Does a SampleGroup exist already with the same parameter (readclean)
	    my $sg = new Pfizer::FastQC::SampleGroup();
	    unless ($sg = setupSampleGroup($bd, $ss)) {
		next;
	    }
	    # If one does not already exist, insert a BCL2FASTQ_RUN
	    my $needNewBCL2FastqRun = 1;
	    my $b2f = new Pfizer::FastQC::BCL2FastqRun();
	    $b2f->set_name($bd->name);
	    my @raw_fastqs;
	    my $all_fastq_ok = 1;
	    my @fastq_check_msgs = ("BCL Directory: " . $bd->name); 
	    if ($needNewBCL2FastqRun) {
		my @b2fs;
		if (@b2fs = Pfizer::FastQC::BCL2FastqRun->getByBCLDirectoryID($bd->id)) {
		    protlog($LOG_FH, "BCL Directory ID = " . $bd->id . " already has generated .fastq files");
		    $b2f = $b2fs[0];
		} else { # Insert new BCL2FastqRun
		    $b2f->set_bcl_directory_id($bd->id);
		    $b2f->set_loading_threads($Pfizer::FastQC::Config::LOADING_THREADS); # 16
		    $b2f->set_demultx_threads($Pfizer::FastQC::Config::DEMULTX_THREADS); # 16
		    $b2f->set_proc_threads($Pfizer::FastQC::Config::PROC_THREADS); # (32);
		    $b2f->set_write_threads($Pfizer::FastQC::Config::WRITE_THREADS); # (16);
		    $b2f->set_status('PEN');
		    $b2f->set_output_dir(join("/", $Pfizer::FastQC::Config::RAW_FASTQ_FILE_DIR, $bd->name));
		    if ($b2f->insert) {
			protlog($LOG_FH, "Inserted new BCL2FastqRun ID = " . $b2f->id);
		    } else {
			warn("failed to insert BCL2FastqRun ID = " . $b2f->id);
			next;
		    }
		    $bd->set_update_status('WOR');
		    $b2f->sendStartMessage;
		    @raw_fastqs = $b2f->run;
		    if (@raw_fastqs && ($b2f->status eq 'PAS')) { 
			foreach my $fqo (@raw_fastqs) {
			    if (-e $fqo->full_path) {
				my $fsz = -s $fqo->full_path;
				push @fastq_check_msgs, sprintf("%s: %0.0f M", $fqo->name, $fsz/1e6);
				if (! $fsz > 0) {
				    protlog($LOG_FH, "Filesize ($fsz) was zero for " . $fqo->name);
				    push @fastq_check_msgs, sprintf("Error: Filesize was zero for %s", $fqo->name);
				    $all_fastq_ok = 0;
				}
			    } else {
				push @fastq_check_msgs, sprintf("Error: File %s was not generated", $fqo->name);
				$all_fastq_ok = 0;
			    }
			}
		    } else { # BCL2Fastq run returned fail status
			$all_fastq_ok = 0;
			push @fastq_check_msgs, "BCL2FastqRun failed to generate .fastq.gz files";
			set_b2f_fail($bd, $b2f);
			warn "failed to run BCL2FastqRun ID = " . $b2f->id;
		    }	
		} 
	    } # if need new BCL run
	    protlog($LOG_FH, join("\n", @fastq_check_msgs));
	    if ($all_fastq_ok) {
		$b2f->set_update_status('PAS');
		$b2f->sendCompleteMessage;
	    } else {
		set_b2f_fail($bd, $b2f);
		sendBailMsg($sg->userName, join("<br>", @fastq_check_msgs));
		next;
	    }
	    # ReadCleanRun
	    # Isolate @rcrs = ReadCleanRun( for SampleGroupId)
	    my @rcrs = Pfizer::FastQC::ReadCleanRun->run_for_sample_group($sg, $do_readclean, $ss);
	    
	    # write the metadata file
	    my $dest_file = join('/', $b2f->output_dir, 'metadata.txt');
	    unless (open OUT, ">$dest_file") {
		set_b2f_fail($bd, $b2f);
		protlog($LOG_FH, "cannot open $dest_file: $!");
		sendBailMsg($sg->userName, 'Failed to open $dest_file for write');
		next;
	    }
	    my ($headsref, $recs) = $sg->attrib_table();
	    print OUT join("\t", @$headsref), "\n";
	    foreach my $rec (@$recs) {
		print OUT join("\t", @$rec), "\n";
	    }
	    close OUT;
	    protlog($LOG_FH, "wrote metadata to $dest_file");
	    
#	    # Insert and run the QC Report
#	   # #my $qcr = new Pfizer::FastQC::QCReport();
#	   # $qcr->set_username($sg->userName);
#	   # $qcr->set_status('PEN');
#	   # $qcr->set_name(join("_", $sg->name, $sg->do_readclean));
#	   # $qcr->set_path(join("/", $Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR, $qcr->name));
#	   # $qcr->set_fastqc_extract(1);
#	   # unless ($qcr->insert) {
#		warn "failed to insert QCReport";
#		next;
#	    }
#	    my @infastqs;
#	    foreach my $rcr (@rcrs) {
#		push @infastqs, Pfizer::FastQC::CleanFastqFileFactory->selectByCriteria(READCLEAN_RUN_ID => ' = ' . $rcr->id);
#	    }
#	    foreach my $inf (@infastqs) {
#		my $q2f = new Pfizer::FastQC::QCRep2Fastq();
#		$q2f->set_qc_report_id($qcr->id);
#		$q2f->set_fastq_file_id($inf->id);
#		$q2f->set_fastq_type('CLEAN');
#		unless ($q2f->insert) {
#		    warn "failed to insert QCRep2Fastq";
#		    next;
#		}	       	       
#	    }
#	    if ($qcr->run && ($qcr->status eq 'PAS')) {
#		protlog($LOG_FH, "Succesfully completed QCReport ID = " . $qcr->id);
#		$qcr->set_update_status('PAS');
#	    } else {
#		$qcr->set_update_status('FAI');
#		sendBailMsg($sg->userName, "failed to run QCReport ID = " . $qcr->id . " for BCL Directory " . $bd->name);
#		next;
#	    }
#	    # BCL2Fastq through QC Report have completed
	    $bd->set_update_status('PAS');
	    protlog($LOG_FH, "Successfully completed processing for BCLDirectory " . $bd->name);
	} # next new SampleSheet
    } # end if $PROCESSING
    ## CORE end  
} # end sub

sub set_b2f_fail {
    my $bd = shift;
    my $b2f = shift;
    $b2f->set_update_status('FAI');
    $bd->set_update_status('FAI');
}

sub addBCLDirectory {
    my $ss = shift;
    my @failing_names = $ss->validate_sample_names;
    if (@failing_names) {
	protlog($LOG_FH, "File " . $ss->filename . "contains illegal sample names, skipping this directory");
	$ss->sendBadNamesMsg(\@failing_names);
	return(0);
    }
    my $bd = Pfizer::FastQC::BCLDirectory->buildFromSampleSheet($ss);
    my $bdtest = new Pfizer::FastQC::BCLDirectory();
    if ($bdtest->selectByName($bd->name)) {
	protlog($LOG_FH, "BCL Directory  " . $bd->name . "(ID = " . $bd->id . ") already exists, skipping this directory");
	return(0);
    } else {
	# Insert the BCLDirectory
	unless ($bd->insert) {
	    warn("failed to insert BCLDirectory " . $bd->name);
	    return(0);
	}
	protlog($LOG_FH, "New BCL Directory " . $bd->name . " inserted");
    }
    return($bd);
}	    

sub setupSampleGroup {
    my $bd = shift;
    my $ss = shift;
    my $needNewSampleGroup = 1;
    my $needNewSamples = 1;
    my $sg = new Pfizer::FastQC::SampleGroup();
    if ($sg->selectByName($bd->name)) {
	protlog($LOG_FH, "Sample group ID = " . $sg->id . " already exists; skipping processing of this directory");
	return(0);
	if ($sg->do_readclean eq $ss->do_read_clean) {
	    protlog($LOG_FH, "Sample group ID = " . $sg->id . " already exists with same readclean setting");
	    $needNewSampleGroup = 0;
	} else {
	    protlog($LOG_FH, "Sample group ID = " . $sg->id . " exists, but has a different readclean setting");
	    $needNewSampleGroup = 1;
	}
    } 
    if ($needNewSampleGroup) {
	$sg = Pfizer::FastQC::SampleGroup->insertSampleGroup($bd, $ss);
	if ($needNewSamples) {
	    Pfizer::FastQC::Sample->insertSamples($sg, $ss);
	} else {
	    # reference samples from the already-existing SampleGroup
	}
    } # end if need new Sample Group
    return($sg);
}

