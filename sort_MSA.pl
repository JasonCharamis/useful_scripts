use strict;
use warnings;

my @inputs = ();
my %fasta = ();
my $id = ();
my $comb = ();

open ( IN, $ARGV[0] );

while ( my $line = <IN> ) {
    FastaParser($line);

    foreach ( sort %fasta ) {
        print ">$_\n$fasta{$_}\n";
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

    else {
        $comb .= $line; 
        $line = uc ($line);
    }

$fasta{$id}=$comb;

}
