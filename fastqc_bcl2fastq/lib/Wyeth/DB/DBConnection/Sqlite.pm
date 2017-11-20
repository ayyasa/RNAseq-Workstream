package Wyeth::DB::DBConnection::Sqlite;
use base qw(Wyeth::DB::DBConnection);

=head1 NAME

Wyeth::DB::DBConnection::Sqlite

=head1 SYNOPSIS

    use Wyeth::DB::DBConnection::Sqlite;
    $dbc1 = Wyeth::DB::DBConnection::Sqlite->instance($sqlite_file, $user, $pwd);

=head1 DESCRIPTION

Class to manage Sqlite database connection. 

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use DBI;

our $VERSION = '1.3.2';

my $oneTrueSelf;

=head2 instance

 Title   : instance
 Usage   : $dbc->instance($sqlite_file, $user, $pwd); 
 Function: Return a singleton instance of a database connection
           to a Sqlite file.
 Returns : A singleton DBConnectionSqlite object.

=cut

sub instance {
    unless (defined($oneTrueSelf) && $oneTrueSelf->{'_dbh'}->ping) {
	my $type = shift;
	my $SQLITE_FILE = shift;
	my $user = shift;
	my $pwd = shift;
	my $this = { _dbh => connectToDb( $SQLITE_FILE, $user, $pwd) };
	$oneTrueSelf = bless $this, $type;
    }
    print "Returning dbh instance\n" if $Wyeth::DB::Config::VERBOSE>=3;
    return $oneTrueSelf;
}

=head2 dbh

 Title   : dbh
 Usage   : $dbc->dbh
 Function: Return the DBI database handle. 
 Returns : The DBI database handle

=cut

sub dbh {
    my $self = shift;
    $self->{'_dbh'};
}

=head2 connectToDb

 Title   : connectToDb
 Usage   : $dbh = connectToDb( $sqlite_file, $username, $password); 
 Function: Connects to an Oracle relational database, and sets some
           connection properties that are appropriate for Masstermine.
 Returns : a DBI database handle

=cut

sub connectToDb {
    my $sqlite_file = shift;
    my $username = shift;
    my $password = shift;
    
    my $database = "dbi:SQLite:dbname=" . $sqlite_file;
    my %attr = (
		PrintError => 1,
		RaiseError => 0,
		AutoCommit => 0,
		private_mm_connection => 'yes'
		);
    my $dbh = DBI->connect_cached($database,$username,$password, \%attr) or 
	confess $DBI::errstr;
    $dbh->do("PRAGMA foreign_keys = ON") or confess $DBI::errstr;
    print "Connected to $database as \'$username\'\n" if $Wyeth::DB::Config::VERBOSE>=3;
    return $dbh;
}

=head2 getDateStamp

 Title   : getDateStamp
 Usage   : $date_stamp = $dbi->getDateStamp(); 
 Function: Ojbect method that retrieves current date
 Returns : String containing a date stamp

=cut

sub getDateStamp {
    my $self = shift;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);
}

sub disconnect {
    my $class = shift;
    if (defined($oneTrueSelf)) {
	$oneTrueSelf->{'_dbh'}->disconnect;
    }
    return 1;
}

1;
