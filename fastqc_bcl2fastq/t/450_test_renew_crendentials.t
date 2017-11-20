use Test::Simple tests => 1;
use Pfizer::FastQC::Config;
use Pfizer::FastQC::Utils qw(renewCredentials);
use strict;

renewCredentials($Pfizer::FastQC::Config::PROCESS_USER, $Pfizer::FastQC::Config::KEYTAB_FILE);
ok(1, 'renewCredentials');

