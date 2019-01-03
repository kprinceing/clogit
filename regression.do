local data_path C:/Users/1/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee_sample.dta,clear

    
  * model version 1: without behavior types
    rename ind_id id
    gen clg_available = (score>sch_cutoff)
    keep if id <=100
    drop if id == 49

    keep if clg_available == 1    

    set more off
    cd C:/Users/1/Dropbox/college_entrance_exam/program/2018.12
    program drop _all
    global ML_id id 
    ml model d0 clogit_sch (eq1: choice = sch_score distance,noconstant) 
    ml check 
    ml max,difficult
  
    set more off
    asclogit choice sch_score distance, case(id) alternatives(clg_id)

    * model version 2: with behavior types
    /* varlist to generate:
        1. college availability indicator: clg_available
        2. number of unavailable colleges: num_clg_unavailable
        3. student rank within prov-year
        4. safe college: clg_safe_k
           4.1 for each k type, find out the top k schools. 
           4.2 for each k type, find out if the total capacity of the unavailable colleges
               and the top k available schools are less than the rank of the student in that prov-year.
           4.3 if the above condition is true, the rest of the available schools
               are safe schools. 
        5. e<num_clg_unavailable:  e_cu
        6. 
     */

*   model version 2: add naive type 
local data_path C:/Users/1/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee_sample.dta,clear

    rename ind_id id
    rename rank clg_rank

    gen clg_available = (score>sch_cutoff) // college availability indicator
    gen clg_unavailable = 1-clg_available  // opposite indicator
    bysort id: egen num_clg_unavailable = total(clg_unavailable) // number of unavailable clgs
    
    gen indicator_1   = ns1_seg1 <= num_clg_unavailable
    
    * xtset id clg_id // necessary when use xfill

    set more off
    keep if id <=100
    drop if id == 49
    bysort id: egen clg_num = count(clg_id)

    cd C:/Users/1/Dropbox/college_entrance_exam/program/2018.12
   
    program drop _all
    clear mata
    do clogit_sch_v21.mata

    set more off
    global ML_id id 
    ml model d0 clogit_sch_v21_mata (eq1: choice = sch_score distance,noconstant) (eq2:)
    ml max,difficult


/**   model version 3: add naive and cautious type
    rename ind_id id
    rename rank clg_rank

    gen clg_available = (score>sch_cutoff) // college availability indicator
    gen clg_unavailable = 1-clg_available  // opposite indicator
    bysort id: egen num_clg_unavailable = total(clg_unavailable) // number of unavailable clgs
    
    bysort prov wave : egen student_rank = rank(score),field // student rank
    
    bysort id:  egen clg_rank_available   = rank(clg_rank) if clg_available == 1, unique // 3 
    bysort prov wave clg_string: egen clg_capacity = count(score) if choice == 1

    forvalues i=1/4{
    	gen clg_risky_`i' = ((clg_unavailable == 1) | (clg_rank_available<= `i')) 
        bysort id: egen clg_risky_`i'_capacity = total(clg_capacity) if clg_risky_`i' == 1
        gen risky_`i'_condition  = (student_rank>=clg_risky_`i'_capacity)
        gen clg_safe_`i' = 1 if (clg_available == 1) & (clg_risky_`i' == 0) & (risky_`i'_condition == 1)
    }

    gen indicator_1   = ns1_seg1 < num_clg_unavailable*/
