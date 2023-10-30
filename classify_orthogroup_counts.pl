
use strict;
use warnings;

#scalars, arrays and hashes for parsing original file and counting number of species per OG
my @f = ();
my @count = ();
my $number_of_cols = ();
my %species_counter = ();

#hashes for assigning OG id based on their presence
my %phlebotominae = ();
my %phlebotomus = ();
my %lutzomyia = ();
my %schw = ();
my %nematocera = ();
my %brachycera = ();

#assign OG categories
my %universal = ();
my %universal_single_copy = ();
my %species_specific = ();
my %phlebotomus_specific = ();
my %lutzomyia_specific = ();
my %phlebotominae_wide = ();
my %phlebotominae_patchy = ();
my %nematocera_patchy = ();
my %diptera_patchy = ();

#scalars, arrays and arrays for parsing the file, assigning OG id with species and saving the contents into a hash
my @file = ();
my %file = ();
my @h = ();
my @j = ();
my @y = ();
my $hg = ();
my %uniprint = ();

#scalars, arrays and hashes for calculating the number of genes per category (universal, phlebotominae_wide etc) per species and printing results
my %data = ();

open ( IN, $ARGV[0] ); ## Orthogroups.GeneCount.tsv
open ( IN2, $ARGV[1] ); ## Orthogroups_UnassignedGenes.tsv

open ( OUT0, ">orthology_results.tsv" );
open ( OUT1, ">orthology_results_for_R.txt" );
  
    
my %species_unassigned = (); ## hash to save the number of unassigned genes per species

while (my $line2 = <IN2>) {  
    if ($. == 1) {
        my @tabs = split(/\t/, $line2);
        for my $n (1 .. scalar(@tabs) - 2) {
            $species_unassigned{$tabs[$n]} = 1;
        }
    }

}

foreach (keys %species_unassigned) {
    $species_unassigned{$_} = `grep -c $_ $ARGV[1]`;
}


while ( my $line = <IN> ) {
    chomp $line;
    push ( @file, $line);

    #first characterize orthogroups based on their presence (universal, widespread, phlebotominae, culicidae, chironomidae, nematocera, brachycera, none - note that this is per species )    
    if ( $. > 1 ) { ## skip header line with species names

	@f = split (/\t/,$line); #split file by columns
	$number_of_cols = scalar(@f);
    
	my $i = 0; #create a variable to use as counter when finding one of the species

	for my $species (1..$number_of_cols-2) { 	#skip orthogroup name and total (0 and 20)
	    if ( $f[$species] > 0 ) { #count number of species with higher than zero number of genes per orthogroup
		$i++;
		$species_counter{$f[0]} = $i;
		
		if ( $f[$species] == 1 ) {
		    $file{$f[0]}{$species} = $f[$species];
		}
	    }
	}

	my $p = 0;
	for my $phlebotomines (9..$number_of_cols-2) { #OGs present in phlebotominae with maximum species counts
	    if ( $f[$phlebotomines] > 0 ) {
		$p++;
		$phlebotominae{$f[0]} = $p;
	    }
	}

	my $ph = 0;
	for my $phlebotomus (9..11, 14..16, 18, 19) {
	    if ( $f[$phlebotomus] > 0 ) {
		$ph++;
		$phlebotomus{$f[0]} = $ph;
	    }
	}

	my $ltz = 0;
	for my $lutzomyia (12, 13) {
	    if ( $f[$lutzomyia] > 0 ) {
		$ltz++;
		$lutzomyia{$f[0]} = $ltz;
	    }
	}

	my $stz = 0;
	for my $schw (17) {
	    if ( $f[$schw] > 0 ) {
		$stz++;
		$schw{$f[0]} = $stz;
	    }
	}	

	my $m = 0;
	for my $mosquitoes_midge (1,2,3,4,5,8) {
	    if ( $f[$mosquitoes_midge] > 0 ) {
		$m++;
		$nematocera{$f[0]} = $m;
	    }
	}

	my $d = 0;
	for my $flies (6,7) {
	    if ( $f[$flies] > 0 ) {
		$d++;
		$brachycera{$f[0]} = $d;
	    }
	}
    }
}


my $universal_single_copy = 0;
my $og = ();
    
for $og ( keys %file ) {
    $universal_single_copy = 0;
    
    foreach ( keys %{ $file{$og} } ) {
	$universal_single_copy += $file{$og}{$_} ;
    }

    if ( $universal_single_copy ==  ( $number_of_cols-2 ) ) {
	$universal_single_copy{$og} = 0;
    }
}
 
