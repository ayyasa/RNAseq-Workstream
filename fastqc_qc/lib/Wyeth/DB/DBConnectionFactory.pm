package Wyeth::DB::DBConnectionFactory;

=head1 NAME

Wyeth::DB::DBConnectionFactory

=head1 SYNOPSIS

    use Wyeth::DB::DBConnectionFactory;
    # connect to an Oracle DB:
    $DB_DRIVER = '::Oracle';
    $dbh_oracle = Wyeth::DB::DBConnectionFactory->makeInstance($DB_DRIVER, $sid, $user, $pwd);
    $DB_DRIVER = '::Sqlite';
    $dbh_sqlite = Wyeth::DB::DBConnectionFactory->makeInstance($DB_DRIVER, $sid, $user, $pwd);


=head1 DESCRIPTION

Factor class to instantiate database connections.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use DBI;
use Carp;

our $VERSION = '1.3.2';

sub makeInstance {
    my ($class, $db_driver, $sid, $user, $pwd, $setSchema) = @_;
    eval "require(Wyeth::DB::DBConnection${db_driver})" or 
	confess "failed to load module Wyeth::DB::DBConnection${db_driver}";
    return "Wyeth::DB::DBConnection${db_driver}"->instance($sid, $user, $pwd, $setSchema);
}

