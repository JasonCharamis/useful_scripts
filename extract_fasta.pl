# Script to extract fasta sequences based on list of IDs #

use strict;
use warnings;

open ( IN, $ARGV[0] ) or die "USAGE: perl filter_fasta.pl 2-LINE_FASTA_FILE [LIST_OF_IDs_TO_EXTRACT]" ;
open ( IN1, $ARGV[1]);


my @f = ();
my @h = ();
my $seq = ();
my $id = ();
my @filter = ();
my %filter = ();
my @inputs = ();
my %fasta = ();

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


#fasta hash, genes to extract

sub FastaFile {
    @filter=@_;
    @h = split (/\t/,$filter[0]);
    chomp $h[1];
    $filter{$h[0]}{$h[1]}=1;
}


while ( my $line = <IN> ) {
    FastaParser ($line);
}


while ( my $line=<IN1> ) {
    FastaFile($line);
}

close (IN);


for my $head ( keys %fasta ) {
    for my $id ( keys %{$filter{$head}} ) {
        if ( exists $fasta{$head} ) {
            print "$head\t$id\t$fasta{$head}\n";
        }
    }
}
