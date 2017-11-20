# FASTQC configuration
setenv FQ_DEV_ROOT `pwd`/lib
setenv FQ_CONFIG `pwd`/config
setenv PROT_SID /hpc/grid/omics_data03/fastqc/geatd_dev
setenv PROT_USER SRVCEW_FASTQCUSER
setenv MM_DB_DRIVER '::Sqlite'
setenv PROT_PASS ''

#set PATH for PERL executable that contains needed dependencies
#setenv PATH /afs/grid.pfizer.com/apps/Linux-x86_64/shared/perl/5.14.1/bin:${PATH}
setenv PATH /nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/perl/5.20.0/bin:${PATH}

#module load RHEL6-apps
#module load perl/5.20.0


# Paths for perl libraries
setenv APP_ROOT /hpc/grid/omics_data02/apps
setenv DEV_PERL_LIB /afs/grid.pfizer.com/alds/projects/dev/perllib

#setenv SHARED_PERL_LIB /nfs/grid/software/hpcc/apps/Linux-x86_64-RHEL6/perl/5.20.0/lib/site_perl

if (! ($?SHARED_PERL_LIB)) then
  setenv SHARED_PERL_LIB ${DEV_PERL_LIB}:${APP_ROOT}/perl5.14/lib:${APP_ROOT}/perl5.14/lib/site_perl:${APP_ROOT}/perl5.14/lib/perl5
endif
if (! ($?PERL5LIB)) then
   setenv PERL5LIB ${FQ_DEV_ROOT}:${SHARED_PERL_LIB}
else
   setenv PERL5LIB ${FQ_DEV_ROOT}:${SHARED_PERL_LIB}:${PERL5LIB}
endif
