version 14
mata:
real matrix rank_2(string scalar e_xb_1, 
                   string scalar sum_e_xb_c_1,
                   string scalar id_1,
                   string scalar clg_id_1,
                   string scalar clg_unavailable_1,
                   string scalar choice_1
                   )
/*
function rank_2: calculates the probability of chosen college ranked as 2nd in submitted preference list.
p_1st: probability of 1st among all. 
p_2nd: probability of choice 2nd among all-1. 
*/
{
	real matrix p_1st, p_2nd,m, clg_1
  real matrix temp_e_xb,temp_choice,temp_denom_k1,temp_exb_choice,temp_p_2nd, temp_term2_2,term2_2
	real scalar num_clg
  real matrix e_xb, sum_e_xb_c, id, clg_id,clg_unavailable,choice

  st_view(e_xb=., .,   e_xb_1)
  st_view(sum_e_xb_c=., .,   sum_e_xb_c_1)
  st_view(id=., .,   id_1)
  st_view(clg_id=., .,   clg_id_1)
  st_view(clg_unavailable=., .,   clg_unavailable_1)
  st_view(choice=., .,   choice_1)

	p_1st     = (e_xb:/sum_e_xb_c):*clg_unavailable  
  m         = panelsetup(id,1)

  
  term2_2   = J(0,1,.)

  for(i=1;i<=rows(m);i++){

      temp_e_xb       = panelsubmatrix(e_xb,i,m)  
      temp_choice     = panelsubmatrix(choice,i,m)
      temp_p_1st      = panelsubmatrix(p_1st,i,m)

      clg_1     = panelsubmatrix(clg_id,i,m)
      num_clg   = rows(clg_1)

      temp_denom_k1   = colsum(temp_e_xb):-temp_e_xb    
    	temp_exb_choice = colsum(temp_e_xb:*temp_choice) 
    	temp_p_2nd      = temp_exb_choice:/temp_denom_k1
      temp_term2_2    = J(num_clg,1,colsum(temp_p_1st:*temp_p_2nd))
      term2_2         = term2_2\temp_term2_2
    }
	                                
	return(term2_2)
}


real matrix rank_3(string scalar e_xb_1, 
                   string scalar sum_e_xb_c_1,
                   string scalar id_1,
                   string scalar clg_id_1,
                   string scalar clg_unavailable_1,
                   string scalar choice_1
                   )
/*
function rank_3: calculates the probability of chosen college ranked as 3rd in submitted preference list.
p_1st: probability of 1st among all.    matrix dimension: num_clg*1 
p_2nd: probability of 2nd among all-1.  matrix dimension: num_clg*num_clg. diagnoal terms set to .  
p_3rd: probability of choice ranked 3rd among all -2.   : num_clg*num_clg. 
term2_3: overall likelihood.
*/
{
	real matrix p_1st,p_2nd, p_3rd, m, clg_1
  real scalar num_clg,term2_3
  real matrix temp_e_xb, temp_e_xb_sum,temp_p_1st, temp_denom_k1, temp_p_2nd,temp_denom_k2,temp_choice
  real matrix temp_exb_choice,temp_p_3rd, temp_term2_3

  real matrix e_xb, sum_e_xb_c, id, clg_id,clg_unavailable,choice

  st_view(e_xb=., .,   e_xb_1)
  st_view(sum_e_xb_c=., .,   sum_e_xb_c_1)
  st_view(id=., .,   id_1)
  st_view(clg_id=., .,   clg_id_1)
  st_view(clg_unavailable=., .,   clg_unavailable_1)
  st_view(choice=., .,   choice_1)

	p_1st     = (e_xb:/sum_e_xb_c):*clg_unavailable      

  m         = panelsetup(id,1)


  term2_3   = J(0,1,.)

  for(i=1;i<=rows(m);i++){
    	temp_e_xb     = panelsubmatrix(e_xb,i,m)'
      temp_choice   = panelsubmatrix(choice,i,m)'
      temp_clg_unavailable = panelsubmatrix(clg_unavailable,i,m)'    
      temp_p_1st      = panelsubmatrix(p_1st,i,m)
      clg_1     = panelsubmatrix(clg_id,i,m) 
      num_clg   = rows(clg_1)

      temp_e_xb_sum = J(num_clg,num_clg,rowsum(temp_e_xb))
      temp_denom_k1 = temp_e_xb_sum :-temp_e_xb'    
      _diag(temp_denom_k1,0)
      temp_p_2nd    = (temp_e_xb:*temp_clg_unavailable):/ temp_denom_k1
      temp_denom_k2 = temp_e_xb_sum :-temp_e_xb:-temp_e_xb'    
      _diag(temp_denom_k2,0) // check if this line works when use view, not data
    	temp_exb_choice  = rowsum(temp_e_xb:*temp_choice)
      temp_p_3rd    = temp_exb_choice:/temp_denom_k2
      temp_term2_3  = J(num_clg,1,colsum(rowsum(temp_p_1st:*temp_p_2nd:*temp_p_3rd)))
      term2_3       = term2_3\temp_term2_3
	}
	return(term2_3)
}
end
