use Test::Simple tests => 1;

use Pfizer::FastQC::Utils qw(makeTemplateHTML);
use strict;

makeTemplateHTML('data/fastqc_report.html', 2);
ok(1, 'test_makeTemplateHTML');
