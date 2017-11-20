package Pfizer::FastQC::Utils;

use warnings 'all';
use strict;
use Exporter;
use Carp;
use XML::Twig;
use Data::Dumper;
use Pfizer::FastQC::Config;
use Wyeth::Util::Utils qw(protlog sendmail);
use Scalar::Util qw(looks_like_number);

our $VERSION = '1.0.0';
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/makeTemplateHTML  insertModulePlots parseFastqcData
buildListMapper parseSampleSheet generate_qc_report buildMultiFastqcDataStruct 
allSamplesPassedModule getGroupQcStatus run_fastqc _trim1_cmd getIconSrc
seqtk_cmd bowtie_cmd parse_bowtie_summary_table contamAlign
supportText _round recipient_list contamAlignParallel renewCredentials
validate_sample_name sendBailMsg bail/;

my @png_orig_size = (1125, 600);
my $scale_factor = 0.45;
my %IMG_SRC;
my $titleText = "Pfizer FastQC Report";

my %modNameLookup = (
    M0 => 'Basic Statistics',
    M1 => 'Per base sequence quality',
    M2 => 'Per tile sequence quality',
    M3 => 'Per sequence quality scores',
    M4 => 'Per base sequence content',
    M5 => 'Per sequence GC content',
    M6 => 'Per base N content',
    M7 => 'Sequence Length Distribution',
    M8 => 'Sequence Duplication Levels',
    M9 => 'Overrepresented sequences',
    M10 => 'Adapter Content',
    M11 => 'Kmer Content',
    M12 => 'Percent Globin/rRNA Contamination'
    );

=head2 validate_sample_names

 Title   : validate_sample_names
 Usage   : 
  Function: 
 Returns : 

=cut

sub validate_sample_name {
    my $name = shift;
    if (($name =~ m/$Pfizer::FastQC::Config::BAD_CHARS/) || ($name eq '')) {
	return 0;
    }
    return 1;
}


sub get_ReadCleanRun_ID{

    

}

=head2 parseSampleSheet

 Title   : parseSampleSheet
 Usage   : my $href = parseSampleSheet($sample_sheet_file)
  Function: Parse a BCL folder sample sheet
 Returns : hashref containing parsed data

=cut

sub parseSampleSheet {
    my $infile = shift;
    open IN, "<$infile" or confess "cannot open $infile: $!";
    my $href;
    my $section;
    # local $/ = "\r\n";
    while (my $line = <IN>) {
	chomp $line;
	$line =~ s/\r?$//;
	# print "parsed: $line\n";
	next if ($line !~ m/[^,]/);
	if ($line =~ m/^\[([^\]]+)\]/) {
	    $section = $1;
	    $href->{$section} = [];
	    next;
	}
	my @f = split(",", $line);
	push @{$href->{$section}}, [@f];
    }
    close IN;
    $href;
}

=head2 buildListMapper

 Title   : buildListMapper
 Usage   : my $list_mapper = buildListMapper(@dirlist) 
 Function: Parse FASTQC data.txt files (one file per input @dirlist).
 Returns : A hashref containing paths to input files or images
                 for each input directory
=cut

sub buildListMapper {
    # transform list of unzipped FASTQC directories 
    # to a list_mapper structure, suitable as input to
    # insertModulePlots
    my @dirlist = @_;
    my $list_mapper = {};
    foreach my $dir (@dirlist) {
	my $img_root = "$dir/Images";
	my $sample_root = $dir;
	my $per_base_quality = "$img_root/per_base_quality.png";
	my $per_tile_sequence_quality = "$img_root/per_tile_quality.png";
	my $per_sequence_quality = "$img_root/per_sequence_quality.png";
	my $adaptor_content = "$img_root/adapter_content.png";
	my $duplication_levels = "$img_root/duplication_levels.png";
	my $kmer_profiles = "$img_root/kmer_profiles.png";
	my $per_base_n_content = "$img_root/per_base_n_content.png";
	my $per_base_sequence_content = "$img_root/per_base_sequence_content.png";
	my $per_sequence_gc_content = "$img_root/per_sequence_gc_content.png";
	my $sequence_length_distribution = "$img_root/sequence_length_distribution.png";

	push @{$list_mapper->{'M0'}}, $sample_root;
	push @{$list_mapper->{'M1'}}, $per_base_quality;
	push @{$list_mapper->{'M2'}},  $per_tile_sequence_quality;
	push @{$list_mapper->{'M3'}}, $per_sequence_quality;
	push @{$list_mapper->{'M4'}}, $per_base_sequence_content;
	push @{$list_mapper->{'M5'}}, $per_sequence_gc_content;
	push @{$list_mapper->{'M6'}}, $per_base_n_content;
      	push @{$list_mapper->{'M7'}}, $sequence_length_distribution;
	push @{$list_mapper->{'M8'}}, $duplication_levels;
      	push @{$list_mapper->{'M9'}}, $sample_root;
      	push @{$list_mapper->{'M10'}}, $adaptor_content;
	push @{$list_mapper->{'M11'}}, $kmer_profiles;
	push @{$list_mapper->{'M12'}}, $sample_root; # TODO
}      
    $list_mapper;
}

