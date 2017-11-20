use Pfizer::FastQC::Config;
use Pfizer::FastQC::BCL2FastqRunFactory;
use Pfizer::FastQC::ReadCleanRunFactory;
use Pfizer::FastQC::QCReportFactory;
use Pfizer::FastQC::Utils qw(recipient_list);
use Wyeth::Util::Utils qw(sendmail);
use Test::Simple tests => 6;
use Carp;
use Data::Dumper;
use strict;

my $b2f = Pfizer::FastQC::BCL2FastqRunFactory->select(4);
print $b2f->startMessage(), "\n";
ok(1);
#$b2f->sendStartMessage;
#ok(1);
print $b2f->completeMessage(), "\n";
ok(1);
#$b2f->sendCompleteMessage;
#ok(1);

my $msg = $b2f->startMessage;
my $sg = $b2f->getSampleGroup;
my $first_email = $sg->userName;
my $multi_address = 'archana.ayyaswamy@pfizer.com';

print $multi_address;
#sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
#             $Pfizer::FastQC::Config::APPLICATION_EMAIL,
#             recipient_list($multi_address),
#             "Started fastq extraction for BCL directory (test-multi email)",
#             $b2f->startMessage);

my $rcr = Pfizer::FastQC::ReadCleanRunFactory->select(22);
print $rcr->startMessage(), "\n";
ok(1);
print $rcr->completeMessage(), "\n";
ok(1);

my $qcr =  Pfizer::FastQC::QCReportFactory->select(468);
print $qcr->startMessage(), "\n";
ok(1);
print $qcr->completeMessage(), "\n";
ok(1);
#$qcr->sendCompleteMessage();
#ok(1);
