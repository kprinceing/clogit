program clogit_sch_v2
	version 14
	/* 
	model based on note cca181212 with naive type, no cautious type.
    parameters: 
        b: parameters for utility functions
        alpha: fraction of naive students
    
    terms in the likelihood function: 
        term1   = (1-alpha*(e<c_u(s_i))- \sum{k}(beta_k *(e<=k)))* p_ca
        term2_1 =  c_i is most preferred among all colleges. (p_c)
        term2_2 =  \sum{c_u}(c_ui is most preferred * c_i is second preferred)
        term2_3 =  \sum{c_u}(c_ui and c_uj is most preferred and second preferred
                   * c_i is third preferred)
        term2_4 =  \sum{c_u}(c_ui,c_uj, c_uk are top3 preferred
                         * c_i is fourth preferred)
        (the number of term2 = the number of e)
	*/

	args todo b lnf 
	tempvar xb alpha e_xb sum_e_xb_c sum_e_xb_ca /// *xb and e(xb) terms
	        p_c p_ca ///
	        term1 /// 
	        term2_1 term2_2 term2_3 term2_4 ///
            p_1st p_2nd p_3rd p_4th ///
            denom_2nd denom_3rd denom_4th

	local y $ML_y1
	mleval `xb'     = `b', eq(1)
	mleval `alpha'  = `b', eq(2)

    sort id
	quietly{ 
        gen `e_xb'                     = exp(`xb')
        bysort id: egen `sum_e_xb_c'   = total(`e_xb') 
 		bysort id: egen `sum_e_xb_ca'  = total(`e_xb')  if clg_available == 1


		gen double `p_c'     = `e_xb'/`sum_e_xb_c'
		gen double `p_ca'    = `e_xb'/`sum_e_xb_ca'

        /*
        term1: all three types being assigned to top choice in their available set
               rational type: always in this group.
               naive type   : when the number of e > the number of unavailable college
               cautious type: when the number of e > the risky type
        */
        gen double `term1'   = (1-`alpha'*indicator_1)*`p_ca'
        
        /*
        term2:  naive type and e < number of unavailable colleges. 
                break down term2 into e categories:
                term2_1: choice college ranked 1st among all colleges.
                term2_2: any college j  ranked 1st among all colleges, and 
                         choice college ranked 2nd among all colleges except college j.
                         Loop over all possible cases to get term2_2.
                         Each case treat college other than observed choice as most preferred, and college j as second 
                         most preferred
                term2_3: similar as term2_2, except needs 2 loops. 
                .
                  .
                .
                In total, there are e categories, as observed choice can be placed in any position 
                in the preference list.
        */

        gen double `term2_1' = `p_c' // choice of college ranked 1st among all colleges

        sum clg_id // return total num of clgs
        local clg_max = r(max)
        gen double `term2_2' = .  // choice of college ranked in the 2nd among all colleges
        forvalues j = 1/`clg_max'{
        	gen double `p_1st' =  `e_xb' / `sum_e_xb_c' if clg_id   == `j' & clg_unavailable == 1 // clg j's prob as ranked 1st
        	bysort id (`p_1st'): replace `p_1st' = `p_1st'[1] // expand p_1st to all obs within id

        	bysort id: egen `denom_2nd'  = total(`e_xb')  if clg_id !=`j' & clg_available == 1 // denominator of choice clg ranked 1st among colleges other than j
        	gen `p_2nd' =  (`p_1st')*(`e_xb'/`denom_2nd')     // joint probability

            replace `term2_2' = `term2_2' + `p_2nd'  // sum over all cases
            drop `p_1st' `denom_2nd' `p_2nd'
        }

        * repeat the procedures above for all term2_3 variables
        gen double `term2_3' = .  // choice of college ranked in the 3rd among all colleges
        forvalues j = 1/`clg_max'{
        	forvalues k = 1/`clg_max'{
        	    gen `p_1st' =  `e_xb' / `sum_e_xb_c' if clg_id == `j' & clg_unavailable == 1 // clg j's prob as ranked 1st
                bysort id (`p_1st'): replace `p_1st' = `p_1st'[1] // expand p_1st to all obs within id
   
        	    bysort id: egen `denom_2nd'  = total(`e_xb')  if clg_id !=`j'  // denominator of clg ranked 2nd among colleges other than j
        	    gen `p_2nd' =  (`p_1st')*(`e_xb'/`denom_2nd') if clg_id == `k' & clg_unavailable == 1 // joint probability
                bysort id (`p_2nd'): replace `p_2nd' = `p_2nd'[1] // expand p_1st to all obs within id

        	    bysort id: egen `denom_3rd'  = total(`e_xb')  if clg_id !=`j' & clg_id != `k' clg_available == 1  // denominator of clg ranked 2nd among colleges other than j
        	    gen `p_3rd' =  (`p_2nd')*(`e_xb'/`denom_3rd') // joint probability
    
                replace `term2_3' = `term2_3' + `p_3rd'  // sum over all cases
                drop `p_1st' `denom_2nd' `p_2nd' `denom_3rd' `p_3rd'
            }
        }

      * repeat the procedures above for all term2_4 variables
        gen double `term2_4' = .  // choice of college ranked in the 4th among all colleges
        forvalues j = 1/`clg_max'{
        	forvalues k = 1/`clg_max'{
        		forvalues l = 1/`clg_max'{
        	        gen `p_1st' =  `e_xb' / `sum_e_xb_c' if clg_id == `j' & clg_unavailable == 1 // clg j's prob as ranked 1st
                    bysort id (`p_1st'): replace `p_1st' = `p_1st'[1] // expand p_1st to all obs within id

        	        bysort id: egen `denom_2nd'  = total(`e_xb')  if clg_id !=`j'  // denominator of clg ranked 2nd among colleges other than j
        	        gen `p_2nd' =  (`p_1st')*(`e_xb'/`denom_2nd') if clg_id == `k' & clg_unavailable == 1 // joint probability
                    bysort id (`p_2nd'): replace `p_2nd' = `p_2nd'[1] // expand p_1st to all obs within id

        	        bysort id: egen `denom_3rd'  = total(`e_xb')  if clg_id !=`j' & clg_id != `k' // denominator of clg ranked 2nd among colleges other than j
        	        gen `p_3rd' =  (`p2nd')*(`e_xb'/`denom_3rd')  if clg_id == `l' & clg_unavailable == 1 // joint probability
                    bysort id (`p_3rd'): replace `p_3rd' = `p_3rd'[1] // expand p_1st to all obs within id

        	        bysort id: egen `denom_4th'  = total(`e_xb')  if clg_id !=`j' & clg_id != `k' & clg_id != `l' // denominator of clg ranked 2nd among colleges other than j
        	        gen `p_4th' =  (`p_3rd')*(`e_xb'/`denom_4th') & clg_available == 1  // joint probability

                    replace `term2_4' = `term2_4' + `p_4th'  // sum over all cases
                    drop `p_1st' `denom_2nd' `p_2nd' `denom_3rd' `p_3rd' `denom_4th' `p_4th'
                }
            }
        }

      
        gen `lnfj'    = ln(`term1' + `alpha'*indicator_1*(`term2_1'+ `term2_2'+ `term2_3'+`term2_4')) ///

		mlsum `lnf' = `lnfj' if `y' == 1
	}
end
