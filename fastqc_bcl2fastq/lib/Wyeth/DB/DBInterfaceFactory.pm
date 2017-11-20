package Wyeth::DB::DBInterfaceFactory;

=head1 NAME

Wyeth::DB::DBInterfaceFactory

=head1 SYNOPSIS

    use Wyeth::DB::DBInterfaceFactory;
    $dbi_of_type = Wyeth::DB::DBInterfaceFactory->create($type, $db_driver);
    $returned_value = $dbi_of_type->select($id) 
    ..etc..

=head1 DESCRIPTION

A DBInterfaceFactory is a parameterized factory class that generates DBInterface objects.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use warnings 'all';
use Wyeth::DB::Config;
use Carp;
use strict;

sub _toClass {
    my $fully_qualified_name = shift;
    my $class = $fully_qualified_name;
    $class =~ s/^(.+)::([^:]+)$/$1::DBInterface::$2/;
    if ($class) {
	return $class;
    } else {
	confess "failed to parse Class from string: \'$fully_qualified_name\'";
    }
}

=head2 create

  Title: create
  Usage: $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $db_driver);
  Function: Return a new DBInterface object of type DBInterface::$type::$db_driver
  Returns: new DBInterface object of type DBInterface::$type::$db_driver

=cut

sub create {
    my $type = shift;
    my $requested_type = shift;
    my $db_driver = shift;
    
    my $db_type = _toClass($requested_type);
    eval "require ${db_type}${db_driver}";
    warn $@ if $@;
    return "${db_type}${db_driver}"->new;
}

1;
