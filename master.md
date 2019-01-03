# Program master file.
Data Files:
1. policy_20170712.dta:
    + NCEE policy data. 
2. rank_tier1.dta: ranking of tier1 schools using 软科2017.
3. ncee: student admission data.


## prepare.do 
+ Merge the ncee.dta with the rank_tier1.dta.
+ Check if the school lists can reasonably cover schools in tier1.
+ Generate ncee_rank.dta.
+ Generate sch_cutoff.dta.

## C_A_Num:
+ Python code to calculate the difference between CA and CS.
