use ExtUtils::MakeMaker;

sub MY::postamble {
    return << "MAKE_FRAG";
install_svn: INSTALLDIR=/hpc/grid/omics_data04/appsdev/fastqc
install_svn: REPO_URL=https://pfizer.collab.net/svn/repos
install_svn:
	svn export --force \$(REPO_URL)/fastqc/trunk/perl \$(INSTALLDIR)
MAKE_FRAG
}

WriteMakefile(
	      NAME => 'Pfizer::FastQC',
	      VERSION => '1.0.1',
	      AUTHOR => 'Andrew Hill',
	      ABSTRACT => 'Automated demltiplexing and FASTQC for Illumina RNASeq data'
	      );