sub makeTemplateHTML {
    my $inreport = shift;
    my $numSamples = shift;
    
    my $t = XML::Twig->new( 
	twig_handlers => 
	{ 
	    'body/div[@class = "main"]/div[@class = "module"]' => 
		sub { my @els = $_->children();
		      foreach my $i (1..(@els-1)) {
			  $els[$i]->delete();
		      }
	    },
	    'body/div[@class="header"]/div[@id="header_filename"]' => 
		sub { $_->set_text(sprintf("$titleText generated at %s", scalar(localtime)));}
	},
	pretty_print => 'indented',
	empty_tags => 'html'
	);

    $t->parsefile($inreport);
    $t->print;
}

=head2 insertModulePlots

 Title   : insertModulePlots
 Usage   : insertModulePlots($in_template, $module_mapper)
 Function: Generate the final HTML report
 Returns : XML text of the HTML report.  

=cut

sub insertModulePlots {
    my $intemplate = shift;
    my $module_mapper = shift;
    my $mref = shift;

    my $nsamples = scalar(@{$module_mapper->{'M0'}});
    my $nrows = int($nsamples/2);
    my $ncols = 2;
    my $pindex = 0;

    my $module_handler = sub {
	my ($twig, $preceeding) = @_; # $_; # ->first_child('h2');
	my $module_name = $preceeding->att('id');
	my $mname = $modNameLookup{$module_name};
	print STDERR "found $module_name\n";
	# Insert module-dependent image grid or table
	if ($module_name ne 'M0' && $module_name ne 'M9' && $module_name ne 'M12') {
	    my $tbl;
	    if ($module_name eq 'M10') { # Adapter content
		if (allSamplesPassedModule($module_name, $mref)) {
		    # suppress output
		    $tbl = XML::Twig::Elt->new('h3');
		    $tbl->set_text("All $nsamples runs passed module '$mname', so output has been suppressed");
		} else { # Some failed M10, show it 
		    $tbl = buildImageGrid($module_mapper, $module_name, $nrows, $ncols);
		}
	    } elsif ($module_name eq 'M7') { # Sequence length distribution
		my $check_module = 'M10';
		if (allSamplesPassedModule($check_module, $mref)) {
		    # suppress output
		    $tbl = XML::Twig::Elt->new('h3');
		    $tbl->set_text("All $nsamples runs passed module '" . $modNameLookup{$check_module} . 
				   "', so output has been suppressed");
		} else { # Some failed M10, show it 
		    $tbl = buildImageGrid($module_mapper, $module_name, $nrows, $ncols);
		}
	    } else {
		$tbl = buildImageGrid($module_mapper, $module_name, $nrows, $ncols);
	    }
	    $tbl->paste( after => $preceeding);
	} else { # end non-M0,M9 (image inserts)
	    my $tbl;
	    if ($module_name eq 'M0') {
		$tbl = renderTableM0($module_name, $module_mapper);
		#$tbl->paste( after => $preceeding);
		# close the table out
	    } elsif  ($module_name eq 'M9') {
		$tbl = renderTableM9($module_name, $module_mapper);
		#$tbl->paste( after => $preceeding);
	    } elsif ($module_name eq 'M12') {
		# TODO
		my $txt = XML::Twig::Elt->new('h3');
		$txt->set_text("The table shows the percentage of a sample of $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE" .
			       " reads that mapped to the corresponding species/order.");
		$txt->paste( after => $preceeding);
		$tbl = renderTableM0($module_name, $module_mapper);
	    } else {
		confess "unknown module name '$module_name'";
	    }
	  $tbl->paste(  after => $preceeding);
	} # end else
	# Update the module summary icon
	my $target_icon = $preceeding->first_child('img');
	my $grp_status = getGroupQcStatus($module_name, $mref);
	my $target_src = getIconSrc($grp_status);
	$target_icon->set_att(src => $target_src);
	$target_icon->set_att(alt => ('[' . $grp_status . ']'));
	print STDERR "set status for module '$module_name' to '$grp_status'\n";
    }; # end sub

my $summary_handler = sub {
    my ($twig, $elt) = @_; 
    my $module_str = $elt->first_child('a')->att('href');
    my ($module_name) = ($module_str =~ m/(M\d+)/);
    my $grp_status = getGroupQcStatus($module_name, $mref);
    my $target_src = getIconSrc($grp_status);
    my $target_icon = $elt->first_child('img');
    $target_icon->set_att(src => $target_src);
    $target_icon->set_att(alt => ('[' . $grp_status . ']'));
    print STDERR "set summary status for module '$module_name' to '$grp_status'\n";
}; # end sub

    my $t = XML::Twig->new( 
	twig_handlers => 
	{ 
	    "div[\@class='module']/h2[\@id =~ /M\\d+/]" => $module_handler,
	    'body/div[@class="header"]/div[@id="header_filename"]' => 
		sub { $_->set_text(sprintf("$titleText generated at %s (%d sample-reads)", 
					   scalar(localtime), $nsamples));},
	    'head/title' => 
		sub { $_->set_text(sprintf("$titleText generated at %s (%d sample-reads)", 
					   scalar(localtime), $nsamples));},
	     "div[\@class='summary']/ul/li" => $summary_handler
	},
	pretty_print => 'indented',
	empty_tags => 'html'
	);
    $t->parsefile($intemplate);
    return $t->sprint;
}

