65;6003;1cimport pandas as pd
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('filename')
args = parser.parse_args()

tsv_file = args.filename
xlsx_file = re.sub('.tsv',".xlsx",tsv_file)

df = pd.read_csv(tsv_file, sep='\t')

df.to_excel(xlsx_file, index=False)
