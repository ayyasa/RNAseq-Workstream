package Wyeth::DB::DBConnection;

=head1 NAME

Wyeth::DB::DBConnection

=head1 SYNOPSIS

    use Wyeth::DB::DBConnection;
    $dbc1 = Wyeth::DB::DBConnection->instance($oracle_sid, $user, $pwd);
    $dbc2 = Wyeth::DB::DBConnection->instance($oracle_sid, $user, $pwd);
    # these two connection objects will share the same Oracle connection

=head1 DESCRIPTION

Object class to manage Oracle database connection.  The Singleton
design pattern is used to ensure re-use of any pre-existing connection
instance.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use DBI;
use Carp;
use Wyeth::DB::Config;

our $VERSION = '1.3.2';

my $oneTrueSelf;
my $SELECT_DATE = "SELECT SYSDATE FROM DUAL";

=head2 instance

 Title   : instance
 Usage   : Wyeth::DB::DBConnection->instance($oracle_sid, $user, $pwd); 
 Function: Return a singleton instance of an Oracle database connection
           to database designated by $oracle_sid.
 Returns : A singleton DBConnection object.

=cut

sub instance {
    unless (defined($oneTrueSelf) && $oneTrueSelf->{'_dbh'}->ping) {
	my $type = shift;
	my $ORACLE_SID = shift;
	my $user = shift;
	my $pwd = shift;
	my $setSchema = shift || $Wyeth::DB::Config::DEFAULT_SCHEMA;
	my $this = { _dbh => connectToDb( $ORACLE_SID, $user, $pwd, $setSchema) };
	$oneTrueSelf = bless $this, $type;
    }
    print "Returning dbh instance\n" if $Wyeth::DB::Config::VERBOSE>=3;
    return $oneTrueSelf;
}

sub dbh {
    my $self = shift;
    $self->{'_dbh'};
}

=head2 connectToDb

 Title   : connectToDb
 Usage   : $dbh = connectToDb( $target_db, $username, $password); 
 Function: Connects to an Oracle relational database, and sets some
           connection properties that are appropriate for Masstermine.
 Returns : a DBI database handle

=cut

sub connectToDb {
    my $targetDb = shift;
    my $username = shift;
    my $password = shift;
    my $setSchema = shift;
    
    my $database = "dbi:Oracle:" . $targetDb;
    print "Database connect string: $database (as $username)\n" if $Wyeth::DB::Config::VERBOSE>=3;
    my %attr = (
		PrintError => 1,
		RaiseError => 0,
		AutoCommit => 0,
		private_mm_connection => 'yes',
	        LongReadLen => 2*1024*1024 #2 meg
	);
    my $dbh = DBI->connect_cached($database,$username,$password, \%attr) or 
	confess $DBI::errstr;
    $dbh->do("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'") or
	confess $DBI::errstr;
    if (defined($setSchema)) {
	$dbh->do("ALTER SESSION SET CURRENT_SCHEMA = $setSchema") or
	confess $DBI::errstr;
    }
    print "Connected to $database as $username with default schema '$setSchema'\n" if $Wyeth::DB::Config::VERBOSE>=3;
    return $dbh;
}

=head2 getDateStamp

 Title   : getDateStamp
 Usage   : $date_stamp = $dbh->getDateStamp(); 
 Function: Object method that retrieves current date from existing singleton Oracle connection, or
           makes a new connection and does the same otherwise.
 Returns : String containing a date stamp

=cut

sub getDateStamp {
    my $self = shift;
    my $dbh = $self->{_dbh};
    my $sth = $dbh->prepare( $SELECT_DATE);
    $sth->execute or confess $dbh->errstr;
    my @date = $sth->fetchrow_array();
    $sth->finish;
    $date[0];
}

=head2 disconnect

 Title   : disconnect
 Usage   : Wyeth::DB::DBConnection->disconnect;
 Function: Disconnects from database
 Returns : True

=cut

sub disconnect {
    my $class = shift;
    if (defined($oneTrueSelf)) {
	$oneTrueSelf->{'_dbh'}->disconnect;
    }
    return 1;
}

1;
