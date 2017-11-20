#! /bin/sh

echo 'delete from qt_bcl_directory;' | ~/sqlite3 geatd
echo 'delete from qt_sample_group;' | ~/sqlite3 geatd
echo 'delete from qt_sample;' | ~/sqlite3 geatd
echo 'delete from qt_bcl2fastq_run;' | ~/sqlite3 geatd
echo 'delete from qt_raw_fastq_file;' | ~/sqlite3 geatd
echo 'delete from qt_readclean_run;' | ~/sqlite3 geatd
echo 'delete from qt_clean_fastq_file;' | ~/sqlite3 geatd
echo 'delete from qt_qcrep_2_fastq;' | ~/sqlite3 geatd
echo 'delete from qt_qc_report;' | ~/sqlite3 geatd




