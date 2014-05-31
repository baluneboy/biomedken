#!/usr/bin/env python

import datetime
import pandas as pd

file_name = '/home/pims/Documents/xactions.xlsx'
file_name = '/home/pims/Documents/example.xlsx'
xl_file = pd.ExcelFile(file_name)

dfs = {sheet_name: xl_file.parse(sheet_name) for sheet_name in xl_file.sheet_names}

dfx = dfs['xactions']
dfz = dfs['zin']
dfv = dfs['vars']

new_row = pd.DataFrame([dict(PayDate=datetime.datetime.now().date(), Hours=80.0, Type='Regular', Amount=123.45), ])
dfz = dfz.append(new_row, ignore_index=True)

print dfz[-5:]
print dfv