sub getIconSrc {
    my $name = shift;
    if (!defined($IMG_SRC{$name})) {
	my $src;
	unless (defined($Pfizer::FastQC::Config::IMG_SRC{$name})) {
	    confess "unknown icon name '$name'";
	}
	open ICON, "<$Pfizer::FastQC::Config::IMG_SRC{$name}";
	while (<ICON>) {
	    chomp;
	    $src .= $_;
	}
	close ICON;
	$IMG_SRC{$name} = $src;
    }
    $IMG_SRC{$name};
}

    
sub getIconFromTwig {
    my $twig = shift;
    my $grp_status = shift;
    my @imgs = $twig->find_by_tag_name('img');
    my $target_src;
    my $found = 0;
    # $twig->print;
    foreach my $img (@imgs) {
	if ($img->att('alt') =~ m/$grp_status/) {
	    $target_src = $img->att('src');
	    print STDERR "located an image in template with status $grp_status!\n";
	    $found++;
	    last;
	}
    }
    if (! $found) {
	warn "failed to find an icon for status $grp_status in the template!";
    }
    $target_src;
}

sub getGroupQcStatus {
    my $module_name = shift;
    my $mref = shift;
    my %statCounts;
    my $mname = $modNameLookup{$module_name};
    foreach my $samp (keys %$mref) {
	if (defined($mref->{$samp}->{$mname}->{'status'})) {
	    my $stat = $mref->{$samp}->{$mname}->{'status'};
	    $statCounts{$stat}++;
	} elsif ($mname eq $modNameLookup{'M12'}) { # TODO
	    $statCounts{'PASS'}++;
	} else {
	    warn "failed to get status for sample '$samp', module '$mname' ($module_name)";
	    $statCounts{'FAIL'}++;
	}  
    }
    if (defined($statCounts{'fail'})) {
	return('FAIL');
    } elsif (defined($statCounts{'warn'})) {
	return('WARN');
    } else {
	return('PASS');
    }
}

sub getQcImageByStatus {
    my $status = shift;
}

