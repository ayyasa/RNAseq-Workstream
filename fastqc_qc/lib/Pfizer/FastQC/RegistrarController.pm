package Pfizer::FastQC::RegistrarController;

use warnings 'all';
use strict;
use Exporter;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(renewCredentials sendBailMsg);
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::SampleGroupFactory;
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
use List::MoreUtils qw(uniq);

our $VERSION = '1.0.0';
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/register_core addBCLDirectory setupSampleGroup/;

my $PROCESSING = $Pfizer::FastQC::Config::PROCESSING; # for debug; 0 = no processing will be done, only monitoring
my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;

sub register_core {
    my @metadata_files = @_;
    ## CORE f(@sampleSheets)
    my $num_metadata = @metadata_files;
    protlog($LOG_FH, "found $num_metadata new Metadata file in $FQ_BCL_ROOT_DIR");
    if ($PROCESSING) {
	foreach my $md (@metadata_files) { #md was ss before; remove this comment

	    my $bd = new Pfizer::FastQC::BCLDirectory();
	    unless ($bd = findBCLDirectory($md)) {  #find BCLdir name
		next;
	    }
            my $bd_id = $bd->id; #print "bd id is $bd_id\n";
	    my @sg = Pfizer::FastQC::SampleGroupFactory->selectByCriteria(BCL_Directory_ID => " = " . $bd->id); 
	    my $username = $sg[0]->userName; #print "username is $username\n";
            my $name = $sg[0]->name; #print "sgname is $name\n";
            my $doreadclean = $sg[0]->do_readclean; #print "doread is $doreadclean\n";


	    my @b2f = Pfizer::FastQC::BCL2FastqRun->selectByCriteria(BCL_DIRECTORY_ID => " = " . $bd->id);
	    my $b2f_id = $b2f[0]->id;

	    my @rfqs = Pfizer::FastQC::RawFastqFile->selectByCriteria(BCL2FASTQ_RUN_ID => " = " . $b2f_id);
            my ($k, @cfqs_id, @cfqs_list, @rcr_ids);
	    foreach $k (@rfqs){
		my @cfqs = Pfizer::FastQC::CleanFastqFile->selectByCriteria(RAW_FASTQ_FILE_ID => " = " .$k->id);
		push @cfqs_list ,@cfqs;
	    }

	    foreach $k (@cfqs_list){
		my $k_id = $k->readclean_run_id;
	        push @rcr_ids , $k_id;	
	    }
            @rcr_ids = uniq(@rcr_ids);
	   
	   # Insert and run the QC Report
	   my $qcr = new Pfizer::FastQC::QCReport();
	   $qcr->set_username($sg[0]->userName);
	   $qcr->set_status('PEN');
	   $qcr->set_name(join("_", $sg[0]->name, $sg[0]->do_readclean));
	   $qcr->set_path(join("/", $Pfizer::FastQC::Config::QC_REPORT_ROOT_DIR, $qcr->name));
	   $qcr->set_fastqc_extract(1);
	   unless ($qcr->insert) {
		warn "failed to insert QCReport";
		next;
	    }
	    my @infastqs;

	    foreach my $rcr (@rcr_ids) {
		push @infastqs, Pfizer::FastQC::CleanFastqFileFactory->selectByCriteria(READCLEAN_RUN_ID => ' = ' . $rcr); #$rcr holds rcr->id
	    }
	    foreach my $inf (@infastqs) {
		my $q2f = new Pfizer::FastQC::QCRep2Fastq();
		$q2f->set_qc_report_id($qcr->id);
		$q2f->set_fastq_file_id($inf->id);
		$q2f->set_fastq_type('CLEAN');
		unless ($q2f->insert) {
		    warn "failed to insert QCRep2Fastq";
		    next;
		}	       	       
	    }
	    if ($qcr->run && ($qcr->status eq 'PAS')) {
		protlog($LOG_FH, "Succesfully completed QCReport ID = " . $qcr->id);
		$qcr->set_update_status('PAS');
	    } else {
		$qcr->set_update_status('FAI');
		sendBailMsg($sg[0]->userName, "failed to run QCReport ID = " . $qcr->id . " for BCL Directory " . $bd->name);
		next;
	    }
           # QC Report have completed
	    protlog($LOG_FH, "Successfully generated QC report for BCLDirectory " . $bd->name);
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

sub findBCLDirectory{
	my $md = shift;
	#assume sample names are valid; Add validation for sample names later here

	my $bd = Pfizer::FastQC::BCLDirectory->buildFromMetaData($md);


	$bd; 

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

