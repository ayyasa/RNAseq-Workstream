use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(sendBailMsg);
use Test::Simple tests => 1;
use strict;

sendBailMsg($Pfizer::FastQC::Config::ADMIN_EMAIL, 'This is a test daemon bail message.');
ok(1, 'sendBailMsg');

