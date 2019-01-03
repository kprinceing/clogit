* test rank_2: should produce [0.15,0.15,0.15]'
    clear
    input e_xb sum_e_xb_c id clg_id clg_unavailable choice 
           1      10      1     1       0             1
           3      10      1     2       0             0
           6      10      1     3       1             0 
    end

    clear mata
    quietly do clogit_sch_v21.mata

    mata:

    term2_2 = rank_2("e_xb", "sum_e_xb_c","id","clg_id","clg_unavailable","choice")
    term2_2
    end

* test rank_3: should produce [0.70,0.70,0.70]'
    clear
    input e_xb sum_e_xb_c id clg_id clg_unavailable choice 
           1      10      1     1       0             1
           3      10      1     2       1             0
           6      10      1     3       1             0 
    end

    mata:
    term2_3 = rank_3("e_xb", "sum_e_xb_c","id","clg_id","clg_unavailable","choice")
    term2_3
    end
