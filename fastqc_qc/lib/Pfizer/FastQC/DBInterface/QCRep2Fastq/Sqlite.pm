package Pfizer::FastQC::DBInterface::QCRep2Fastq::Sqlite;
use base qw( Pfizer::FastQC::DBInterface::QCRep2Fastq);

=head1 NAME

Pfizer::FastQC::DBInterface::QCRep2Fastq::Sqlite

=head1 SYNOPSIS

=head1 DESCRIPTION

A database interface to enable persistent storage of QCRep2Fastq objects using Sqlite.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Pfizer::FastQC::Config;
use Wyeth::DB::Config;
use Wyeth::Util::Utils qw(protlog);
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.0.0';

sub INSERT_STMT { 
    my $self = shift;
    my @FIELDS = $self->FIELDS;
    "INSERT INTO " . $self->TABLE . "  ( " . join(", ", @FIELDS) . " ) VALUES " .
	"(NULL, " . join(', ', map {'?'} @FIELDS[1..$#FIELDS]) . ")";
}

=head2 insert

 Title   : insert
 Usage   : $dbi->insert($qcr);
 Function: Inserts the QCRep2Fastq to the database
 Returns : Nothing

=cut

sub insert {
    my $self = shift;
    my $lcms = shift;

    my ($user, $pwd) = get_usr_pwd();
    my $dbo = Wyeth::DB::DBConnectionFactory->makeInstance($DB_DRIVER, $ORACLE_SID, $user, $pwd);
    my $dbh = $dbo->dbh;
    my $date = $dbo->getDateStamp;
    my $sth = $dbh->prepare( $self->INSERT_STMT);
    my @FIELDS = $self->FIELDS;
    $lcms->setParam(DATE_MODIFIED => $dbo->getDateStamp);
    foreach my $i (1..@FIELDS-1) {
	$sth->bind_param( $i, $lcms->{$FIELDS[$i]});
    }
    $sth->execute or confess $dbh->errstr;
    my $lcms_run_id = $dbh->last_insert_id("","","","");
    protlog($LOG_FH, "Recorded last insert id = $lcms_run_id") if $VERBOSE>=3;
    $lcms->set_id($lcms_run_id);
    protlog($LOG_FH, "inserted " . ref($lcms) . " = " . $lcms->id)
	if $VERBOSE>=1;
    $dbh->commit;
}    

1;
