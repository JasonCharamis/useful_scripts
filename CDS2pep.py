
import textwrap
import fileinput
import argparse
import sys
import re


def translate(seq):

    table = {
        'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
        'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
        'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
        'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
        'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
        'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
        'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
        'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
        'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
        'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
        'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
        'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
        'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
        'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
        'TAC':'Y', 'TAT':'Y', 'TAA':'', 'TAG':'',
        'TGC':'C', 'TGT':'C', 'TGA':'', 'TGG':'W'
    }

    aminoacids = []
    
    for i in range(0,len(seq),3):
        codon = seq[i:i+3]

        if codon in table:
            aminoacids.append(table[codon])

        else:
            aminoacids.append("N")

    protein = ''.join(aminoacids)
    
    return protein


def write_file(fasta,filename):

    """
    Takes a dictionary and writes it to a fasta file
    Must specify the filename when calling the function
    """
  
    with open(filename, "w") as outfile:
        for keys,seqs in fasta.items():
            keys = keys.strip("\n")
            outfile.write(">" + keys + "\n")
            outfile.write(seqs + "\n")


parser = argparse.ArgumentParser(
                    prog='CDS2pep.py',
                    description='Program to translate DNA to proteins',
                    )

parser.add_argument('filename'), # positional argument
parser.add_argument('-p','--protein')

args = parser.parse_args()

protein_file = re.sub("CDS","PEP",args.filename)

input = args.filename

fasta={}

names=[]
seqs=[]

name=""

for line in fileinput.input():
    line=line.strip('\n')
    
    if re.search (">",line):
        line = re.sub (">","",line)
        line = re.sub("PP","P",line)
        name = line
        fasta[name]=""
        
    elif re.search("\--",line):
        next
    
    else:
        seq=line.upper()
        fasta[name]=translate(seq)

write_file(fasta,protein_file)
