#! /bin/sh

DIRS=`find . -type d -name 'R160209*'`
for DT in $DIRS
do
    pushd $DT
    echo "-- $DT"
    for READ in 1 2 
    do
	FQF=`ls *R${READ}_001*.fastq.gz`
	FOUT=`basename $DT`_R${READ}.fastq.gz
	cat $FQF > $FOUT
	echo "for READ $READ wrote $FOUT"
    done
    popd
done
