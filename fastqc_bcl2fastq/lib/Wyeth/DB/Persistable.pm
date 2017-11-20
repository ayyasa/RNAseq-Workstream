package Wyeth::DB::Persistable;

=head1 NAME

Wyeth::DB::Persistable

=head1 SYNOPSIS

    use Wyeth::DB::Persistable

=head1 DESCRIPTION

A base class to provide persistence methods for Perl objects. 
This class is inherited by any Perl class that is to be persisted
in the relational database, and provides that class methods for
insert, update, select, and delete operations.

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Wyeth::Util::Utils qw(protlog);
use Wyeth::DB::Config;
use Wyeth::DB::DBInterfaceFactory;
use Data::Dumper;
use Carp;
use warnings 'all';
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

=head2 insert

 Title   : insert
 Usage   : $object->insert(@args);
 Function: Inserts the $object to the database, possibly using optional @args
 Returns : 1 on success, 0 on failure

=cut

sub insert {
    my $self = shift;
    my @args = @_;

    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    $dbi->insert($self, @args);
}    

=head2 delete

 Title   : delete
 Usage   :  $object->delete;
 Function: Deletes the XXX (and all asscociated child entities!) from the database
 Returns : Number of records deleted (expected to be 1)

=cut

sub delete {
    my $self = shift;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    $dbi->delete($self->id);
}

=head2 select

 Title   : select
 Usage   : $object->select($object_id, @args);
 Function: Selects an object from the database, given an object db primary key
           and optionally, other arguments that will be passed to DBI.
 Returns : 1 on success, 0 on failure

=cut

sub select {
    my $self = shift;
    my $object_id = shift;
    my @args = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    my $object;
    unless ($object = $dbi->select($object_id, @args)) {
	return(0);
    }
    print Dumper $object if $Wyeth::DB::Config::VERBOSE>=3;
    @$self{keys %$object} = values %$object;
    return 1;
}

=head2 update

 Title   : update
 Usage   : $object->update;
 Function: Updates an object in relational DB
 Returns : 1 on success, 0 on failure

=cut

sub update {
    my $self = shift;
    my $object_id = $self->id;
    my @args = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    unless ($dbi->update($self)) {
	return(0);
    }
    print Dumper $self if $Wyeth::DB::Config::VERBOSE>=3;
    return 1;
}

=head2 getAll

 Title   : getAll
 Usage   : my @objects = Class->getAll();
 Function: Class method to retrieve list of all objects from the database.
 Returns : list of Objects

=cut

sub getAll {
    my $type = shift;
    my $dbtype = _toClass($type);
    eval "require ${dbtype}${DB_DRIVER}";
    warn $@ if $@;
    my $ret = "${dbtype}${DB_DRIVER}"->getAll;
    my @objects;
    foreach my $row (@$ret) {
        my $object = "${type}"->new();
        $object->setParam( %$row); 
        push @objects, $object;
    }+
    @objects;
}

=head2 selectByName

 Title   : selectByName
 Usage   : $object->selectByName($name);
 Function: Select a previously registered object by db NAME field
 Returns : 1 on success, 0 on failure

=cut

sub selectByName {
    my $self = shift;
    my $object_name = shift;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    # print "class of dbi object returned by DBInterfaceFactory is '" . ref($dbi) . "'\n" if $Wyeth::DB::Config::VERBOSE >= 2;
    my $ret = $dbi->selectByName($object_name);
    if ($ret) {
	$self->setParam(%$ret);
    } else {
	warn "note: OBJECT_NAME = \'$object_name\' does not exist" if $Wyeth::DB::Config::VERBOSE>=2;
	return 0;
    }
    return 1;
}

=head2 selectByCriteria

 Title   : selectByCriteria
 Usage   : my @objects = Class->selectByCriteria( NAME => '= Default MS2 Extraction',
				      STATUS => '= ACTIVE',
				      EXTRACT_MS_RUN_T_ID => '>=37');
 Function: Class method to select objects by literal criteria.  The criteria are literal
           strings and are joined by AND in a SQL WHERE clause.
 Returns : list of objects on success, zero on failure

=cut

sub selectByCriteria {
    my $type = shift;
    my $dbtype = _toClass($type);
    my %criteria = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $DB_DRIVER);
    my $ret = $dbi->selectByCriteria(%criteria);
    my @objects;
    if ($ret) {
	foreach my $row (@$ret) {
	    my $object = "${type}"->new();
	    $object->setParam( %$row); 
	    push @objects, $object;
	}
    } else {
	warn "failed to retrieve in selectByCritiera";
	return 0;
    }
    @objects;
}

=head2 countByCriteria

 Title   : countByCriteria
 Usage   : my $numrecs = Class->countByCriteria( NAME => '= Default MS2 Extraction',
				      STATUS => '= ACTIVE',
				      EXTRACT_MS_RUN_T_ID => '>=37');
 Function: Class method to count objects by literal criteria.  The criteria are literal
           strings and are joined by AND in a SQL WHERE clause.
 Returns : list of objects on success, zero on failure

=cut

sub countByCriteria {
    my $type = shift;
    my %criteria = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $DB_DRIVER);
    my $ret = $dbi->countByCriteria(%criteria);
}

=head2 countAll

 Title   : countAll
 Usage   : my $total_recs = Class->countAll
 Function: Count all objects
 Returns : count of objects on success, zero on failure

=cut

sub countAll {
    my $type = shift;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $DB_DRIVER);
    my $ret = $dbi->countAll;
}

=head2 insertManyTransaction

  Title: insertManyTransaction
  Usage: Class->insertManyTransaction($objectsRef, @args)
  Function: Insert many objects in the array ref $objectsRef as a transaction, rolling back if any failure
  Returns: count of objects inserted on success, zero on failure

=cut

sub insertManyTransaction {
    my $type = shift;
    my $objectsRef = shift;
    my @args = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $DB_DRIVER);
    $dbi->insertManyTransaction($objectsRef, @args);
}

=head2 updateManyTransaction

  Title: updateManyTransaction
  Usage: Class->updateManyTransaction($objectsRef, @args)
  Function: Update many objects in the array ref $objectsRef as a transaction, rolling back if any failure
  Returns: Count of objects updated on success, zero on failure

=cut

sub updateManyTransaction {
    my $type = shift;
    my $objectsRef = shift;
    my @args = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create($type, $DB_DRIVER);
    $dbi->updateManyTransaction($objectsRef, @args);
}

=head2 setParam

  Title: setParam
  Usage: $object->setParam( FOO => 7, BAX => 'lax');
  Function: Generic parameter setting for objects
  Returns: Nothing

=cut

sub setParam {
    my $self = shift;
    my %params = @_;
    @$self{keys %params} = values %params;    
}

=head2 selectIds

 Title   : selectIds
 Usage   : $object->selectIds($object_id, @args);
 Function: Selects a XXX object from the database, given a DATABASE_ID
           and optionally, other arguments that will be passed to DBI.
 Returns : 1 on success, 0 on failure

=cut

#TODO
sub selectIds {
    my $self = shift;
    my @args = @_;
    my $dbi = Wyeth::DB::DBInterfaceFactory->create(ref($self), $DB_DRIVER);
    my $object;
    unless ($object = $dbi->selectIds(@args)) {
	return(0);
    }
    $object;
}

1;
