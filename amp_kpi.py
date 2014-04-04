#!/usr/bin/env python

import re
import sys
import csv
import numpy as np
import pandas as pd
import datetime
from cStringIO import StringIO
from pims.utils.pimsdateutil import hours_in_month, doytimestr_to_datetime

#  Group,                 System,     Resource,   Formula
#  ------------------------------------------------------------
#  continuous,            sams,       121f03,     100 * D / T
#  continuous,            sams,       121f04,     100 * D / T
#  continuous,            sams,       cu,         100 * X / T
#  continuous,            mams,       hirap,      100 * D / T
#  continuous,            mams,       ossraw,     100 * D / T
#  ------------------------------------------------------------
#  power_rack_dependent,  sams,       121f05,     100 * D / R
#  power_rack_dependent,  sams,       121f02,     100 * D / R
#  ------------------------------------------------------------
#  payload_dependent,     sams,       es03,       100 * D / P
#  payload_dependent,     sams,       es05,       100 * D / P
#  payload_dependent,     sams,       es06,       100 * D / P

# Each of below for a given resource for a given month (T is total hours for the given month)
# DONE continuous group, resource NOT "cu" = 100 * D / T; where D is the number of hours in PAD files
# TODO continuous group, resource IS  "cu" = 100 * X / T, where X is the number of records in the database in the CU Housekeeping Packet
# TODO power_rack_dependent group, involves MSID related to each ER power
# TODO payload_dependent group, resource IS "cir|fir", involves MSID related to SAMS power:
#      - UFZF12RT7452J is IOP MP PWR CTRL SAMS for FIR (ES06), at offset word 53 (byte 106), 1 byte length
#      - UFZF13RT7420J is IOP MP PWR CTRL SAMS for CIR (ES05), at offset word 53 (byte 106), 1 byte length
# TODO payload_dependent group, resource IS "msg", involves MSID related to outlet power (1 of 2 possible outlets):
#      - watching the MSG planning for which experiment is in, and then if they use SAMS, and then monitor the power outlet
#        to know when they turned us on

# filter and pivot to get aggregate sum of monthly hours
def monthly_hours(df, s):
    """filter and pivot to get aggregate sum of monthly hours"""
    ndf = df.filter(regex='Date|Year|Month|Day|' + s + '.*_hours')
    cols = [i for i in ndf.columns if i not in ['Date', 'Year', 'Month', 'Day']]
    t = pd.pivot_table(ndf, rows=['Year','Month'], values=cols, aggfunc=np.sum)
    series = t.transpose().sum()
    return series

# put systems' monthly hours (each a series) into pd.DataFrame
def monthly_hours_dataframe(df, systems_series):
    """put systems' monthly hours (each a series) into pd.DataFrame"""
    for k, v in systems_series.iteritems():
        systems_series[k] = monthly_hours(df, k)    
    monthly_hours_df = pd.DataFrame(systems_series)
    monthly_hours_df.columns = [ s.upper() for s in monthly_hours_df.columns ]
    return monthly_hours_df

# parse date/times from the csv
def parse(s):
    yr = int(s[0:4])
    #doy = int(s[5:8])
    mo = int(s[5:7])
    da = int(s[8:10])
    #hr = int(s[9:11])
    #min = int(s[12:14])
    #sec = int(s[15:17])
    #sec = float(sec)
    #mu_sec = int((sec - int(sec)) * 1e6)
    #mu_sec = 0
    #sec = int(sec)
    #dt = datetime(yr - 1, 12, 31)
    #delta = timedelta(days=doy, hours=hr, minutes=min, seconds=sec, microseconds=mu_sec)
    #return dt + delta
    return datetime.date(yr, mo, da)

# read big CSV into dataframe (for pivot tables)
def csv2dataframe(csvfile):
    """read CSV into dataframe (so we can use pivot tables)"""
    with open(csvfile, 'rb') as f:
        labels = f.next().strip().split(',')
        df = pd.read_csv( csvfile, parse_dates=True, index_col = [0] )
    return df

# read resource config CSV file into dataframe
def resource_csv2dataframe(csvfile):
    """read resource config CSV file into dataframe"""
    with open(csvfile, 'rb') as f:
        labels = f.next().strip().split(',')
        df = pd.read_csv( csvfile )
    return df

# normalize on/off (as one/zero) for CIR and FIR power on/off columns
def normalize_cir_fir_power(v):
    """normalize on/off (as one/zero) for CIR and FIR power on/off columns"""
    if isinstance(v, float) and np.isnan(v):
        return 0
    elif v.lower().startswith('off') or v.lower().startswith('power off'):
        return 0
    elif v.lower().startswith('on') or v.lower().startswith('power on'):
        return 1
    else:
        return np.nan
        
