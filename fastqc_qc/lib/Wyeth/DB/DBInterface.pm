package Wyeth::DB::DBInterface;

=head1 NAME

Wyeth::DB::DBInterface

=head1 SYNOPSIS

=head1 DESCRIPTION

A base class for database interface to enable persistent storage of 
Perl objects. There will be one subclass of DBInterface 
for each Perl class and database driver (Oracle, Sqlite, etc.).

=head1 AUTHOR

Andrew Hill, Wyeth Research.

=cut

use Wyeth::DB::Config;
use Wyeth::Util::Utils qw(protlog);
use Wyeth::DB::DBConnectionFactory;

use Data::Dumper;
use Carp;
use warnings 'all';
use strict;

our $VERSION = '1.3.2';

sub new {
    my ($type, @args) = @_;
    my $self = {};
    return bless $self, $type;
}

=head2 dbo

  Title: dbo
  Usage: dbo()
  Function: Returns a DBConnection object. Used to localize knowledge of credentials.
  Returns: DBConnection object

=cut

sub dbo {
 my ($user, $pwd) = get_usr_pwd();
 print "$DB_DRIVER:$ORACLE_SID:$user\n" if $Wyeth::DB::Config::VERBOSE>=4;
return Wyeth::DB::DBConnectionFactory->makeInstance($DB_DRIVER, 
						     $ORACLE_SID,
						     $user, $pwd);
}

sub PRIMARY_KEY {
    my $self = shift;
    my $key;
    ($key = $self->TABLE) =~ s/^MT_//;
    $key . '_ID';
}