sub buildImageGrid {
    my $module_mapper = shift;
    my $module_name = shift;
    my $nrows = shift;
    my $ncols = shift;

    my $pindex = 0;
    my $tbl = XML::Twig::Elt->new( table => { 
	align => 'center',
	border => 1});
    my ($klab, $kimg) = (0, 0);
    foreach my $i (1..$nrows) {
	my $trt = XML::Twig::Elt->new( 'tr');
	#print STDERR "adding row\n";
	# insert header row
	foreach my $j (1..$ncols) {
	    # needed to determine QC status flag for all runs
	    my $href = parseFastqcData($module_mapper->{'M0'}->[$klab]);
	    my $mname = $modNameLookup{$module_name};
	    # print "seeking: href -> $mname\n";
	    if (!defined($href->{$mname})) {
		warn "cannot find href -> $mname";
	    }
	    my $td_class = 'fail_td';
	    if ($href->{$mname}->{'status'} eq 'pass') {
		$td_class = 'pass_td';
	    } elsif ($href->{$mname}->{'status'} eq 'warn') {
		$td_class = 'warn_td';
	    }
	    my $td = XML::Twig::Elt->new('td' => { class => $td_class });
	    $td->set_text(imgPath2FastqName($module_mapper->{$module_name}->[$klab++]));
	    $td->paste( last_child => $trt);
	}
	$trt->paste(last_child => $tbl);
	# insert all plots on the row
	my $tr = XML::Twig::Elt->new( 'tr');
	foreach my $j (1..$ncols) {
	    my $td = XML::Twig::Elt->new('td');
	    # print STDERR $pindex . "\n";
	    my $img = XML::Twig::Elt->new(img => { src => imgPath2RelPath($module_mapper->{$module_name}->[$kimg++]),
						   height => $png_orig_size[1] * $scale_factor,
						   width => $png_orig_size[0] * $scale_factor
					  });
	    $img->paste(first_child => $td);
	    $pindex++;
	    # print STDERR "adding cell..\n";
	    $td->paste( last_child => $tr);
	}
	$tr->paste(last_child => $tbl);
    }
    $tbl;
}


=head2 renderTableM0

 Title   : renderTableM0
 Usage   : my $twig_tbl = renderTableM0($module_name, $module_mapper)
 Function: Generate the Twig containing HTML table for Module 0 (Basic Statistics)
 Returns : Twig object containing HTML table

=cut

sub renderTableM0 {
    # transpose/transform individual sample tables
    # to a single table
    my $module_name = shift;
    my $module_mapper = shift;

    my $mname = $modNameLookup{$module_name};
    # for these, need to assemble and insert tabular data
    my @infiles = @{$module_mapper->{$module_name}};
    # append the table header
    my $tbl = XML::Twig::Elt->new( table => { 
	align => 'center',
	border => 1});
    my $thead = XML::Twig::Elt->new( 'thead');
    my $tr = XML::Twig::Elt->new( 'tr');
    my $href = parseFastqcData($infiles[0]);
    # print Dumper $href;
    my @hels = map { $_->[0]} @{$href->{$mname}->{'rows'}};
    foreach my $i (0..(@hels-1)) {
	my $th = XML::Twig::Elt->new('th');
	$th->set_text($hels[$i]);
	$th->paste(last_child => $tr);
    }
    $tr->paste(first_child => $thead);
    $thead->paste(first_child => $tbl);
    foreach my $i (0..(@infiles-1)) {
	$href = parseFastqcData($infiles[$i]);
	# append the rows to table
	my $tr = XML::Twig::Elt->new( 'tr');
	my @rows = @{$href->{$mname}->{'rows'}};
	foreach my $j (0..(@rows-1)) {
	    my $el = $rows[$j]->[1];
	    #foreach my $el (@{$rows[$j]}) {
		my $td = XML::Twig::Elt->new('td');
		$td->set_text(looks_like_number($el) ? _round($el,3) : $el);
		$td->paste( last_child => $tr);
	    #}
	}
	$tr->paste( last_child => $tbl);
    }
    $tbl;
}

=head2 renderTableM9

 Title   : renderTableM9
 Usage   : my $twig_tbl = renderTableM9($module_name, $module_mapper)
 Function: Generate the Twig containing HTML table for Module M9
 Returns : Twig object containing HTML table

=cut

sub renderTableM9 {
    # simple transform for M9
    my $module_name = shift;
    my $module_mapper = shift;

    my $mname = $modNameLookup{$module_name};
    # for these, need to assemble and insert tabular data
    my @infiles = @{$module_mapper->{$module_name}};
    # append the table header
    my $tbl = XML::Twig::Elt->new( table => { 
	align => 'center',
	border => 1});
    my $thead = XML::Twig::Elt->new( 'thead');
    my $tr = XML::Twig::Elt->new( 'tr');
    my $href = parseFastqcData($infiles[0]);
    my @hels = ('Sample', 'Sequence', 'Count', 'Percentage', 'Possible Source');
    my @rows = @{$href->{$mname}->{'rows'}};
    if (@rows) {
	foreach my $i (0..(@hels-1)) {
	    my $th = XML::Twig::Elt->new('th');
	    $th->set_text($hels[$i]);
	    $th->paste(last_child => $tr);
	}
	$tr->paste(first_child => $thead);
	$thead->paste(first_child => $tbl);
	foreach my $i (0..(@infiles-1)) {
	    $href = parseFastqcData($infiles[$i]);
	    # append the rows to table
	    foreach my $j (0..(@rows-1)) {
		my $tr = XML::Twig::Elt->new( 'tr');
		my $td = XML::Twig::Elt->new('td');
		my $short_file = shorten_file($infiles[$i]);
		$td->set_text($short_file);
		$td->paste( last_child => $tr);
		foreach my $el (@{$rows[$j]}) {
		    $td = XML::Twig::Elt->new('td');
		    $td->set_text($el);
		    $td->paste( last_child => $tr);
		}
		$tr->paste( last_child => $tbl);
	    }
	}
    } else {
	# empty table
	$tbl = XML::Twig::Elt->new('h3');
	$tbl->set_text('No overrepresented sequences were found');
    }
    $tbl;
}

