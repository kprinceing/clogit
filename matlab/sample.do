local data_path C:/Users/1/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee_sample.dta,clear

    rename ind_id id

    gen clg_avlb   = (score>sch_cutoff) // college availability indicator
    gen clg_unavlb = 1-clg_avlb  // opposite indicator
    bysort id: egen num_clg_unavailable = total(clg_unavlb) // number of unavailable clgs
    
    gen indicator   = ns1_seg1 <= num_clg_unavailable
    
    keep id clg_id choice sch_score distance clg_avlb clg_unavlb indicator
	export delimited "C:\Users\1\Dropbox\college_entrance_exam\program\2018.12\matlab\sample.csv", replace
	
