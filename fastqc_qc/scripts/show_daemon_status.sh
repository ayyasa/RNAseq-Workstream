#!/bin/sh

FQ_LOGDIR=`perl -MPfizer::FastQC::Config -e 'print $Pfizer::FastQC::Config::FQ_LOGDIR;'`
echo "using FQ_LOGDIR = $FQ_LOGDIR"

echo "The following reports on the FastQC daemon processes (register, extract_ms, and search)"
echo "that log to the directory $FQ_LOGDIR."
echo "Under each daemon below, you should see an active process ID.  If you see a missing line,"
echo "that indicates a daemon has gone down.  To fix this, follow the instructions in the Masstermine"
echo "admin guide, in the section 'Starting System Daemons'." 
for LOG in `ls $FQ_LOGDIR/*.log` 
do
    echo "-----------------"
    echo $LOG | perl -ne 'm/([^\/]+)\.log$/; print "daemon: $1\n";'
    echo "-----------------"   
    MACH=`grep "####### on " $LOG | tail -1 | perl -ne 'm/# on (\S+)/; print "$1\n";'`
    PSID=`grep "####### process ID" $LOG | tail -1 | perl -ne 'm/process ID = (\d+)/; print "$1\n";'`
    if ps -o uid,pid,stime,time,pmem,pcpu,cmd -p $PSID > /dev/null
    then
	echo "process $PSID on $MACH"
	lsrun -m "$MACH" ps -o uid,pid,stime,time,pmem,pcpu,cmd -p $PSID
    else
	echo "Daemon not running."
    fi
	echo "-----------------"
done




