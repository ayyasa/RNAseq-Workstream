$LOC = "/hpc/grid/omics_data02/apps/fastqc/";

print "Step 1: Check daemon status. Do you want to run ./scripts/show_daemon_status.sh Enter y or n- ";
$input1 = <STDIN>;
chomp($input1);

if($input1 eq 'y'){
#	print "Entered yes";
	$daemon_status_loc = $LOC."scripts/show_daemon_status.sh";
	system("$daemon_status_loc");

	print "Step 2: Do you want to do a sanity check. Enter y or n- ";
	$input2 = <STDIN>;
	chomp($input2);

	if($input2 eq 'y'){
#		print "Entered yes";	
		$scan_bcl =  $LOC."scripts/scan_bcl_root_dir.pl";
		system("perl $scan_bcl");

		print "Step 3: Do you want to list BCL directories? Enter y or n- ";
		$input3 = <STDIN>;
		chomp($input3);
		if($input3 eq 'y'){
#			print "Entered yes";
			$listBCL = $LOC."scripts/listAllBCLDirectories.pl";
			system("perl $listBCL");	

			print "Step 4: Do you want to stop the daemon and check daemon status? Enter y or n- ";
			$input4 = <STDIN>;
			chomp($input4);
			
			if($input4 eq 'y'){
#				print "Entered yes";
				$stop_daemon_loc = $LOC."scripts/stop_all_daemons.sh";
				system("$stop_daemon_loc");		
				system("$daemon_status_loc");

				print "Step 5: Delete existing .fastq files. Do you want to proceed? Enter y or n- ";
				$input5 = <STDIN>;
				chomp($input5);

				if($input5 eq 'y'){
#					print "Entered yes\n";
					print "Enter full BCL dir path to delete(Ex: /hpc/grid/scratch/tbi/fastqc/raw/150803_NS500482_0052_AH27NYAFXX_mRNA_redo1/)- ";
					$bcl_dir_path = <STDIN>;
					chomp($bcl_dir_path);
					system("rm -rf $bcl_dir_path");
					print "Raw fastq files are deleted.\n";

					print "Step 6: Do you want to delete the record in DB? Enter y or n- ";
					$input6 = <STDIN>;
					chomp($input6);

					if($input6 eq 'y'){
#						print "Entered yes\n";
						print "Enter BCL Directory ID - ";
						$bcl_dir_id = <STDIN>	;
						chomp($bcl_dir_id);
						$delete_bcl_dir = $LOC."scripts/deleteBCLDirectory.pl";
				                system("perl $delete_bcl_dir $bcl_dir_id");

						print "Database record deleted.\nStep 7: Do you want to scan bcl dir? Enter y or n- ";
						$input7 = <STDIN>;
						chomp($input7);
						
						if($input7 eq 'y'){
#							print "Entered yes";
						        system("perl $scan_bcl");
							
							print "Step 8: Do you want to launch the daemon? Enter y or n- ";
							$input8 = <STDIN>	;
							chomp($input8);
							
							if($input8 eq 'y'){
#								print "Entered yes\n";
								$daemon_loc = $LOC. "scripts/register_runs_daemon.pl";
								system("perl $daemon_loc register_runs_fastqc.log 1");
								print "Launched daemon! Exiting!";
							}
							else{print "Exiting!";}# exit if launch daemon is no

						}
						else{print "Exiting!"}# exit if no to scan bcl dir
							
					
        



					}
					else{print "Exiting!";} #exit if delete db is no

				}
				else {print "Exiting!";}#exit if delete .fastq is no

			}
			else {print "Exiting!";}#exit if stop daemon is no
		}
		else{print "Exiting!";}#exit if list BCLdir is no
	
	}
	else{print "Exiting!";}#exit if sanity check is no
	
}
else{
	print "Exiting ... Bye";
}#exit if check daemon status is no
