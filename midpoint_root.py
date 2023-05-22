import re
import argparse
from ete3 import Tree

parser = argparse.ArgumentParser()
parser.add_argument('filename')
args = parser.parse_args()

input = args.filename

if len(input) != 1:
    print ("USAGE: python argv[0] <Tree in Newick format>")

def midpoint_root(input):
    tree = Tree(input, format = 1)
    
    ## get midpoint root of tree ##
    midpoint = tree.get_midpoint_outgroup()

    ## set midpoint root as outgroup ##
    tree.set_outgroup(midpoint)
    
    ## write new file ##
    tree.write(format=1, outfile=input+".midpoint_rooted")

midpoint_root(input)
