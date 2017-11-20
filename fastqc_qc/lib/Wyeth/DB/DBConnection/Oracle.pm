package Wyeth::DB::DBConnection::Oracle;
use base qw(Wyeth::DB::DBConnection);

=head1 NAME

Wyeth::DB::DBConnection::Oracle

=head1 SYNOPSIS

    use Wyeth::DB::DBConnection::Oracle;
    $dbc1 = Wyeth::DB::DBConnection::Oracle->instance($oracle_sid, $user, $pwd);
    $dbc2 = Wyeth::DB::DBConnection::Oracle->instance($oracle_sid, $user, $pwd);
    # these two connection objects will share the same Oracle connection

=head1 DESCRIPTION

Class to manage Oracle database connection.  

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use DBI;
use Carp;

our $VERSION = '1.3.2';

1;
