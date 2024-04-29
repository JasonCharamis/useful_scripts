import pandas as pd
import argparse
import re
import openpyxl

parser = argparse.ArgumentParser()
parser.add_argument('--xlsx', type = str, help = 'Input xlsx spreasheet file.')
args = parser.parse_args()


def xlsx_to_tsv(xlsx_file):
    """
    Convert an Excel XLSX file to a TSV file
    """
    
    # Load the XLSX file
    workbook = openpyxl.load_workbook(xlsx_file)

    # Get the active worksheet
    worksheet = workbook.active

    # Create a list of rows
    rows = []
    
    for row in worksheet.iter_rows():
        row_data = []
        for cell in row:
            row_data.append(str(cell.value))
        rows.append('\t'.join(row_data))

    # Write the TSV file

    tsv_file = re.sub('.xlsx', '.tsv', xlsx_file)
    
    with open(tsv_file, 'w', encoding='utf-8') as tsv_file:
        tsv_file.write('\n'.join(rows))


if __name__ == "__main__":
    xlsx_to_tsv(xlsx_file = args.xlsx)
