program clogit_sch_v2_mata
	version 14
	/* 
	model based on note cca181212 with naive type, no cautious type.
    can only handle e = 3
    
    parameters: 
        b: parameters for utility functions
        alpha: fraction of naive students
    
    terms in the likelihood function: 
        term1   = (1-alpha*(e<c_u(s_i))- \sum{k}(beta_k *(e<=k)))* p_ca
        term2_1 =  c_i is most preferred among all colleges. (p_c)
        term2_2 =  \sum{c_u}(c_ui is most preferred * c_i is second preferred)
        term2_3 =  \sum{c_u}(c_ui and c_uj is most preferred and second preferred
                   * c_i is third preferred)
	*/

	args todo b lnf 
	tempvar xb alpha e_xb sum_e_xb_c sum_e_xb_ca ///
	        p_c p_ca ///
	        term1 /// 
	        term2_1 term2_2 term2_3 ///
            p_1st p_2nd p_3rd ///

	local y $ML_y1
	mleval `xb'     = `b', eq(1)
	mleval `alpha'  = `b', eq(2)

    sort id
	// quietly{ 
        gen `e_xb'                     = exp(`xb')
        bysort id: egen `sum_e_xb_c'   = total(`e_xb') // switch to mata functions
 		bysort id: egen `sum_e_xb_ca'  = total(`e_xb')  if clg_available == 1 // switch to mata functions


		gen double `p_c'     = `e_xb'/`sum_e_xb_c'
		gen double `p_ca'    = `e_xb'/`sum_e_xb_ca'

        /*
        term1: all three types being assigned to top choice in their available set
               rational type: always in this group.
               naive type   : when the number of e > the number of unavailable college
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
                In total, there are e categories, as observed choice can be placed in any position in the preference list.
        */

        gen double `term2_1' = `p_c' // choice of college ranked 1st among all colleges
        // putmata e_xb = `e_xb' sum_e_xb_c = `sum_e_xb_c' id = id clg_id = clg_id clg_unavailable =clg_unavailable choice = choice
     mata:
/*           st_view(e_xb=., .,   "`e_xb'")  // replace with putmata command?
             st_view(sum_e_xb_c=., .,   "`sum_e_xb_c'")
             st_view(id=., .,   "id")
             st_view(clg_id=., .,   "clg_id")
             st_view(clg_unavailable=., .,   "clg_unavailable")
             st_view(choice=., .,   "choice") */
             term2_2 = rank_2(e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
             term2_3 = rank_3(e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
        end

        getmata `term2_2' =term2_2 `term2_3' =term2_3
      
        gen `lnfj'  = ln(`term1' + `alpha'*indicator_1*(`term2_1'+ `term2_2'+ `term2_3'))

		mlsum `lnf' = `lnfj' if `y' == 1
	// }
end
