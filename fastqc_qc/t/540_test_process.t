use Pfizer::FastQC::Process;
use Test::Simple tests => 1;
use Carp;
use Data::Dumper;
use strict;


my @proc_rec = Pfizer::FastQC::Process->getAll();
print Dumper \@proc_rec;
foreach my $proc (@proc_rec){
	print $proc->process_name(), '\n';
}
my $proc = new Pfizer::FastQC::Process();
$proc->select(23);
print Dumper $proc;

ok(1, 'Process->getAll');




