use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(renewCredentials sendBailMsg bail);
use Pfizer::FastQC::SampleGroup;
use Pfizer::FastQC::RegistrarController qw(register_core);
use Wyeth::Util::Utils qw(protlog);
use Carp;
use POSIX qw(setsid);
use File::Path qw(make_path);
use Cwd;
use strict;

if (@ARGV != 2) {
    print STDERR "usage $0 <LOG_FILE_NAME> <verbosity level (0..Inf)\n";
    exit(-1);
}

if (! -e $Pfizer::FastQC::Config::FQ_LOGDIR) {
    unless (make_path($Pfizer::FastQC::Config::FQ_LOGDIR)) {
	confess "failed to create the log directory '$Pfizer::FastQC::Config::FQ_LOGDIR'";
    }
}
my $logFile = $Pfizer::FastQC::Config::FQ_LOGDIR . '/' . shift;
$VERBOSE = shift || 0;

# daemonize
# append (un-buffered) to the log file
open LOG, ">>$logFile" or
    confess "cannot open log file for writing: $!";
open STDERR, ">&LOG" 
    or die "Cannot dup STDERR to LOG: $!";
open STDOUT, ">&LOG" 
    or die "Cannot dup STDOUT to LOG: $!";
select STDOUT; $| =1;
$LOG_FH = \*LOG;
my $old_fh = select $LOG_FH; $| = 1; select $old_fh;
umask 0;
FORK: {
    if (my $pid = fork) {
	protlog($LOG_FH, "####### Parent process ID = $$");
	protlog($LOG_FH, "####### Forking daemon process ID = $pid");
	exit;
    } elsif (defined $pid) {
	# in the child, setsid and nothing else
	setsid;
    } elsif ($! =~ /No more process/) {
	sleep 5;
	redo FORK;
    } else {
	confess "Cannot fork: $!\n";
    }
}

# Set the signal handler
my $GOT_SIGINT = 0;
sub set_shutdown_flag {
	my ($sig) = @_;
	$GOT_SIGINT = 1;
	protlog($LOG_FH, "$0: Received SIG $sig");
};
$SIG{USR1} = $SIG{INT} = $SIG{TERM} = \&set_shutdown_flag;

sub end_program_from_signal {
    protlog($LOG_FH, "Received signal; shutting down $0");
    close LOG;
    exit(0);
}

my $machine = `uname -n`;
protlog($LOG_FH, "####### Started $0");
protlog($LOG_FH, "####### on $machine");
protlog($LOG_FH, "####### process ID = $$");
protlog($LOG_FH, "log file = $logFile");
protlog($LOG_FH, "verbosity = $VERBOSE"); 
foreach my $dir (@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
    protlog($LOG_FH, "monitoring BCL Root $dir");
}

# The main daemon infinite loop
my $PROCESSING = 1; # for debug; 0 = no processing will be done, only monitoring
my $FQ_BCL_ROOT_DIR = $Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR;

while (1) {
    foreach my $FQ_BCL_ROOT_DIR (@Pfizer::FastQC::Config::FQ_BCL_ROOT_DIRS) {
	$Pfizer::FastQC::Config::FQ_BCL_ROOT_DIR = $FQ_BCL_ROOT_DIR;
	protlog($LOG_FH, "Set configuration for root dir $FQ_BCL_ROOT_DIR");
	my @sampleSheets = Pfizer::FastQC::SampleGroup->findNewSampleSheets($FQ_BCL_ROOT_DIR);
	register_core(@sampleSheets);
	if ($GOT_SIGINT) {
	    end_program_from_signal();
	}
    } # end fq_bcl_root_dirs
    sleep(60*$Pfizer::FastQC::Config::WAIT_MINUTES);
    unless (renewCredentials($Pfizer::FastQC::Config::PROCESS_USER, $Pfizer::FastQC::Config::KEYTAB_FILE)) {
	bail($Pfizer::FastQC::Config::ADMIN_EMAIL, 'Failed to renew credentials');
    }
} # end daemon loop

