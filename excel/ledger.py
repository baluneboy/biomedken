#!/usr/bin/env python

import os
import datetime
import shutil
import xlwt
import pandas as pd

# return dict of dataframes, one for each sheet in Excel file
def load_previous(file_name):
    """return dict of dataframes, one for each sheet in Excel file"""

    # Backup previous Excel file
    suffix = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M_%S')
    backup_file = file_name.replace('.xlsx', suffix + '.xlsx')
    if os.path.exists(backup_file):
        raise('Abort because backup file %s already exists' % backup_file)
    shutil.copy(file_name, backup_file)
    if os.path.isfile(backup_file):
        print "Wrote backup file %s" % backup_file
    else:
        raise('Something went wrong with creating backup file %s' % backup_file)

    # Read Excel file into dict of dataframes
    excel_file = pd.ExcelFile(file_name)
    dfs = {sheet_name: excel_file.parse(sheet_name) for sheet_name in excel_file.sheet_names}
    
    #dfx = dfs['xactions']
    #dfz = dfs['zin']
    #dfv = dfs['vars']
    #
    #new_row = pd.DataFrame([dict(PayDate=datetime.datetime.now().date(), Hours=80.0, Type='Regular', Amount=123.45), ])
    #dfz = dfz.append(new_row, ignore_index=True)
    #
    #print dfz[-5:]
    #print dfv
    
    # Return dict of dataframes
    return dfs

sheets = {
    'xactions': ['Date', 'Where', 'Delta', 'Note'],
    'zin':      ['PayDate', 'Type', 'Hours', 'Amount'],
    'vars':     ['Date', 'Variable', 'Value'],
}

def add_pay_stub(file_name='/home/pims/Documents/ledger.xlsx'):
    
    # Backup, then load previous Excel file into dict of dataframes
    dfs = load_previous(file_name)

    # NOTE: could not find good way to add new, formulaic rows, so...
    #       instead of working from dataframe for new pay stub, use...
    #       xlsxwriter write_formula on zin sheet later (below)

    # Create a Pandas Excel writer using XlsxWriter as the engine
    # NOTE: we clobber original file because we have backed it up already!
    writer = pd.ExcelWriter(file_name, engine='xlsxwriter')
    
    # Create a sheet for each DataFrame
    for sheet_name, column_order in sheets.iteritems():
        dfs[sheet_name].to_excel(writer, sheet_name=sheet_name, cols=column_order, index=False)

    # TODO Create "new pay stub" entries (80 hours of Regular, est. deductions, etc.)
    # TODO Use formulas for Amounts tied to Hours on zin sheet for easy manual changes
    #      NOTE: these will get overwritten on next run with values instead of formulas
    #    
    # dfs['vars'] # for MOST RECENT value of zin_hourly
    # pay_date = previous + TWO_WEEKS
    # somewhere around here we use write_formula method on zin sheet

    # Add formats to use
    date_format = writer.book.add_format({'num_format': 'dd-mmm-yyyy'})
    red_cond_format = writer.book.add_format({'num_format': '#.00;[RED]-#.00'})
    right_align_format = writer.book.add_format({'align': 'right'})

    # Set formats
    writer.sheets['zin'].set_column('A:A', 12, date_format)
    writer.sheets['zin'].set_column('B:B', 16, right_align_format)
    writer.sheets['zin'].set_column('D:D', 9, red_cond_format)
    writer.sheets['xactions'].set_column('A:A', 12, date_format)
    writer.sheets['xactions'].set_column('B:B', 6, right_align_format)
    writer.sheets['xactions'].set_column('C:C', 9, red_cond_format)
    writer.sheets['xactions'].set_column('D:D', 9, right_align_format)
    writer.sheets['xactions'].freeze_panes(1, 0)
    writer.sheets['zin'].freeze_panes(1, 0)    
    writer.sheets['vars'].set_column('A:A', 12, date_format)
    writer.sheets['vars'].set_column('B:B', 16, right_align_format)
    
    # Close the Pandas Excel writer with save to Excel file
    writer.save()
    
if __name__ == "__main__":
    #add_pay_stub()
    add_pay_stub(file_name='/home/pims/Documents/example.xlsx')