foreach ( sort keys %species_counter) {  #if orthogroup is found in all or all-but-two species save the ids into the universal dictionary    
    if ( $species_counter{$_} >= $number_of_cols-4 ) {
	unless ( exists $universal_single_copy{$_} ) {
	    $universal{$_} = $species_counter{$_};
	}
    }
    
    elsif ( $species_counter{$_} < 2 ) {
	$species_specific{$_} = $species_counter{$_};
    }
}

foreach ( sort keys %phlebotominae ) { #orthogroups widespread (all or all-but-two) in phlebotominae    
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $brachycera{$_} ) {
		    unless ( exists $nematocera{$_} ) {
			if ( $phlebotominae{$_} >= 9 ) {
			    $phlebotominae_wide{$_} = $phlebotominae{$_};
			}
		    }
		}
	    }
	}
    }
}


foreach ( sort keys %phlebotomus ) { #orthogroups specific (all or all-but-one) to phlebotomus genus 
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $brachycera{$_} ) {
		    unless ( exists $nematocera{$_} ) {
			unless ( exists $phlebotominae_wide{$_} ) {
			    unless ( exists $lutzomyia{$_} ) {
				unless ( exists $schw{$_} ) {			       
				    if ( exists $phlebotomus{$_} && $phlebotomus{$_} >= 7 ) {
					$phlebotomus_specific{$_} = $phlebotomus{$_};
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}

foreach ( sort keys %lutzomyia ) { #orthogroups specific (all) to lutzomyia genus 
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $brachycera{$_} ) {
		    unless ( exists $nematocera{$_} ) {
			unless ( exists $phlebotominae_wide{$_} ) {
			    unless ( exists $phlebotominae_patchy{$_} ) {
				unless ( exists $phlebotomus{$_} ) {
				    unless ( exists $schw{$_} ) {			       
					if ( exists $lutzomyia{$_} && $lutzomyia{$_} == 2 ) {
					    $lutzomyia_specific{$_} = $lutzomyia{$_};
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}
foreach ( sort keys %phlebotominae ) { #orthogroups present only in phlebotomines, and with patchy distribution
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $brachycera{$_} ) {
		    unless ( exists $nematocera{$_} ) {
			unless ( exists $phlebotominae_wide{$_} ) {
			    unless ( exists $phlebotomus_specific{$_} ) {
				unless ( exists $lutzomyia_specific{$_} ) {
				    if ( $phlebotominae{$_} >= 2 && $phlebotominae{$_} <= 8 ) {
					$phlebotominae_patchy{$_} = $phlebotominae{$_};
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}

foreach ( sort keys %nematocera) { #orthogroups present in nematocera, with patchy distribution
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $brachycera{$_} ) {
		    unless ( exists $phlebotominae_wide{$_} ) {
			unless ( exists $phlebotominae_patchy{$_} ) {
			    unless ( exists $phlebotomus_specific{$_} ) {
				unless ( exists $lutzomyia_specific{$_} ) {
				    if (  $species_counter{$_} >= 2  && $species_counter{$_} < 19) {
					$nematocera_patchy{$_} = $nematocera{$_};
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}

foreach ( sort keys %brachycera) { #orthogroups present in diptera, with patchy distribution
    unless ( exists $universal_single_copy{$_} ) {
	unless ( exists $universal{$_} ) {
	    unless ( exists $species_specific{$_} ) {
		unless ( exists $nematocera_patchy{$_} ) {
		    unless ( exists $phlebotominae_wide{$_} ) {
			unless ( exists $phlebotominae_patchy{$_} ) {
			    unless ( exists $phlebotomus_specific{$_} ) {
				unless ( exists $lutzomyia_specific{$_} ) {
				    $diptera_patchy{$_} = $brachycera{$_};			      
				}
			    }
			}
		    }
		}
	    }
	}
    }
}


for my $nl (0..scalar(@file)-1 ) { #now that i have the OG ids per category, I have to parse the file and print the number of genes per orthogroup per species

    @j = split (/\n/,$file[0]);
    @y = split (/\t/,$j[0] ); #create an array with the species names 

    if ( $nl == 0 ) {next};
    
    @h = split (/\t/,$file[$nl]);

    for my $col (1..scalar( @h )-2 ) {
	$uniprint{"$y[$col]:$h[0]"} = $h[$col];
    }
}


foreach ( sort keys %uniprint ) {
    ( my $n ) = ( $_ =~ /\:(OG\d+)/ );
    ( my $sp ) = ( $_ =~ /^(\w+)\:/ );
    $data{$sp}{$n}=$uniprint{$_};
   }

print OUT0 "Species\tUniversal_Single_Copy\tUniversal\tPhlebotominae_wide\tPhlebotominae_patchy\tPhlebotomus_specific\tLutzomyia_specific\tNematocera_Patchy\tDiptera_Patchy\tSpecies_specific\n";

print OUT1 "Species\tNumber_of_Genes\tType\n";


for my $sp ( sort keys %data ) {     #counting arrays and scalars should be initialized in every species, otherwise the gene numbers will keep adding
    
    my @number_universal = ();
    my @number_universal_single_copy = ();
    my @number_phlw = ();
    my @number_phl_patchy = ();
    my @number_phls = ();
    my @number_ltz = ();
    my @number_nematocera_patchy = ();
    my @number_diptera_patchy = ();
    my @number_spsp = ();
    my $sum_uni = 0;
    my $sum_uni_single_copy = 0;
    my $sum_phlw = 0;
    my $sum_phl_patchy = 0;
    my $sum_phls = 0;
    my $sum_ltz = 0;
    my $sum_nematocera_patchy = 0;
    my $sum_diptera_patchy = 0;
    my $sum_spsp = 0;

    for my $hg ( sort keys %{ $data{$sp} } ) { #get number of genes per OG per species 

	if ( exists ( $universal_single_copy{$hg} ) ) {
	    push ( @number_universal_single_copy, $data{$sp}{$hg} );
	}

	if ( exists ( $universal{$hg} ) ) {
	    push ( @number_universal, $data{$sp}{$hg} );
	}

	if ( exists ( $phlebotominae_wide{$hg} ) ) {
	    push ( @number_phlw, $data{$sp}{$hg} );
	}

	if ( exists ( $phlebotominae_patchy{$hg} ) ) {
	    push ( @number_phl_patchy, $data{$sp}{$hg} );
	}

	if ( exists ( $nematocera_patchy{$hg} ) ) {
	    push ( @number_nematocera_patchy, $data{$sp}{$hg} );
	}

	if ( exists ( $diptera_patchy{$hg} ) ) {
	    push ( @number_diptera_patchy, $data{$sp}{$hg} );
	}

	if ( exists ( $phlebotomus_specific{$hg} ) ) {
	    push ( @number_phls, $data{$sp}{$hg} );
	}
	
	if ( exists ( $lutzomyia_specific{$hg} ) ) {
	    push ( @number_ltz, $data{$sp}{$hg} );
	}

	if ( exists ( $species_specific{$hg} ) ) {
	    push ( @number_spsp, $data{$sp}{$hg} );
	}
    }

    for my $num (0..scalar( @number_universal_single_copy))  {     #add number of genes per category per species
	$sum_uni_single_copy += $number_universal_single_copy[$num];
    }

    for my $num (0..scalar( @number_universal))  {
	$sum_uni += $number_universal[$num];
    }

    for my $num (0..scalar( @number_phlw))  {
	$sum_phlw += $number_phlw[$num];
    }

    for my $num (0..scalar( @number_phls))  {
	$sum_phls += $number_phls[$num];
    }

    for my $num (0..scalar( @number_ltz))  {
	$sum_ltz += $number_ltz[$num];
    }

    for my $num (0..scalar( @number_phl_patchy))  {
	$sum_phl_patchy += $number_phl_patchy[$num];
    }

    for my $num (0..scalar( @number_nematocera_patchy))  {
	$sum_nematocera_patchy += $number_nematocera_patchy[$num];
    }

    for my $num (0..scalar( @number_diptera_patchy))  {
	$sum_diptera_patchy += $number_diptera_patchy[$num];
    }
 
    for my $num (0..scalar( @number_spsp))  {
	$sum_spsp += $number_spsp[$num];
    }

    my $species_specific_all = $sum_spsp+$species_unassigned{$sp}-1;

    #output in tab-separated, human-readable format
    print OUT0 "$sp\t$sum_uni_single_copy\t$sum_uni\t$sum_phlw\t$sum_phl_patchy\t$sum_phls\t$sum_ltz\t$sum_nematocera_patchy\t$sum_diptera_patchy\t$species_specific_all\n";

    # output for ggplot2
    print OUT1 "$sp\t$sum_uni_single_copy\tUniversal_single_copy\n$sp\t$sum_uni\tUniversal\n$sp\t$sum_phlw\tPhlebotominae_wide\n$sp\t$sum_phl_patchy\tPhlebotominae\n$sp\t$sum_phls\tPhlebotomus_specific\n$sp\t$sum_ltz\tLutzomyia_specific\n$sp\t$sum_nematocera_patchy\tNematocera\n$sp\t$sum_diptera_patchy\tDiptera\n$sp\t$species_specific_all\tSpecies_specific\n";

}
