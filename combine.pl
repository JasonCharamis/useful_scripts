#Combine the contents of two files based on common identifier.
#Can be easily adjusted for which columns and at what order they will be printed.


use strict;
use warnings;

open ( IN1, $ARGV[0]);
open ( IN2, $ARGV[1]);

my %file1={};
my %file2={};


while ( my $line = <IN1> ) {

    chomp $line;
    my @f = split (/\t/,$line);
    $file1{$f[0]}=$line;

}

while ( my $line = <IN2> ) {

    chomp $line;
    my @f = split (/\t/,$line);
    $file2{$f[0]}=$f[2];

}

close (IN1);
close (IN2);


foreach ( keys %file1 ) {
    if ( exists $file2{$_} ) {
        print "$file1{$_}\t$file2{$_}\n";

    }

}
