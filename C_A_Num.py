import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import statsmodels.formula.api as sm
import time

# Generate CA
# read in the gaokao raw data.
gaokao_df = pd.read_stata('C:/Users/yan/Dropbox/college_entrance_exam/data/ncee_rank.dta')
gaokao_df = gaokao_df[['provid', 'wave','clg_num','sch_rank', 'score']]
gaokao_df['score_rank'] = gaokao_df.groupby(['provid','wave'])['score'].rank(ascending=False).astype(int)
gaokao_df.sort_values(by=['provid','wave','score_rank'],inplace=True)

# generate the clg bar dataframe.
clg_df_grouped = gaokao_df[['score','clg_num','provid','wave']].groupby(['clg_num','provid','wave'])
clg_bar_df = clg_df_grouped.agg(np.min)
clg_bar_df.rename(columns={'score':'bar'},inplace=True)
clg_bar_df.reset_index(inplace=True)
clg_bar_df.dropna(inplace=True)
clg = clg_bar_df[['provid', 'wave', 'bar']]

# get clg_quota_df with school cumulative quota.
clg_df_grouped = gaokao_df[['sch_rank','score','clg_num','provid','wave']].groupby(['clg_num','provid','wave'])
clg_quota_df = clg_df_grouped.agg({'sch_rank':'mean','score':'count'}) # use different group functions for two columns
clg_quota_df.rename(columns={'score':'quota'},inplace=True)
clg_quota_df.reset_index(inplace=True)
clg_quota_df.dropna(inplace=True)
clg_quota_df.sort_values(by=['provid','wave','sch_rank'], inplace=True)
clg_quota_df.set_index(['provid','wave'],inplace=True) # set index for the groupby operation : cumsum
clg_quota_df['cum_quota'] = clg_quota_df.groupby(level=0)['quota'].cumsum()
clg_quota_df.reset_index(inplace=True)

# function to calculate the CA for a given individual with :
#   score, province and year.
#  versions of the functions:
     # gen_CA: 216 s for a 1 percent sample
     # np_gen_CA: 187s
     # np_gen_CA2: 135s
     # np_gen_CA3: 127s
def gen_CA(row):
    # select the score prov year
    score  = row['score']
    #print(score)
    prov  = row['provid']
    year = row['wave']
    
    # select a temp2 df from the clg_bar_df for a given prov year combination
    condition_1= clg_bar_df['provid']      == prov
    condition_2= clg_bar_df['wave']        == year
    
    temp = clg_bar_df.loc[condition_1 & condition_2].copy()
    temp.loc[:,'eligible'] = np.nan
    #print(temp.head())
    
    # within the temp2 df, generate a new column with 1 as the score larger than the cutoff, 0 smaller than the cutoff
    # one condition needs to be satisfied:
    # 1. Own score higher than the bar 
    
    temp.loc[:,'eligible'] = (temp.loc[:,'bar']<=score)
    #print(temp.head())

    # return the total number of 
    #print(temp['eligible'].sum())

    return temp['eligible'].sum()
def np_gen_CA(row):
    # select the score prov year
    score = row['score']
    # print(score)
    prov = row['provid']
    year = row['wave']

    # select a temp2 df from the clg_bar_df for a given prov year combination
    condition_1 = clg_bar_df['provid'] == prov
    condition_2 = clg_bar_df['wave'] == year

    temp = clg_bar_df.loc[condition_1 & condition_2].copy()
    temp.loc[:, 'eligible'] = np.nan
    a = temp.values
    # print(temp.head())

    # within the temp2 df, generate a new column with 1 as the score larger than the cutoff, 0 smaller than the cutoff
    # one condition needs to be satisfied:
    # 1. Own score higher than the bar

    temp.loc[:, 'eligible'] = np.where(a[:,3]<=score,1,0) # use np.where to achieve speed gains.
    # print(temp.head())

    # return the total number of
    # print(temp['eligible'].sum())

    return temp['eligible'].sum()
def np_gen_CA2(row):
    # select the score prov year
    score = row['score']
    # print(score)
    prov = row['provid']
    year = row['wave']

    # select a temp2 df from the clg_bar_df for a given prov year combination
    clg_bar_df.loc[:, 'eligible'] = np.nan
    condition_1 = clg_bar_df['provid'] == prov
    condition_2 = clg_bar_df['wave'] == year

    temp = clg_bar_df.loc[condition_1 & condition_2].values
    # print(temp.head())

    # within the temp2 df, generate a new column with 1 as the score larger than the cutoff, 0 smaller than the cutoff
    # one condition needs to be satisfied:
    # 1. Own score higher than the bar

    temp[:, 4] = np.where(temp[:,3]<=score,1,0) # use np.where to achieve speed gains.
    # print(temp.head())

    # return the total number of
    # print(temp['eligible'].sum())

    return temp[:, 4].sum()
def np_gen_CA3(row):
    # select the score prov year
    score = row['score']
    # print(score)
    prov = row['provid']
    year = row['wave']

    clg_bar_df.loc[:, 'eligible'] = np.nan

    # select a temp df from the clg_bar_df for a given prov year combination
    temp = clg_bar_df.loc[(clg_bar_df['provid'] == prov) & (clg_bar_df['wave'] == year)].values

    # within the temp2 df, generate a new column with 1 as the score larger than the cutoff, 0 smaller than the cutoff
    # one condition needs to be satisfied:
    # 1. Own score higher than the bar
    temp[:, 4] = np.where(temp[:,3]<=score,1,0) # use np.where to achieve speed gains.
    return temp[:, 4].sum()

def np_gen_CA4(row, clg):
     value = np.where(clg.loc[(clg['provid'] == row['provid']) & (clg['wave'] == row['wave']), 'bar'].values<=row['score'], 1, 0).sum()
     return value

# function to generate the rank of school a student can get in.
def get_CS(row):
    score_rank = row['score_rank']
    province = row['provid']
    year = row['wave']
    # print(score_rank)
    temp = clg_quota_df.loc[(clg_quota_df['provid'] == province) & (clg_quota_df['wave'] == year)].copy().values
    # columns of temp: provid  wave clg_num  sch_rank  quota  cum_quota
    pos = np.searchsorted(temp[:, 5],
                          score_rank) + 1  # use positional index to reference the cumsum column. more robust option?
    cs = temp[:, 5].size-pos
    # print(pos)
    return cs

# CA
t0 = time.time()
gaokao_df['CA'] = gaokao_df.iloc[0:100000,:].apply(np_gen_CA4,args=(clg,),axis=1)
t1 = time.time()
print(t1-t0)
print(gaokao_df['CA'].describe())

#CS
t0 = time.time()
gaokao_df['CS'] = gaokao_df.iloc[0:100000,:].apply(get_CS,axis=1)
t1 = time.time()
print(t1-t0)
print(gaokao_df['CS'].describe())

gaokao_df['diff_CACS']= gaokao_df['CA']-gaokao_df['CS']
print(gaokao_df['diff_CACS'].describe())