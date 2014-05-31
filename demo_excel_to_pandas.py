#!/usr/bin/env python

import pandas as pd

file_name = '/home/pims/Documents/xactions.xlsx'
xl_file = pd.ExcelFile(file_name)

dfs = {sheet_name: xl_file.parse(sheet_name) for sheet_name in xl_file.sheet_names}

print dfs['xactions']
print dfs['zin']