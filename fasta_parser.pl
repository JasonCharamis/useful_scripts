
use strict;
use warnings;

open ( IN, $ARGV[0] );

my @f = ();
my %fasta=();
my $seq=();
my $id = ();

while ( my $line = <IN> ) {

    chomp $line;
    
    if ( $line =~ />/ ) {
	$line =~ s/>//g;
	$id = $line;
	$fasta{$id}=1;

    }

    elsif ( $line =~ /\--/ ) {
	next;
    }

    else {
	$seq = $line;
	$fasta{$id}=$line;
    }
   
}


foreach ( keys %fasta ) {

    unless ( $_ =~ /jg|tet/ ) {
	print ">$_\n$fasta{$_}\n";
    }

}