sub imgPath2FastqName {
    my $inpath = shift;
    my $short_file = $inpath;
    ($short_file) = ($inpath =~ m/([^\/]+)_fastqc\/Images/);
    $short_file
}

sub imgPath2RelPath {
    my $inpath = shift;
    my $short_file = $inpath;
    ($short_file) = ($inpath =~ m/([^\/]+_fastqc\/.+$)/);
    $short_file
}

sub shorten_file {
    my $inpath = shift;
    my $short_file = $inpath;
    ($short_file) = ($inpath =~ m/([^\/]+)_fastqc$/);
    $short_file;
}

=head2 parseFastqcData

 Title   : parseFastqcData
 Usage   : parseFastqcData($fastq_dir)
 Function: Parse the fastqc_data.txt file from a FASTQC report directory
 Returns : A hashref containing the parsed data (keys are modules Mx)

=cut


sub parseFastqcData  {
    my $rootDir = shift;
    my $href;
    my $infile = join("/", $rootDir, "fastqc_data.txt");
    open IN, "<$infile" or confess "cannot open $infile: $!";
    my $curr_module;
    my @heads;
    my @rows;
    my $line;
    my $inline;
    my $curr_status = 'not_set';
    while (<IN>) {
	chomp;
	$inline = $_;
	next if (m/^##/);
	if (m/^>>(.+)$/) {
	    $line = $1;
	    if ($line =~ m/END_MODULE/) {
		# end, load the global data
		$href->{$curr_module}->{'status'} = $curr_status;
		$href->{$curr_module}->{'head'} = [@heads];
		$href->{$curr_module}->{'rows'} = [@rows];
		# clear the status, heads, rows
		@heads = ();
		@rows = ();
		$curr_status = 'not_set';
	    } else {
		# beginning, capture module name and status
		$line =~ m/([^\t]+)\t([^\t]+)$/;
		($curr_module, $curr_status) = ($1, $2);
	    }
	} else {
	    if (m/^#([^#]+)/) {
		# header row
		my $headline = $1;
		@heads = split("\t", $headline);
	    } else {
		# table data row
		push @rows, [ split("\t", $inline) ];
	    }
	}
    }	
    close IN;
    $href = parseContamAlignReport($rootDir, $href);
    $href;
}

sub parseContamAlignReport {
    my $rootDir = shift;
    my $href = shift;
    my $infile = join("/", $rootDir, "contam_report.txt");
    open IN, "<$infile" or confess "cannot open $infile: $!";
    my $curr_module =  'Percent Globin/rRNA Contamination'; # 'M12';
    my @heads = ('Sample', 'Organism Order', 'Percent_reads');
    my @rows;
    my $line;
    my $inline;
    while (<IN>) {
	chomp;
	push @rows, [ split("\t", $_) ];
    }
    close IN;
    $href->{$curr_module}->{'status'} = 'pass';
    $href->{$curr_module}->{'head'} = [@heads];
    $href->{$curr_module}->{'rows'} = [@rows];
    $href;
}


sub buildMultiFastqcDataStruct {
    my @dirlist = @_;
    my $href = {};
    foreach my $dir (@dirlist) {
	$href->{$dir} = parseFastqcData($dir) 
    }
    $href;
}

sub allSamplesPassedModule {
    my $module = shift;
    my $mref = shift;
    my $all_passed = 1;
    my $npass = 0;
    my @stati = ();
    my $stat;
    my $mname = $modNameLookup{$module};
    foreach my $samp (keys %$mref) {
	if (defined($mref->{$samp}->{$mname}->{'status'})) {
	    $stat = $mref->{$samp}->{$mname}->{'status'};
	    push @stati, $stat;
	    if ($stat eq 'pass') {
		$npass++;
	    } else {
		$all_passed = 0;
		last;
	    }
	} else {
	    confess "failed to get status for module $module";
	}
	# print join("\t", $mname, shorten_file($samp), $stat), "\n";
    }
    $all_passed;
}

sub generate_qc_report {
    my @dirlist = @_;
    my $TEMPLATE = '/afs/grid.pfizer.com/alds/projects/dev/fastqc/perl/data/template.html';
    my $list_mapper = buildListMapper(@dirlist);
    my $mref = buildMultiFastqcDataStruct(@dirlist);
    insertModulePlots($TEMPLATE, $list_mapper, $mref);
}
    
sub run_fastqc {
    my $output_dir = shift;
    my $extract = shift;
    my $format = shift;
    my $fastqref = shift;
    my $log_stub = shift;

    # TODO: parallelize if @$fastqref>1
    my $job_array = "fqr_$$";
    foreach my $i (1..@$fastqref) {
	my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-J \"${job_array}_$i\"",
	       "-o ${log_stub}_$i.out",
	       "-e ${log_stub}_$i.err",
	       $Pfizer::FastQC::Config::FASTQC_EXE,
	       "-o $output_dir",
	       $extract ? "--extract" : "--noextract",
	       "-f $format",
	       "'" . $fastqref->[$i-1] . "'");
              # map { "'" . $_ . "'"} @$fastqref); # Protect spaces in paths
	protlog($LOG_FH, "Will execute command: " . join("\n", @cmd)) if $VERBOSE>=1;
	unless (system(join(" ", @cmd))==0) {
	    confess "failed to run command " . join(" ", @cmd);
	}
    } # end input fastqs
    my @hold_cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
		    "-K",
		    "-J fastqc_hold",
		    "-w \'done(\"$job_array*\")\'",
		    "-o ${log_stub}_hold.out",
		    "-e ${log_stub}_hold.err",
		    "sleep 30");
    unless (system(join(" ", @hold_cmd))==0) {
	confess "failed to run command " . join(" ", @hold_cmd);
    }
    my @output_dirs = map { $_ =~ s/(^.+\/)([^\/]+)\.f(ast)?q.gz$/$output_dir\/$2_fastqc/; $_ } @$fastqref;
    @output_dirs;
}