sub INSERT_STMT {
    my $self = shift;
    my @FIELDS = $self->FIELDS;
    "INSERT INTO " . $self->TABLE . " ( " . join(", ", @FIELDS) . " ) VALUES " .
	"(" . $self->SEQUENCE . ".NEXTVAL, " . join(', ', map {'?'} @FIELDS[1..$#FIELDS]) . ") RETURNING " .
	$self->PRIMARY_KEY . " INTO ?";
}

sub SELECT_STMT {
    my $self = shift;
    "SELECT " . join(", ", $self->FIELDS) . " FROM " . $self->TABLE . " WHERE " . $self->PRIMARY_KEY . " = ?";
}

sub DELETE_STMT {
    my $self = shift;
    "DELETE FROM " . $self->TABLE . " WHERE " . $self->PRIMARY_KEY . " = ?";
}

sub SELECT_ALL_STMT {
    my $type = shift;
    "SELECT * FROM " . $type->TABLE . " ORDER BY " . $type->PRIMARY_KEY . " DESC";
}

sub SELECT_BY_NAME_STMT {
    my $self = shift;
    "SELECT " . join(", ", $self->FIELDS) . " FROM " . $self->TABLE . 
	" WHERE NAME = ?";
}

sub SELECT_BY_CRITERIA_STMT { 
    my $self = shift;
    my %criteria = @_;
    my @where_limits;
    while (my ($u,$v) = each(%criteria)) {
	push @where_limits, "$u $v";
    }
    "SELECT * FROM " . $self->TABLE . " WHERE " . join(" AND ", @where_limits) . " ORDER BY " . $self->PRIMARY_KEY . " DESC";
}
    
sub COUNT_BY_CRITERIA_STMT { 
    my $self = shift;
    my %criteria = @_;
    my @where_limits;
    while (my ($u,$v) = each(%criteria)) {
	push @where_limits, "$u $v";
    }
    "SELECT COUNT(*) FROM " . $self->TABLE . " WHERE " . join(" AND ", @where_limits) . " ORDER BY " . $self->PRIMARY_KEY . " DESC";
}
    
sub COUNT_ALL_STMT { 
    my $self = shift;
    "SELECT COUNT(*) FROM " . $self->TABLE;
}

sub SET_STATUS_STMT {
    my $self = shift;
    "UPDATE " . $self->TABLE . " SET STATUS = ? WHERE " . $self->PRIMARY_KEY . " = ?";
}

sub UPDATE_STMT {
    my $self = shift;
    my @FIELDS = $self->FIELDS;
    @FIELDS = @FIELDS[1..@FIELDS-1];
    "UPDATE " . $self->TABLE . " SET " . join(", ", map {$_." = ?"} @FIELDS) . " WHERE " . $self->PRIMARY_KEY . " = ?";
}

sub  _isSequence_Insert {
    my $stmt = shift;
    if ($stmt =~ m/RETURNING/i) {
	return 1;
    } else {
	return 0;
    }
}

=head2 insert

 Title   : insert
 Usage   : $dbi->insert($object);
 Function: Inserts an object into the database, associating the database 
           id on success
 Returns : True on success

=cut

sub insert {
    my $self = shift;
    my $object = shift;

    my $dbo = dbo(); 
    my $dbh = $dbo->dbh;
    my $sth = $dbh->prepare( $self->INSERT_STMT);
    our @FIELDS = $self->FIELDS;
    $object->setParam(DATE_MODIFIED => $dbo->getDateStamp);
    print Dumper $object if $Wyeth::DB::Config::VERBOSE>=3;
    print $self->INSERT_STMT . "\n" if $Wyeth::DB::Config::VERBOSE>=3;
    
    my $object_id;
    my $usingSequence = _isSequence_Insert($self->INSERT_STMT);
    if ($usingSequence) {
	foreach my $i (1..@FIELDS-1) {
	    $sth->bind_param( $i, $object->{$FIELDS[$i]});
	}
	$sth->bind_param_inout( scalar(@FIELDS), \$object_id, 99);
    } else {
	foreach my $i (0..@FIELDS-1) {
	    $sth->bind_param( $i+1, $object->{$FIELDS[$i]});
	}
    }
    unless ($sth->execute) {
	warn $dbh->errstr;
	return 0;
    }
    if ($usingSequence) {
	$object->set_id($object_id);
	protlog($LOG_FH, "inserted " . ref($object) . " id = $object_id") if $Wyeth::DB::Config::VERBOSE>=2;
    }
    $dbh->commit; 
    return 1;
}    

=head2 select

 Title   : select
 Usage   : $dbi->select($object_id);
 Function: Selects an object from the database, given the object ID
 Returns : A hash reference on success; undefined on failure

=cut

sub select {
    my $self = shift;
    my $object_id = shift;
    my $dbh = dbo()->{'_dbh'};
    print $self->SELECT_STMT . "($object_id)\n" if $Wyeth::DB::Config::VERBOSE>=3;
    my $ret = $dbh->selectrow_hashref( $self->SELECT_STMT, undef, $object_id);
    if (defined($ret)) {
	protlog($LOG_FH, "selected " . ref($self) . " id = $object_id") if $Wyeth::DB::Config::VERBOSE >=3;
    } else {
	warn "warning: " . ref($self) . " = $object_id does not exist";
	return 0;
    }
    $ret;
}

=head2 selectByName

 Title   : selectByName
 Usage   : $dbi->selectByName($object, $object_id);
 Function: SelectByNames an object from the database, given the object ID
 Returns : A hash reference on success; undefined on failure

=cut

sub selectByName {
    my $self = shift;
    my $object_name = shift;
    my $dbh = dbo()->{'_dbh'};
    my $ret = $dbh->selectrow_hashref( $self->SELECT_BY_NAME_STMT, undef, $object_name);
    if (defined($ret)) {
	protlog($LOG_FH, "selected " . ref($self) . " name = $object_name") if $Wyeth::DB::Config::VERBOSE >=3;
    } else {
	warn "warning: " . ref($self) . " = $object_name does not exist" if $Wyeth::DB::Config::VERBOSE>=3;
	return 0;
    }
    $ret;
}

=head2 delete

 Title   : delete
 Usage   :  $dbi->delete($object_id);
 Function: Deletes an object (and all asscociated child entities!) from the database
 Returns : Number of records deleted (expected to be 1)

=cut

sub delete {
    my $self = shift;
    my $object_id = shift; 
    unless (defined($object_id)) {
	warn "cannot delete object with undefined ID";
	return 0;
    }
    my $dbh = dbo()->{'_dbh'};
    my $rowsDeleted = $dbh->do( $self->DELETE_STMT, undef, $object_id);
    if (!defined($rowsDeleted) || $rowsDeleted==0) {
	warn "warning: zero rows were deleted for id = $object_id";
    } else {
	protlog($LOG_FH, "deleted " . ref($self) . " = " . $object_id) if $Wyeth::DB::Config::VERBOSE>=1;
    }
    $dbh->commit;
    return $rowsDeleted;
}

=head2 getDateStamp

 Title   : getDateStamp
 Usage   : my $date_string = $dbi->getDateStamp;
 Function: Retrieve current datestamp
 Returns : String containing datestamp

=cut

sub getDateStamp {
    my $self = shift;
    my $dbo = dbo();
    $dbo->getDateStamp;
}

=head2 getAll

 Title   : getAll
 Usage   : my $arrayref = $dbi->getAll;
 Function: Retrieve list of all objects from the database.
 Returns : Array reference on success, or 0 on failure

=cut

sub getAll {
    my $self = shift;
    my $dbh = dbo()->{'_dbh'};
    my $ret= $dbh->selectall_arrayref( $self->SELECT_ALL_STMT, 
				       { Slice => {}});
    if (!defined($ret)) {
	warn "note: did not select any objects"
	    if $Wyeth::DB::Config::VERBOSE >= 2;
	return 0;
    }
    return $ret;
}

=head2  insertManyTransaction

  Title:  insertManyTransaction
  Usage:  $dbi->insertManyTransaction($objectsRef, @args)
  Function: Insert many objects as transaction, rollback if any failure
  Returns: count of objects inserted on success, zero on failure

=cut

sub insertManyTransaction {
    my $self = shift;
    my $objectsRef = shift;
    my @args = @_;
    
    my $dbh = dbo()->{'_dbh'};

    $dbh->{RaiseError} = 1;
    my $numInserts = 0;
    eval {
	$dbh->commit; # start transaction
	foreach my $obj (@$objectsRef) {
	    $obj->insert;
	    $numInserts++;
	}
	$dbh->commit;
    };
    if ($@) {
	warn "Transaction aborted because $@";
	eval { $dbh->rollback };
	return 0;
    }
    $dbh->{RaiseError} = 0;
    return $numInserts;
}

=head2 update

 Title   : update
 Usage   : $dbv->update($object)
 Function: Updates object in relational db
 Returns : 1 on success, 0 on failure

=cut

sub update {
    my $self = shift;
    my $object = shift;
    my $dbo = dbo();
    my $dbh = $dbo->dbh;
    $object->{'DATE_MODIFIED'} = $dbo->getDateStamp(); 
    my $sth = $dbh->prepare( $self->UPDATE_STMT);
    our @FIELDS = $self->FIELDS;
    foreach my $i (1..@FIELDS-1) {
	$sth->bind_param( $i, $object->{$FIELDS[$i]});
    }
    $sth->bind_param(scalar @FIELDS, $object->id);
    if ($sth->execute) {
	protlog($LOG_FH, "updated " . ref($object) . " = " . $object->id) if $Wyeth::DB::Config::VERBOSE>=1;
	$dbh->commit; # TODO: remove this and handle explicitly by $dbo->dbh->commit
	return 1;
    } else {
	warn $dbh->errstr;
	return 0;
    }
}    


=head2 selectByCriteria

 Title   : selectByCriteria
 Usage   : $dbi->selectByCriteria( NAME => 'Default MS2 Extraction',
				      STATUS => 'ACTIVE');
 Function: Select objects by criteria
 Returns : list of hashrefs on success, zero on failure

=cut

sub selectByCriteria {
    my $self = shift;
    my %criteria = @_;
    my $dbh = dbo()->{'_dbh'};
    print($self->SELECT_BY_CRITERIA_STMT(%criteria), "\n") if $Wyeth::DB::Config::VERBOSE>=3;
    my $ret= $dbh->selectall_arrayref( $self->SELECT_BY_CRITERIA_STMT(%criteria), 
				       { Slice => {}});
    if (!defined($ret)) {
	warn "note: did not select any objects"
	    if $Wyeth::DB::Config::VERBOSE >= 2;
	return 0;
    }
    return $ret;
}

=head2 countByCriteria

 Title   : countByCriteria
 Usage   : $dbi->countByCriteria( NAME => 'Default MS2 Extraction',
				      STATUS => 'ACTIVE');
 Function: Select objects by criteria
 Returns : count of objects on success, zero on failure

=cut

sub countByCriteria {
    my $self = shift;
    my %criteria = @_;
    my $dbh = dbo()->{'_dbh'};
    my $ret= $dbh->selectrow_arrayref( $self->COUNT_BY_CRITERIA_STMT(%criteria), 
				       { Slice => {}});
    if (!defined($ret)) {
	warn "note: did not select any objects"
	    if $Wyeth::DB::Config::VERBOSE >= 2;
	return 0;
    }
    return $ret->[0];
}

=head2 countAll

 Title   : countAll
 Usage   : $dbi->countAll
 Function: Count all objects in database
 Returns : list of objects on success, zero on failure

=cut

sub countAll {
    my $self = shift;
    my $dbh = dbo()->{'_dbh'};
    my $ret= $dbh->selectrow_arrayref( $self->COUNT_ALL_STMT, 
				       { Slice => {}});
    if (!defined($ret)) {
	warn "note: did not select any objects"
	    if $Wyeth::DB::Config::VERBOSE >= 2;
	return 0;
    }
    return $ret->[0];
}

sub dbh {
    my $self = shift;
    my $dbo = dbo();
    $dbo->dbh;
}

1;
