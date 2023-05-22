import re
import argparse
from ete3 import Tree

parser = argparse.ArgumentParser()
parser.add_argument('tree_newick')
args = parser.parse_args()

input = args.tree_newick

def midpoint_root(input):
    tree = Tree(input, format = 1)
    
    ## get midpoint root of tree ##
    midpoint = tree.get_midpoint_outgroup()

    ## set midpoint root as outgroup ##
    tree.set_outgroup(midpoint)
    
    ## write new file ##
    tree.write(format=1, outfile=input+".midpoint_rooted")

midpoint_root(input)