sub _trim1_cmd {
    my $infasta = shift;
    my $outfasta = shift;
    my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-K",
	       "-n 16",
	       "-J TRIM_Free",
	       "-o trim_log.out",
	       "-e trim_log.err",
	       $Pfizer::FastQC::Config::TRIM_EXE_STUB,
	       'SE',
	       # "-threads $threads",
	       # "-phred64",
	       # "-trimlog $trim_log",
	       $infasta,
	       $outfasta,
	       @Pfizer::FastQC::Config::DEFAULT_STEP);
    @cmd;
}

sub seqtk_cmd {
    my $infasta = shift;
    my $num_sample = shift;
    my $outfile = shift;
    my $psid = $$;
    my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-K",
	       "-n 1",
	       "-J seqtk_sample_$$",
	       "-o ${Pfizer::FastQC::Config::FQ_TMPDIR}/seqtk_${psid}_log.out",
	       "-e ${Pfizer::FastQC::Config::FQ_TMPDIR}/seqtk_${psid}_log.err",
	       "\'",
	       $Pfizer::FastQC::Config::SEQTK_SAMPLE_CMD,
	       'sample',
	       '-s11',
	       $infasta,
	       $num_sample,
	       '>',
	       $outfile,
	       "\'");
    @cmd;
}

sub bowtie_cmd {
    my $infasta = shift;
    my $outfile = shift;
    my $psid = $$;
    my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-K",
	       "-n 1",
	       "-J bowtie_$$",
	       "-o  ${Pfizer::FastQC::Config::FQ_TMPDIR}/bowtie_${psid}_log.out",
	       "-e  ${Pfizer::FastQC::Config::FQ_TMPDIR}/bowtie_${psid}_log.err",
	       "\'",
	       $Pfizer::FastQC::Config::BOWTIE_CMD,
	       $infasta,
	       '| cut -f3 | sort | uniq -c | sort -nr',
	       '>',
	       $outfile,
	       "\'");
    @cmd;
}

