import pandas as pd
import re
import argparse

def tsv_to_xlsx(tsv_file):
    # Read the TSV file
    df = pd.read_csv(tsv_file, sep='\t', header=None)
    
    # Generate the XLSX filename
    xlsx_file = re.sub(r'\.tsv$', '.xlsx', tsv_file)
    
    # Write to XLSX file
    df.to_excel(xlsx_file, index=False, header=False)
    
    print(f"Converted {tsv_file} to {xlsx_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert TSV file to XLSX")
    parser.add_argument('filename', help="Input TSV file")
    args = parser.parse_args()
    
    tsv_to_xlsx(args.filename)
