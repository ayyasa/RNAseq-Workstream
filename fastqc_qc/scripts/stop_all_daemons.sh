#! /bin/tcsh

setenv FQ_LOGDIR `perl -MPfizer::FastQC::Config -e 'print $Pfizer::FastQC::Config::FQ_LOGDIR;'`
echo "using FQ_LOGDIR = $FQ_LOGDIR"

foreach LOG (`ls $FQ_LOGDIR/*.log`)
    echo "stopping daemon ($LOG)"
    setenv MACH `grep "####### on " $LOG | tail -1 | perl -ne 'm/# on (\S+)/; print "$1\n";'`
    setenv PSID `grep "####### process ID" $LOG | tail -1 | perl -ne 'm/process ID = (\d+)/; print "$1\n";'`
    echo "-- stopping process $PSID on $MACH"
    lsrun -m "$MACH" kill $PSID
end