sub parse_bowtie_summary_table {
    my $summary_file_in = shift;
    my $num_input_seqs = shift;
    my %cnt;
    open IN, "<$summary_file_in" or confess "cannot open $summary_file_in: $!";
    while (<IN>) {
	chomp;
	my ($spacer, $num, $species) = split(/\s+/, $_);
	# print join(":", $num, $species), "\n";
	$cnt{$species} += $num;
    }
    close IN;
    my %tokenCnts;
    foreach my $token (keys %Pfizer::FastQC::Config::CONTAM_SPECIES_TOKENS) {
	$tokenCnts{$token} = 0;
    }
    foreach my $inkey (keys %cnt) {
	foreach my $token (keys %Pfizer::FastQC::Config::CONTAM_SPECIES_TOKENS) {
	    my $mtok = $Pfizer::FastQC::Config::CONTAM_SPECIES_TOKENS{$token};
	    # print "testing token: '$mtok' vs key '$inkey'\n";
	    if ($inkey =~ m/$mtok/) {
		$tokenCnts{$token} += ( $cnt{$inkey} / $num_input_seqs * 100);
		# print "matched token '$token' in key '$inkey'\n";
	    }
	}
    }
    \%tokenCnts;
}

sub run_bowtie_parallel {
    my ($sampled_fastqs_ref, $output_dir) = @_;
    my $psid = $$;
    my $job_array = "bowtie_$psid";
    my @align_summary_tables;
    my $log_stub = "${Pfizer::FastQC::Config::FQ_TMPDIR}/bowtie_$psid";
    foreach my $i (1..@$sampled_fastqs_ref) {
	my $align_table = join("/", $output_dir, "$i.aligned.txt");
	my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
		   "-n 1",
		   "-J \"${job_array}_$i\"",
		   "-o  ${Pfizer::FastQC::Config::FQ_TMPDIR}/bowtie_${psid}_log_$i.out",
		   "-e  ${Pfizer::FastQC::Config::FQ_TMPDIR}/bowtie_${psid}_log_$i.err",
		   "\'",
		   $Pfizer::FastQC::Config::BOWTIE_CMD,
		   $sampled_fastqs_ref->[$i-1],
		   '| cut -f3 | sort | uniq -c | sort -nr',
		   '>',
		   $align_table,
		   "\'");
	unless (system(join(" ", @cmd))==0) {
	    confess "failed to run command " . join(" ", @cmd);
	}
	push @align_summary_tables, $align_table;
    }
    my @hold_cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
		    "-K",
		    "-J bowtie_hold",
		    "-w \'done(\"$job_array*\")\'",
		    "-o ${log_stub}_hold.out",
		    "-e ${log_stub}_hold.err",
		    "sleep 30");
    unless (system(join(" ", @hold_cmd))==0) {
	confess "failed to run command " . join(" ", @hold_cmd);
    }
    @align_summary_tables;
}

sub run_seqtk_parallel {
    my ($fastqobs, $num_sample, $output_dir) = @_;
    my $psid = $$;
    my $job_array = "seqtk_$psid";
    my $log_stub = "${Pfizer::FastQC::Config::FQ_TMPDIR}/seqtk_$psid";
    my @sampled_fastqs;
    foreach my $i (1..@$fastqobs) {
	my $sampled_fastq = join("/", $output_dir, $fastqobs->[$i-1]->id . ".sampled.fastq");
	my @cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
	       "-n 1",
	       "-J \"${job_array}_$i\"",
	       "-o ${Pfizer::FastQC::Config::FQ_TMPDIR}/seqtk_${psid}_log_$i.out",
	       "-e ${Pfizer::FastQC::Config::FQ_TMPDIR}/seqtk_${psid}_log_$i.err",
	       "\'",
	       $Pfizer::FastQC::Config::SEQTK_SAMPLE_CMD,
	       'sample',
	       '-s11',
	       $fastqobs->[$i-1]->full_path,
	       $num_sample,
	       '>',
	       $sampled_fastq,
	       "\'");
	unless (system(join(" ", @cmd))==0) {
	    confess "failed to run command " . join(" ", @cmd);
	}
	push @sampled_fastqs, $sampled_fastq;
    }
    my @hold_cmd = ($Pfizer::FastQC::Config::BSUB_CMD,
		    "-K",
		    "-J seqtk_hold",
		    "-w \'done(\"$job_array*\")\'",
		    "-o ${log_stub}_hold.out",
		    "-e ${log_stub}_hold.err",
		    "sleep 30");
    unless (system(join(" ", @hold_cmd))==0) {
	confess "failed to run command " . join(" ", @hold_cmd);
    }
    
    @sampled_fastqs;
}


