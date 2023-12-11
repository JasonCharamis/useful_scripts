import pandas as pd
import argparse
import re

parser = argparse.ArgumentParser()
parser.add_argument('filename')
args = parser.parse_args()

file=pd.read_excel(args.filename,  engine='openpyxl')

out=re.sub(".xlsx",".tsv",args.filename)

file.to_csv(out,sep="\t")
