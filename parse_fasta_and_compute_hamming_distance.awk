awk -F"\n>" 'BEGIN { header=0; print "Sequences\tHamming_Distance"; } {

    if ( $1 ~ />/ ) { header +=1; }

    else {

        for (i=1; i<=length($1); i++) {
            position=substr(substr($1,i,length($1)),1,1);
            sequence[header][i]=position;
        }
    }
    
    for ( head in sequence ) {
        for ( h=head+1; h <= length(sequence); h++) {
            count=0;
            for ( i in sequence[head] ) {
                if ( length(sequence[head]) == length(sequence[h]) ) {
                    if (sequence[head][i] != sequence[h][i] ) {
                        count++;
                    }
                }
            }

            print "seq"head"-seq"h"\t"count | "sort -u"
        }
    }' $1
