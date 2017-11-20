use Pfizer::FastQC::BCL2FastqRunFactory;
use Carp;
use strict;

my $b2f_id = shift;
my $b2f = Pfizer::FastQC::BCL2FastqRunFactory->select($b2f_id);
print $b2f->completeMessage(), "\n";
$b2f->sendCompleteMessage;

