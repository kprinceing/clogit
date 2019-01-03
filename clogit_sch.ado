program clogit_sch 
	version 14
	/* 
	model: lnfi = exp(xb)/(\sum exp(xb))
	*/
	args todo b lnf 
	tempvar xb e_xb sum_e_xb lnfj

	// local group_id $ML_id 
	local y $ML_y1

	mleval `xb' = `b', eq(1)
    sort id
	quietly{
		gen `e_xb' = exp(`xb')
 		bysort id: egen `sum_e_xb' = total(`e_xb')
		gen double `lnfj'   = ln(`e_xb'/`sum_e_xb')
		mlsum `lnf' = `lnfj' if `y' == 1
	}
end