# read NRT List Request output (sto, tab delimited) file into dataframe
def msg_cir_fir_sto2dataframe(stofile):
    """read ascii sto file into dataframe"""
    s = StringIO()
    with open(stofile, 'r') as f:
        # Read and ignore header lines
        header = f.readline() # labels
        s.write(header)
        is_data = False
        for line in f:
            if line.startswith('#Start_Data'):
                is_data = True
            if line.startswith('#End_Data'):
                is_data = False
            if is_data and not line.startswith('#Start_Data'):
                s.write(line)
    s.seek(0) # "rewind" to the beginning of the StringIO object
    df = pd.read_csv(s, sep='\t')
    
    # drop the unwanted "#Header" column
    df = df.drop('#Header', 1)
    column_labels = [ s.replace('Timestamp : Embedded GMT', 'GMT') for s in df.columns.tolist()]
    df.columns = column_labels
    
    # drop Unnamed columns
    for clabel in column_labels:
        if clabel.startswith('Unnamed'):
            df = df.drop(clabel, 1)

    # use Jen's nomenclature to rename column labels    
    msid_map = {
        'ULZL02RT0471C': 'MSG_Outlet_2_Current',
        'ULZL02RT0477J': 'MSG_Outlet_2_Status',
        'UFZF07RT0114V': 'MSG_Outlet1_28V',
        'UFZF07RT0118V': 'MSG_Outlet2_28V',
        'UFZF07RT0121J': 'MSG_Outlet1_Status',
        'UFZF07RT0125J': 'MSG_Outlet2_Status',
        'UFZF07RT0046T': 'MSW_WV_Air_Temp',
        'UFZF13RT7420J': 'TSH_ES05_CIR_Power_Status',
        'UFZF12RT7452J': 'TSH_ES06_FIR_Power_Status',
        }
    for k, v in msid_map.iteritems():
        df.rename(columns={k: v}, inplace=True)

    # normalize on/off (as one/zero) for CIR and FIR columns
    df.TSH_ES05_CIR_Power_Status = [ normalize_cir_fir_power(v) for v in df.TSH_ES05_CIR_Power_Status.values ]
    df.TSH_ES06_FIR_Power_Status = [ normalize_cir_fir_power(v) for v in df.TSH_ES06_FIR_Power_Status.values ]

    return df

## produce output csv with per-system monthly sensor hours totals & rolling means
#def OLD_main(csvfile):
#    """produce output csv with per-system monthly sensor hours totals & rolling means"""
#    # read input CSV into big pd.DataFrame
#    df = csv2dataframe(csvfile)
#
#    # systems' monthly hours (each a series from pivot) into dataframe
#    systems_series = {'sams':None, 'mams':None}
#    monthly_hours_df = monthly_hours_dataframe(df, systems_series)
#    
#    # pd.concat rolling means (most recent n months) into growing dataframe
#    systems = list(monthly_hours_df.columns)
#    original_mdf = monthly_hours_df.copy()
#    num_months = [3, 6, 9]
#    clip_value = 0.01 # threshold to clip tiny values with
#    for n in num_months:
#        roll_mean = pd.rolling_mean(original_mdf, window=n)
#        # rolling mean can produce tiny values (very close to zero), so clip/replace with zeros
#        for system in systems:
#            roll_mean[system] = roll_mean[system].clip(clip_value, None)
#            roll_mean.replace(to_replace=clip_value, value=0.0, inplace=True)
#        roll_mean.columns = [ i + '-%d' % n for i in systems]
#        monthly_hours_df = pd.concat([monthly_hours_df, roll_mean], axis=1)
#    
#    # save csv output file
#    csvout = csvfile.replace('.csv','_monthly.csv')
#    monthly_hours_df.to_csv(csvout)
#    print 'wrote %s' % csvout

