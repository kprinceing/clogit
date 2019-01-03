    clear mata
    quietly do clogit_sch_v2.mata
    

    * test 
    /* 
    Construct a 3 school case to test the rank_2 mata function.
    rank_2 should produce the probability of chosen college is ranked 2nd.
    the final result should be 0.15 based on given numerical values. 
     */
    mata:
    e_xb = (1\3\6)
    sum_e_xb_c=(10\10\10)
    id   = (1\1\1)
    clg_id = (1\2\3)
    clg_unavailable =(0\0\1)
    choice = (1\0\0)
    term2_2 = rank_2(e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
    term2_2
    end
    
    * test rank_2 when num_clg>e. should produce 0.1095
    clear mata
    quietly do clogit_sch_v2.mata

    mata:
    e_xb = (1\2\3\4)
    sum_e_xb_c=(10\10\10\10)
    id   = (1\1\1\1)
    clg_id = (1\2\3\4)
    clg_unavailable =(0\0\1\1)
    choice = (1\0\0\0)
    term2_2 = rank_2(e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
    term2_2
    end



    clear mata
    quietly do clogit_sch_v2.mata
    /* 
    Construct a 3 school case to test the rank_2 mata function.
    rank_2 should produce the probability of chosen college is ranked 2nd.
    the final result should be 0.7 based on given numerical values. 
     */
    mata:
    e_xb = (1\3\6)
    sum_e_xb_c=(10\10\10)
    id   = (1\1\1)
    clg_id = (1\2\3)
    clg_unavailable =(0\1\1)
    choice = (1\0\0)
    term2_3 = rank_3 (e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
    term2_3
    end


    * test rank_3 when num_clg>e. should produce 0.1238
    clear mata
    quietly do clogit_sch_v2.mata

    mata:
    e_xb = (1\2\3\4)
    sum_e_xb_c=(10\10\10\10)
    id   = (1\1\1\1)
    clg_id = (1\2\3\4)
    clg_unavailable =(0\0\1\1)
    choice = (1\0\0\0)
    term2_3 = rank_3(e_xb, sum_e_xb_c,id,clg_id,clg_unavailable,choice)
    term2_3
    end
