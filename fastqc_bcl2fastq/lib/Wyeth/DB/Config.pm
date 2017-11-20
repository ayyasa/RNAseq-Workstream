package Wyeth::DB::Config;

=head1 NAME

Wyeth::DB::Config

=head1 SYNOPSIS

 use Wyeth::DB::Config
 
=head1 DESCRIPTION

 Defines and exports configuration variables for Wyeth::DB modules.
 Some variables are inherited from the environment via %ENV,
 if the corresponding environment variables are set. Other variables are
 read from a configuration file, see do_config() for details.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use warnings 'all';
use Exporter;
use Carp;
use strict;

our $VERSION = '1.3.2';

our @ISA = qw/Exporter/;
our @EXPORT = qw/  get_usr_pwd $DB_DRIVER $ORACLE_SID $LOG_FH
                   get_usr/;

our $VERBOSE = defined($ENV{MM_VERBOSE}) ? $ENV{MM_VERBOSE} : 1; 
our $LOG_FH = \*STDOUT;
our $DB_DRIVER = defined($ENV{'MM_DB_DRIVER'}) ? $ENV{'MM_DB_DRIVER'} : '::Oracle';
our $ORACLE_SID = $ENV{'PROT_SID'};
our $PROT_USER = $ENV{'PROT_USER'};
our $PROT_PASS = $ENV{'PROT_PASS'};
our $DEFAULT_SCHEMA = $ENV{'MM_DEFAULT_SCHEMA'};

sub get_usr {
    $PROT_USER
}

=head2 get_usr_pwd

 Title   : get_usr_pwd
 Usage   : get_usr_pwd(); 
 Function: Retrieve username and password from shell environment
 Returns : List of length 2 containing username and password

=cut

sub get_usr_pwd {
    my $u = $PROT_USER;
    my $p = $PROT_PASS;
    if (!defined $u) {
        confess
            "Variable PROT_USER must be defined";
    }
    if (!defined $p) {
        confess
            "Variable PROT_PASS must be defined";
    }
    ($u, $p);
}

sub getciphertext {
	my $cipherfile = shift;
	my $priv_file = shift;
	my $rsa = new Crypt::RSA;
	my $private = new Crypt::RSA::Key::Private( Filename => $priv_file);
	open IN, "<$cipherfile" or die "cannot open $cipherfile";
	my @ctext = <IN>;
	my $ctext = join("", @ctext);
	close IN;
	my $ciphertext = $rsa->decrypt( Cyphertext => $ctext,
		      Key => $private,
		      Armour => 1);
	$ciphertext;
}


1;