# convert sto file to dataframe, then process and write to csv
def convert_sto2csv(stofile):
    """convert sto file to dataframe, then process and write to csv"""
    
    # get dataframe from sto file
    df = msg_cir_fir_sto2dataframe(stofile)

    # convert like 2014:077:00:02:04 to datetimes, then to strings like 2014-03-18/077,00:02:04
    df['date'] = [ doytimestr_to_datetime( doy_gmtstr ).date() for doy_gmtstr in df.GMT ]

    # convert like 2014:077:00:02:04 to datetimes, then to strings like 2014-03-18/077,00:02:04
    dtmstr = [ doytimestr_to_datetime( doy_gmtstr ).strftime('%Y-%m-%d/%j,%H:%M:%S') for doy_gmtstr in df.GMT ]
    
    # overwrite GMT columns
    df['GMT'] = dtmstr

    # separate CIR/FIR info
    df_cir = df[df['status'] == 'S']
    df_fir = df[df['status.1'] == 'S']
       
    # drop the unwanted columns
    df_cir = df_cir.drop(['TSH_ES06_FIR_Power_Status', 'status.1'], 1)
    
    # pivot to aggregate daily sum for CIR es05 "payload_hours" column
    grouped_cir = df_cir.groupby('date').aggregate(np.sum)
    
    # write CIR info to csv
    df_cir.to_csv( stofile.replace('.sto','_CIR.csv') )
    grouped_cir.to_csv( stofile.replace('.sto','_CIR_grouped.csv') )    
    
    # drop the unwanted columns
    df_fir = df_fir.drop(['TSH_ES05_CIR_Power_Status', 'status'], 1)
    df_fir.rename(columns={'status.1': 'status'}, inplace=True)
    
    # pivot to aggregate daily sum for FIR es06 "payload_hours" column
    grouped_fir = df_fir.groupby('date').aggregate(np.sum)
    
    # write FIR info to csv
    df_fir.to_csv( stofile.replace('.sto','_FIR.csv') )
    grouped_fir.to_csv( stofile.replace('.sto','_FIR_grouped.csv') )  

# produce output csv with per-system monthly sensor hours totals & rolling means
def main(csvfile, resource_csvfile):
    """produce output csv with per-system monthly sensor hours totals & rolling means"""
    
    # read resource config csv file
    df_cfg = resource_csv2dataframe(resource_csvfile)
    regex_sensor_hours = '.*' + '_hours|.*'.join(df_cfg['Resource']) + '_hours'
    
    # read input CSV into big pd.DataFrame
    df = csv2dataframe(csvfile)

    # filter to keep only hours columns (gets rid of bytes columns) for each sensor
    # that shows up in df_cfg's Resource column
    ndf = df.filter(regex='Date|Year|Month|Day|' + regex_sensor_hours)
    
    # pivot to aggregate monthly sum for each "sensor_hours" column
    t = pd.pivot_table(ndf, rows=['Year','Month'], aggfunc=np.sum)
    
    # drop the unwanted "Day" column
    df_monthly_hours = t.drop('Day', 1)
    
    # convert index, which are tuples like (YEAR, MONTH), to tuples like (YEAR, MONTH, 1)
    date_tuples = [ ( t + (1,) ) for t in df_monthly_hours.index.values ]

    # convert date_tuples each to hours_in_month
    hours = [ hours_in_month( datetime.date( *tup ) ) for tup in date_tuples ]

    # before we add hours_in_month column, get list of columns for iteration below
    cols = df_monthly_hours.columns.tolist()
    
    # now we can append month_hours column
    df_monthly_hours['hours_in_month'] = pd.Series( hours, index=df_monthly_hours.index)
    
    # iterate over columns (excluding hours_in_month) to get 100*sensor_hours/hours_in_month
    for c in cols:
        pctstr = c + '_pct'
        pct = 100 * df_monthly_hours[c] / df_monthly_hours['hours_in_month']
        df_monthly_hours[pctstr] = pd.Series( pct, index=df_monthly_hours.index)
    
    # save csv output file
    csvout = csvfile.replace('.csv','_monthly_hours.csv')
    df_monthly_hours.to_csv(csvout)
    print 'wrote %s' % csvout

#stofile = '/misc/yoda/www/plots/batch/padtimes/2014_032-062_msg_cir_fir.sto'
stofile = '/misc/yoda/www/plots/batch/padtimes/2014_077-091_cir_fir_pwr_sams.sto'
#stofile = '/misc/yoda/www/plots/batch/padtimes/2014_077-092_cir_fir_pwr_sams2min.sto'
convert_sto2csv(stofile)
raise SystemExit

if __name__ == '__main__':
    if len(sys.argv) == 3:
        csvfile = sys.argv[1]
        resource_csvfile = sys.argv[2]
    else:
        csvfile = '/misc/yoda/www/plots/batch/padtimes/padtimes.csv'
        resource_csvfile = '/misc/yoda/www/plots/batch/padtimes/kpi_track.csv'
    main(csvfile, resource_csvfile)    