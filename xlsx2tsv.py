import pandas as pd
import argparse
import re
import openpyxl


parser = argparse.ArgumentParser()
parser.add_argument('--spreadsheet', type = str, help = 'Input spreasheet file.')
args = parser.parse_args()


def get_sheet_names(file):
    try:
        workbook = openpyxl.load_workbook(file)
        sheet_names = workbook.sheetnames

        return sheet_names

    except Exception as e:
        print(f"Error: {e}")
        return None

sheet_names = get_sheet_names ( args.spreadsheet )

for sheet in sheet_names:
    data_xlsx = pd.read_excel(args.spreadsheet, sheet, index_col=None)
    data_xlsx.columns = [c.replace(' ', '_') for c in data_xlsx.columns]
    df = data_xlsx.replace('\n', ' ',regex=True)

    transposed_data = df.T
    transposed_data.to_excel(f"{sheet}.xlsx", index=False)
