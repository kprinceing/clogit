* Generate school rank data.

local data_path C:/Users/1/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee.dta,clear
	
	rename wenlike wenke 

	keep   if wenke == 0 // use only the science track
	drop   if clg_string =="" // drop obs with missing school variable

	encode clg_string, gen(clg_num) // numeric id for schools


	gen tier1 = (score>ns1_bar_sci) // indicator variable for students with score above tier1 cutoff
	bysort clg_num: egen tier1_ratio = mean(tier1)

	merge m:1 clg_string using rank_tier1
	
	rename rank sch_rank

	table _merge, c(mean tier1_ratio) 

	keep if _merge == 3

save ncee_rank.dta, replace

* Generate school cutoff data.
local data_path C:/Users/yan/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee_rank.dta,clear
	collapse (min) sch_cutoff = score, by(prov wave clg_string)
save sch_cutoff.dta, replace

* Generate province school distance data
local data_path C:/Users/yan/Dropbox/college_entrance_exam/data
cd "`data_path'"
clear
import excel "prov_clg_geo_finished.xlsx", sheet("Sheet1") firstrow
keep provid clg_string distance
save prov_clg_geo_finished, replace



* Generate a sample for preliminary estimation
local data_path C:/Users/1/Dropbox/college_entrance_exam/data
cd "`data_path'"
use ncee_rank.dta,clear

    keep if provid == 34 & (wave ==2007 | wave ==2008) // keep one province in years with e change
    keep if score>ns1_bar_sci          // keep students with score higher than tier-1 cutoff 
    keep score provid wave clg_string ns1_seg1 // keep relevant variables

    * Transform the data to have a long form:
    * 1. Dimension 1: Individual;
    * 2. Dimension 2: Choice (college)
    * Steps: 
    * 1. Generate individual ID
    * 2. Generate dummy variable for each college in sample.
    * 3 .Merge the clg dummy variable to all clg characteristics dataset. 
    * 4. Expand the dataset by the number of colleges in sample. 
    * 5. Generate clg id. (to merge with clg characteristic dataset)
    * 6. Generate choice variable. 
    * 7. Merge the college characteristics dataset. 
    * 8. Merge to get student college distance.
    * 9. Generate other necessary variables: 
         * 8.1. c_a  : dummy indicating this school is available to this student


    gen  ind_id  = _n // 1
    egen clg_num = group(clg_string) // 2 
    save temp, replace
    
    * step 3
    use temp.dta, clear
    collapse (mean) clg_num, by(clg_string)
    rename clg_num clg_id
    save clg_id, replace

    use sch_cutoff,clear
    merge m:1 clg_string using clg_id
    keep if _merge == 3
    duplicates report provid wave clg_id
    drop _merge
    save sch_cutoff_id, replace

    use rank_tier1,clear
    merge 1:1 clg_string using clg_id
    keep if _merge == 3
    duplicates report clg_id
    drop _merge
    save rank_tier1_id, replace

    use prov_clg_geo_finished,clear 
    merge m:1 clg_string using clg_id
    keep if _merge == 3
    duplicates report provid clg_id
    drop _merge
    save prov_clg_geo_finished_id, replace


    use temp,clear
    sum  clg_num 
    expand r(max) //4 
    sort ind_id clg_num 
    bysort ind_id: gen clg_id = _n //5
    gen  choice  = (clg_num == clg_id) //6 
    drop clg_num 

    merge m:1 provid wave clg_id using sch_cutoff_id  // 7: merge to get cutoff score.
    keep if _merge == 3 
    drop _merge 

    merge m:1 clg_id using rank_tier1_id  // 8: merge to get school quality index
    keep if _merge == 3 
    drop _merge 

    merge m:1 provid clg_id using prov_clg_geo_finished_id // 9: merge to get distance variable
    keep if _merge == 3
    drop _merge 

save ncee_sample, replace
