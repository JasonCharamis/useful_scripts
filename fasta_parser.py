
import re
import fileinput

#this script parses fasta files as dictionaries

def print_fasta(fasta_dict):

    pseudogene = re.compile("P$")
    
    for ids,seqs in fasta_dict.items():
        ids = ids.strip('\n')
        seqs = seqs.strip('\n')

        if not re.search(pseudogene,ids):
            print ( ">" + ids )

        if re.search ("\w+",seqs):
            if not re.search (">",seqs):
                print ( seqs )

        return


def parse_fasta(fasta):

    id = ""
    fasta_dict = {}

    fasta = fasta.strip('\n')

    if re.search (">",fasta):
        id=re.sub (">","",fasta)
        fasta_dict[id]=""
        
    elif re.search("\--",fasta):
        next
    
    else:
        seq=fasta
        fasta_dict[id]=seq

    return print_fasta(fasta_dict)



for line in fileinput.input():
    print (parse_fasta(line))
