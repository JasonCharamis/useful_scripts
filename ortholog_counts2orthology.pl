
use strict;
use warnings;


#scalars, arrays and hashes for parsing original file and counting number of species per OG
my @f = ();
my @count = ();
my $number_of_cols = ();
my %species_counter = ();

#hashes for assigning OG id based on their presence
my %universal = ();
my %species_specific = ();
my %culicidae = ();
my %culicidae_wide = ();
my %chironomidae = ();
my %chironomidae_wide = ();
my %phlebotominae = ();
my %nematocera = ();
my %phlebotominae_wide = ();
my %phlebotomus = ();
my %phlebotomus_specific = ();
my %lutzomyia = ();
my %lutzomyia_specific = ();

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




open ( IN, $ARGV[0] or die "USAGE: perl ortholog_counts2orthology.pl Orthogroups.GeneCount.tsv");

open ( OUT0, ">orthology_results.tsv" );
open ( OUT1, ">orthology_results_for_R.txt" );


while ( my $line = <IN> ) {

    push ( @file, $line);

    $file{$line} = 1;

    chomp $line;
    
    #split file by columns
    @f = split (/\t/,$line);

    $number_of_cols = scalar(@f);

    
#first characterize orthogroups based on their presence (universal, widespread, phlebotominae, culicidae, chironomidae, nematocera, brachycera, none - note that this is per species )
#I will use the orthogroup ids to infer number of genes per species in a second step

    #create a variable to use as counter when finding one of the species
    my $i = 0;

    #skip orthogroup name and total (0 and 20)
    for my $species (1..$number_of_cols-2) {
	#count number of species with higher than zero number of genes per orthogroup
	if ( $f[$species] > 0 ) {
	    $i++;
	    $species_counter{$f[0]} = $i;
	}
    }


    my $p = 0;
    #OGs present in phlebotominae with maximum species counts
    for my $phlebotomines ( 9..$number_of_cols-2) {
	if ( $f[$phlebotomines] > 0 ) {
	    $p++;
	    $phlebotominae{$f[0]} = $p;
	}
    }

    my $ph = 0;
    #OGs present in phlebotominae with maximum species counts
    for my $phlebotomus ( 9..11, 14..16, 18, 19) {
	if ( $f[$phlebotomus] > 0 ) {
	    $ph++;
	    $phlebotomus{$f[0]} = $ph;
	}
    }

    my $ltz = 0;
    #OGs present in phlebotominae with maximum species counts
    for my $lutzomyia ( 12, 13) {
	if ( $f[$lutzomyia] > 0 ) {
	    $ltz++;
	    $lutzomyia{$f[0]} = $ltz;
	}
    }

    my $m = 0;
    for my $mosquitoes (1,2,5) {
	if ( $f[$mosquitoes] > 0 ) {
	    $m++;
	    $culicidae{$f[0]} = $m;
	}
    }

    my $c = 0;
    for my $midges (3,4,8) {
	if ( $f[$midges] > 0 ) {
	    $c++;
	    $chironomidae{$f[0]} = $c;
	}
    }

    my $d = 0;
    for my $flies (6,7) {
	if ( $f[$flies] > 0 ) {
	    $d++;
	    $nematocera{$f[0]} = $d;
	}
    }
}


#for the common keys, it automatically keeps the last (largest) values (don't know why)
 
#if orthogroup is found in all or all-but-one species save the ids into the universal dictionary    
foreach ( sort keys %species_counter) {
	if ( $species_counter{$_} >= $number_of_cols-3 ) {
	    unless ( exists $universal{$_} ) {
		    $universal{$_} = $species_counter{$_};
			}
		    }
	    }
 

#species-specific orthogroups, which will go to none and will be added to the number of genes with no orthogroup at all
foreach ( keys %species_counter ) {
    if ( $species_counter{$_} < 2 ) {
	$species_specific{$_} = $species_counter{$_};
    }
}

#orthogroups widespread (all or all-but-one) in phlebotominae    
foreach ( sort keys %phlebotominae ) {
    unless ( exists $universal{$_} ) {
	unless ( exists $species_specific{$_} ) {
	    unless ( exists $nematocera{$_} ) {
		unless ( exists $chironomidae{$_} ) {
		    unless ( exists $culicidae{$_} ) {
			if ( $phlebotominae{$_} >= 10 ) {
			    $phlebotominae_wide{$_} = $phlebotominae{$_};
			}
		    }
		}
	    }
	}
    }
}



