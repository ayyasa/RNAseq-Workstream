#! /bin/sh
PATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/bin:${PATH} 
LIBRARY_PATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/lib:${LIBRARY_PATH} 
LIBRARY_PATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/lib64:${LIBRARY_PATH}
LD_LIBRARY_PATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/lib:${LD_LIBRARY_PATH}
LD_LIBRARY_PATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/lib64:${LD_LIBRARY_PATH}
CPATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/include:${CPATH} 
MANPATH=/nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/gcc/4.9.2/share/man:${MANPATH}
APP_ROOT=/hpc/grid/omics_data02/apps
# B2FQ=${APP_ROOT}/bcl2fastq-v2.15.0/bin/bcl2fastq
B2FQ=${APP_ROOT}/bcl2fastq-v2.18.0.12/bin/bcl2fastq
$B2FQ $*
