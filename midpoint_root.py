import re
import argparse
from ete3 import Tree

parser = argparse.ArgumentParser()
parser.add_argument('Tree in Newick format')
args = parser.parse_args()

input = args.filename

def midpoint_root(input):
    tree = Tree(input, format = 1)
    
    ## get midpoint root of tree ##
    midpoint = tree.get_midpoint_outgroup()

    ## set midpoint root as outgroup ##
    tree.set_outgroup(midpoint)
    
    ## write new file ##
    tree.write(format=1, outfile=input+".midpoint_rooted")

midpoint_root(input)
