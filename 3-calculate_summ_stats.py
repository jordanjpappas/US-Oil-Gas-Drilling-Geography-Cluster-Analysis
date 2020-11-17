# Jordan Pappas, Katie Bisson, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  9 15:09:49 2020

@author: Katie
"""

import pandas as pd
import os
import numpy as np


### DATA
#os.chdir('/Users/Katie/Box/ShaleGas/Proj/oldnewdrillingclassify/data')
os.chdir('D:\Box Sync\ShaleGas\Proj\oldnewdrillingclassify\data')
wells = pd.read_csv('wellsextract2020_07_08.csv',low_memory=False) # state + county
samp = pd.read_csv('analyticsample_countyids.csv',low_memory=False) # county id for counties in samp


### CREATE ID FOR WELLS TO JOIN W/ SAMP
# 1 or 2 digit state code + 3 digit county code (style of 001)

# drop NAs first
# how many NAs dropped
x = len(wells)
wells = wells.dropna(subset=['STATE','COUNTY'])
y = len(wells)
x-y # 8880 dropped

# make sure leading 0s are there for counties
wells['COUNTY'] = wells['COUNTY'].astype(int)

ctystr = []
for i in wells['COUNTY']:
    if len(str(i))==3:
        ctystr.append(str(i))
    elif len(str(i)) == 2:
        ctystr.append('0' + str(i))
    else:
        ctystr.append('00' + str(i))
wells['COUNTY_STR'] = ctystr

# now state - no leading 0s for state in IDs so very easy
wells['STATE'] = wells['STATE'].astype(int)
wells['STATE'] = wells['STATE'].astype(str)

# now add state + county
wells['id'] = wells['STATE'] + wells['COUNTY_STR']
wells['id'].nunique()

###  COLLAPSE BY ID/TIME INTERVAL

# 1st check that all drilltype and productiontype are consistent - yep
print(wells['drilltype'].unique())
print(wells['productiontype'].unique())

# drop unwanted years
years = list(range(2000,2020)) # didn't work  
# criteria1 = wells['spud_year'].isin(['2000','2001','2002','2003','2004','2005',
#                                     '2006','2007','2008','2009','2010','2011',
#                                     '2012','2013','2014','2015','2016','2017',
#                                     '2018','2019'])
criteria = wells['spud_year'].isin(years)
# criteria1.equals(criteria2)
wells = wells[criteria]

# create 2000-2007 and 2008-2019 var    
wells['spud_year'] = wells['spud_year'].astype(int) 
period = []
for i in wells['spud_year']:
    if 2000 <= i <= 2007:
        period.append('1')
    elif 2008 <= i <= 2019:
        period.append('2')
    else:
        raise
wells['period'] = period

# create new oil/gas variable
OG_var = []
for i in wells['productiontype']:
    if i == 'OIL':
        OG_var.append('O')
    elif i == 'GAS' or i == 'GAS OR COALBED' or i == 'CBM':
        OG_var.append('G')
    elif i == 'OIL & GAS':
        OG_var.append('O&G')
    else:
        raise
wells['OG_var'] = OG_var
    

# create dummies and collapse by id/year
drilldummy = pd.get_dummies(wells['drilltype'])
drilldummy['H'] = drilldummy['H'] + drilldummy['D'] # H = D or H. add works because disjoint events
del drilldummy['D']
del drilldummy['U']
wells = pd.concat([wells,drilldummy], axis=1)

proddummy = pd.get_dummies(wells['OG_var'])
proddummy['O'] = proddummy['O'] + proddummy['O&G']
proddummy['G'] = proddummy['G'] + proddummy['O&G']
del proddummy['O&G']
wells = pd.concat([wells,proddummy], axis=1)

wells['counter'] = 1

collapse = wells.groupby(['id','period'])[['counter','H','V','G','O']].sum()
collapse = collapse.reset_index()
collapse = collapse.rename(columns={'counter':'TOTAL_WELLS'})

# collapse to just period 1, period 2 values
finalall = collapse.groupby('period').sum()

# cute formatting function + application (we want %)
def f(x,y):
    num = (x/y)*100
    k = format(num, '0.2f') #+ '%'
    return k

l = ['H','V','G','O']
for i in range(len(l)):
    x = finalall[l[i]]
    y = finalall['TOTAL_WELLS']
    finalall[l[i]] = np.vectorize(f)(x,y)
    

### CALC FOR SAMPLE

# convert samp to str
samp['countyid'] = samp['countyid'].astype(str)

# join samp w/ collapse
sampmerge = pd.merge(samp, collapse, left_on='countyid', right_on='id', how='left')

# collapse sample by period
finalsamp = sampmerge.groupby('period').sum()

# format as w/ finalall
l = ['H','V','G','O']
for i in range(len(l)):
    x = finalsamp[l[i]]
    y = finalsamp['TOTAL_WELLS']
    finalsamp[l[i]] = np.vectorize(f)(x,y)


### NUMBER OF COUNTIES
#wells['id'].nunique()
# be sure not to count ids containing nan for wells
uniquewellid = pd.DataFrame(wells['id'].unique())
uniquewellid.columns = ['id']
x = len(uniquewellid[uniquewellid['id'].str.contains('nan')]) # = 1 so 1 nan

allcounties = len(wells['id'].unique()) - x #1123
sampcounties = len(samp['countyid'].unique()) #442


### CREATE TABLE/DF

# transpose
tsamp = finalsamp.transpose()
tall = finalall.transpose()

# rename + reorder
tsamp = tsamp.rename(index={'TOTAL_WELLS' : 'Total Wells',
                            'H' : 'Percent Horizontal',
                            'V' : 'Percent Vertical',
                            'G' : 'Percent Gas',
                            'O' : 'Percent Oil'})
tall = tall.rename(index={'TOTAL_WELLS' : 'Total Wells',
                            'H' : 'Percent Horizontal',
                            'V' : 'Percent Vertical',
                            'G' : 'Percent Gas',
                            'O' : 'Percent Oil'})

# separate out the quadrants
place11 = tall['1']
place12 = tsamp['1']
place21 = tall['2']
place22 = tsamp['2']

# now make top half (2000-2007) and bottom half (2008-2019)
top = pd.DataFrame({'All Counties':place11, 'Counties in our Analytic Sample':place12})
bottom = pd.DataFrame({'All Counties':place21, 'Counties in our Analytic Sample':place22})

# this nonsense for the heading rows 2000-2007, 2008-2019
top_row = pd.DataFrame({'All Counties':[''],'Counties in our Analytic Sample':['']})
top = pd.concat([top_row, top])
bottom = pd.concat([top_row, bottom])

top = top.rename(index={0 : 'Wells Drilled (Spudded) 2000 through 2007'})
bottom = bottom.rename(index={0 : 'Wells Drilled (Spudded) 2008 through 2019'})

# put it together
final = pd.concat([top, bottom])

# now just add total # counties
num_cty = pd.DataFrame({'All Counties':[allcounties],
                        'Counties in our Analytic Sample':[sampcounties]})
num_cty = num_cty.rename(index={0:'Number of Counties'})

final = pd.concat([final, num_cty])

# export to csv
final.to_csv('summary_stats_table.csv')