sub contamAlignParallel {
    my $fastqobs = shift;
    my $num_sample = shift || $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE;
    my $output_dir = shift;
    my @trefs;
    
    # TODO:
    my @sampled_fastqs = run_seqtk_parallel($fastqobs, $num_sample, $output_dir);
    my @align_summary_tables = run_bowtie_parallel(\@sampled_fastqs, $output_dir);

    foreach my $alt (@align_summary_tables) {
	push @trefs, parse_bowtie_summary_table($alt,  $num_sample);
    }
    @trefs;
}

sub contamAlign {
    my $fastq_file = shift;
    my $num_sample = shift || $Pfizer::FastQC::Config::SEQTK_NUM_SAMPLE;
    my $contamAlignStub = shift || ($$);
    # seqtk to sample
    my $sampled_fastq = $contamAlignStub . ".sampled.fastq";
    my $align_summary_table = $sampled_fastq . ".aligned.txt";
    my @cmd = seqtk_cmd($fastq_file, $num_sample, $sampled_fastq);
    print join(" ", @cmd), "\n";
    unless (system(join(" ", @cmd))==0) {
	confess "failed to run seqtk_cmd";
    }
    # bowtie alignment against contam db
    @cmd = bowtie_cmd($sampled_fastq, $align_summary_table);
    print join(" ", @cmd), "\n";
    unless (system(join(" ", @cmd))==0) {
	confess "failed to run bowtie_cmd";
    }
    # summarize aligned counts
    my $tref = parse_bowtie_summary_table($align_summary_table,  $num_sample);
    # print Dumper $tref;
    $tref;
}

sub supportText {
    "Tool brought to you by <a href='http://ecfmp.pfizer.com/MA/camb_us/inf/mrbt/default.aspx'>" .
	"Research and Early Clinical Development BT (RECDBT)</a>" . 
	"<br/>For help, file a ticket for the queue <strong>$Pfizer::FastQC::Config::SUPPORT_QUEUE<strong>";
}

=head2 _round

 Title   : _round
 Usage   : _round( $value, $precision);
 Function: Do round-to-even on floating point values, to designated precision.  
           Seems to be necessary to reproduce Mascot's pepXML PTM mass values,
           Because sprintf() does not seem to do round-to-even, except when
           rounding to integers.
 Returns : $value, rounded-to-even for $precision decimal places 

=cut
 
sub _round {
    my $v = shift;
    my $prec = shift;
    $v = $v*(10**$prec);
    $v = sprintf("%0.0f", $v);
    $v = $v/(10**$prec);
}

sub recipient_list {
    my $to = shift;
    join(",", $to, $Pfizer::FastQC::Config::ADMIN_EMAIL);
    
    # For admin only:
    #$Pfizer::FastQC::Config::ADMIN_EMAIL;
}

sub renewCredentials {
    my $user_id = shift; # capitalization important
    my $keytab_file = shift;
    unless (-r $keytab_file) {
	confess "cannot read keytab file: $keytab_file";
    }
    my $creds_cmd = sprintf("kinit %s -k -t %s", $user_id, $keytab_file);

    if (system($creds_cmd)==0) {
	protlog($LOG_FH, "Successfully renewed Kerebos credentials");
    } else {
	warn "failed to run command: '$creds_cmd'\n";
	return 0;
    }
    protlog($LOG_FH, "klist result");
    my $klist_cmd = 'bsub -Is -q short klist';
    if (system($klist_cmd)==0) {
	protlog($LOG_FH, "Successfully ran klist via bsub");
    } else {
	warn "failed to run command: '$klist_cmd'\n";
	return 0;
    }
    return 1;
}

sub bailMessage {
    my $payload_message = shift;
    my $msg = "<html><head><style>$Pfizer::FastQC::Config::EMAIL_STYLE</style></head><body>";
    $msg .= $payload_message;
    $msg .= "<br/><hr/>" . supportText();
    $msg .= "</body></html>";
    $msg;
}

sub sendBailMsg {
    my $to = shift;
    my $payload_message = shift;
    protlog($LOG_FH, $payload_message);
    sendmail($Pfizer::FastQC::Config::SMTP_SERVER, 
	     $Pfizer::FastQC::Config::APPLICATION_EMAIL,
	     recipient_list($to),
	     "FASTQC Pipeline has encountered an error  - please investigate",
	     bailMessage($payload_message));
}

sub bail {
    my $to = shift;
    my $payload_message = shift;
    sendBailMsg($to, $payload_message);
    exit(-1);
}

