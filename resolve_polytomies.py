import re
import argparse
from ete3 import Tree

parser = argparse.ArgumentParser()
parser.add_argument('tree_newick')
args = parser.parse_args()

input = args.tree_newick

def resolve_polytomies(input):
    
    tree = Tree(input, format = 1)
    
    ## resolve polytomies in tree ##
    bifurcating = tree.resolve_polytomy(recursive=True)

    tree.write(format=1, outfile=input+".resolved_polytomies")
    
resolve_polytomies(input)
