use strict;
use warnings;

if ( scalar(@ARGV) != 2 ) { print "USAGE: perl extract_sequence_with_hit.pl <blast outfmt6> <fasta_file>\n" };

my @inputs = ();
my %fasta = ();
my %new_fasta = ();
my $id = ();

## open blast output and get query range of hit ##
my %range = ();

open ( IN, $ARGV[0] );

while ( my $line = <IN> ) {

    my @f = split (/\t/,$line);
    $range{$f[0]}="$f[6]:$f[7]";

}

## load fasta ##
open ( IN1, $ARGV[1] );

while ( my $line = <IN1> ) {
    FastaParser($line);
}


## extract query range with hit ##
foreach ( keys %fasta ) {

    if ( exists $range{$_} ) {
        my @h = split (/:/,$range{$_});
        $new_fasta{$_}=substr($fasta{$_},$h[0],$h[1]);
        print "$_\t$new_fasta{$_}\n";
    }

    else {
        print "$_\t$fasta{$_}\n";
    }  
}




sub FastaParser {

    @inputs = @_;

    my $line=$inputs[0];
    chomp $line;

    if ( $line =~ />/ ) {
        $line =~ s/>| .*//g;
        $id = $line;
    }

    elsif ( $line !~ /\--/ ) {
        $line =~ s/\*$|\.$//g;
        $line = uc ($line);
        $fasta{$id}=$line;
    }

}
