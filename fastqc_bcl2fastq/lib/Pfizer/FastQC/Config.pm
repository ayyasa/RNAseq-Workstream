package Pfizer::FastQC::Config;

=head1 NAME

Pfizer::FastQC::Config
    
=head1 SYNOPSIS

 use Pfizer::FastQC::Config
 
=head1 DESCRIPTION

 Defines and exports configuration variables for Pfizer::FastQC modules.
 Some variables are inherited from the environment via %ENV,
 if the corresponding environment variables are set. Other variables are
 read from a configuration file, see do_config() for details.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use warnings 'all';
#use strict;
use Exporter;
use Carp;
use Data::Dumper;
use LWP::UserAgent;
# use LWP::Debug qw(+); # use this to turn on verbose messages from LWP
use HTTP::Request::Common;
use Wyeth::DB::Config;

our $VERSION = '1.3.2';

our @ISA = qw/Exporter/;
our @EXPORT = qw/  $DEV $VERBOSE $DB_DRIVER $ORACLE_SID
$LOG_FH show_config $SAMPLESHEET_FILE $BAD_CHARS/;

our @EXPORT_OK = qw//;

=head1 METHODS

=head2 do_config

 Title   : do_config
 Usage   : do_config(); 
 Function:  User- and aministrator-settable parameters for Masstermine are
            read from the .mmconfig configuration file, using do_config().  Variables
            defined in the .mmconfig file must also be on the EXPORT list
            of this module (Config.pm) to be defined in main package.
 Returns : NA

=cut

sub do_config {
    my $configdir;
    my $success = 0;
    my @LOCS = qw/ FQ_CONFIG/;
    foreach my $loc (@LOCS) {
	if (defined($ENV{$loc})) {
	    my $conf = "$ENV{$loc}/.mmconfig";

	    if (-r $conf) {
		# print "...$conf is defined\n";
		my $return = do $conf;
		unless ($return) {
		    confess "Could not parse configuration in " .
			"$conf" if $@;
			if(not defined $return){ die "Couldn't do $conf";}
			if(not return){die "Couldn't run $conf";}

			    #confess "Couldn't do $conf: $!" unless defined $return;
			    #confess "Couldn't run $conf" unless return;
		}
		$success++;
	    } else {
		print "...$conf is not defined\n";
	    }
	} else {
	    print "$loc is undefined\n";
	}
    }
    # For CGI scripts, ENV is not fully available,
    # so include a final fallback to a config file 
    # in the current working directory.
    my $conf = '.mmconfig';
    if (!$success && -r $conf) {
	my $return = do $conf;
		unless ($return) {
		    confess "Could not parse configuration in " .
			"$conf" if $@;

			if(not defined $return){ die "Couldn't do $conf";}
			if(not return){die "Couldn't run $conf";}
		
		    #confess "Couldn't do $conf: $!" unless defined $return;
		    #confess "Couldn't run $conf" unless return;
		}
		$success++;
    }
    unless ($success) {
	my $msg = "current locations are:\n";
	foreach my $loc (@LOCS) {
	    $msg .= "$loc:";
	    if (defined($ENV{$loc})) {
		$msg .= "$ENV{$loc}\n";
	    } else {
		$msg .= "<not defined>\n";
	    }
	}
	confess "Error: Cannot find .mmconfig configuration file.  For FQ configuration, you must:\n" . 
	    " 1.  have a .mmconfig file containing configuration settings.\n" .
	    " 2.  set the environment variable FQ_CONFIG to the directory that contains .mmconfig.\n" . 
	    "\n$msg";
    }
}

do_config();

# Constants and parameters that should
# not be user-configurable are defined 
# below.

=head2 show_config

 Title   : show_config
 Usage   : show_config(); 
 Function: Display a set of important system configuration variables
 Returns : NA

=cut

sub show_config {
    print join(": ", "FQ_CONFIG", $ENV{'FQ_CONFIG'}), "\n";
    my ($u,$p) = get_usr_pwd();
    print join(": ", "Database User", $u), "\n";
    print join(": ", "Database Driver (target database)", "$DB_DRIVER ($ORACLE_SID)"), "\n";
    print join(": ", "BCL ROOT directory", $FQ_BCL_ROOT_DIR), "\n";
    print join(": ", "Administrator email", $ADMIN_EMAIL), "\n";    
    print join(": ", "Logs directory", $FQ_LOGDIR), "\n";
    print join(": ", "PERL Library Path", substr(join(",", @INC), 1, 50) . "...\n");
    print join(": ", "R command", $FQ_R_CMD), "\n";
    print join(": ", "SMTP Server", $SMTP_SERVER), "\n";
    print join(": ", "VERBOSE level", $VERBOSE), "\n";
}
