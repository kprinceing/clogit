 
    webuse choice,clear   
    set more off

    gen japan = car==2
    gen europe = car ==3 
    
    
    cd C:/Users/yan/Dropbox/college_entrance_exam/program/2018.12
    program drop _all
    global ML_id id 
    ml model d0 clogit_sch (eq1: choice = dealer japan europe,noconstant) 
    ml check 
    ml max
  
 
