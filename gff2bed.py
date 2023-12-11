import argparse
import re

parser = argparse.ArgumentParser()
parser.add_argument('--gff3')
parser.add_argument('--bed')
args = parser.parse_args()


def write_file(out, filename):
    with open(filename, "a") as outfile:  # Open the file in append mode ("a")
        outfile.write(out + '\n')

with open ( args.gff3 , 'r' ) as gff3:
    lines = gff3.readlines()

    for line in lines:
        line = line.strip('\n')
        comment = re.compile('#')
        
        if not re.search (comment, line):       
            columns = line.split ('\t')          

            if re.search("mRNA",columns[2]):
                gene = re.sub(".*Name=|;.*","",columns[8])
                gene = re.sub ("-00001","",gene)
                
                out = '\t'.join([columns[0],columns[3],columns[4],columns[2],gene])
                out = out.strip('\n')             

                write_file ( out, args.bed )