#orthogroups specific (all or all-but-one) to phlebotomus genus 
foreach ( sort keys %phlebotomus ) {
    unless ( exists $universal{$_} ) {
	unless ( exists $species_specific{$_} ) {
	    unless ( exists $nematocera{$_} ) {
		unless ( exists $chironomidae{$_} ) {
		    unless ( exists $culicidae{$_} ) {
			unless ( exists $phlebotominae_wide{$_} ) {
			    unless ( exists $lutzomyia{$_} ) {
				if ( $phlebotomus{$_} >= 7 ) {
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

#orthogroups specific (all or all-but-one) to lutzomyia genus 
foreach ( sort keys %lutzomyia ) {
    unless ( exists $universal{$_} ) {
	unless ( exists $species_specific{$_} ) {
	    unless ( exists $nematocera{$_} ) {
		unless ( exists $chironomidae{$_} ) {
		    unless ( exists $culicidae{$_} ) {
			unless ( exists $phlebotominae_wide{$_} ) {
			    unless ( exists $phlebotomus{$_} ) {
				if ( $lutzomyia{$_} == 2 ) {
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

#orthogroups specific (all or all-but-one) to mosquitoes
foreach ( sort keys %culicidae ) {
    unless ( exists $universal{$_} ) {
	unless ( exists $species_specific{$_} ) {
	    unless ( exists $nematocera{$_} ) {
		unless ( exists $phlebotominae{$_} ) {
		    unless ( exists $chironomidae{$_} ) {
			    if ( $culicidae{$_} >= 2 ) {
				$culicidae_wide{$_} = $culicidae{$_};
			    }
			}
		    }
		}
	    }
	}
    }



#orthogroups specific (all or all-but-one) to midges
foreach ( sort keys %chironomidae ) {
    unless ( exists $universal{$_} ) {
	unless ( exists $species_specific{$_} ) {
	    unless ( exists $nematocera{$_} ) {
		unless ( exists $phlebotominae{$_} ) {
		    unless ( exists $culicidae{$_} ) {
			    if ( $chironomidae{$_} >= 2 ) {
				$chironomidae_wide{$_} = $chironomidae{$_};
			    }
		    }
		}
	    }
	}
    }
}


#now that i have the OG ids per category, I have to parse the file and print the number of genes per orthogroup per species
for my $nl (0..scalar(@file)-1 )   {

    #split file line-by-line and keep first line which contains species names
    @j = split (/\n/,$file[0]);

    #create an array with the species names 
    @y = split (/\t/,$j[0] );

    if ( $nl == 0 ) {next };
    
    @h = split (/\t/,$file[$nl]);
    
    #combine orthogroup name with species to parse the file
    #this is based on the fact that the sequence of the h array which loops through the columns of the file per line 
    #will have the same sequence with the y array which loops through the columns of the file only for the first line
    #I have two independent arrays which loop through the columns
    #the first has the species names, while the second takes as input the number of genes, while every line is an OG
    #OG and species information is associated with the number of genes in the specific orthogroup in a hash
        for my $col (1..scalar( @h )-2 ) {
	    $uniprint{"$y[$col]:$h[0]"} = $h[$col];
	#    $species_names{$y[$col]} = 1;
	 }

}


#the uniprint hash now contains all the numbers of genes per orthogroup
#on a manner that is easy to parse and extract
#i will now use the OG ids that I have previously kept for getting the number of genes per orthogroup for each category
#next, the numbers should be added to get the total number of genes per category

foreach ( sort keys %uniprint ) {
    ( my $n ) = ( $_ =~ /\:(OG\d+)/ );
    ( my $sp ) = ( $_ =~ /^(\w+)\:/ );
    $data{$sp}{$n}=$uniprint{$_};
   }

print OUT0 "Species\tUniversal\tPhlebotominae_wide\tPhlebotomus_specific\tLutzomyia_specific\tSpecies_specific\n";

for my $sp ( sort keys %data ) {

#    print "$sp\t";

    #counting arrays and scalars should be initialized in every species, otherwise the gene numbers will keep adding
    my @number = ();
    my @number_phlw = ();
    my @number_phls = ();
    my @number_ltz = ();
    my @number_spsp = ();
    my $sum_uni = 0;
    my $sum_phlw = 0;
    my $sum_phls = 0;
    my $sum_ltz = 0;
    my $sum_spsp = 0;

    #get number of genes per OG per species 
    for my $hg ( sort keys %{ $data{$sp} } ) {

	if ( exists ( $universal{$hg} ) ) {
	    push ( @number, $data{$sp}{$hg} );
	}

	if ( exists ( $phlebotominae_wide{$hg} ) ) {
	    push ( @number_phlw, $data{$sp}{$hg} );
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

    #add number of genes per category per species
    for my $num (0..scalar( @number))  {
	$sum_uni += $number[$num];
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
 
    for my $num (0..scalar( @number_spsp))  {
	$sum_spsp += $number_spsp[$num];
    }

    #output in tab-separated, human-readable format
    print OUT0 "$sp\t$sum_uni\t$sum_phlw\t$sum_phls\t$sum_ltz\t$sum_spsp\n";

    #output for parsing with R and create stacked barplots
    print OUT1 "$sp\t$sum_uni\tuniversal\n$sp\t$sum_phlw\tphlebotominae_wide\n$sp\t$sum_phls\tphlebotomus_specific\n$sp\t$sum_ltz\tlutzomyia_specific\n$sp\t$sum_spsp\tspecies_specific\n";


}
