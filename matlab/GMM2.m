function f_obj=GMM2(params, sample, C2, C3, C4, C5, Emax)

%% Column Notation
% *       1                    2              3            4              5     
% *      id                 clg_id        choice     sch_score     dist    
% *       6                    7              8            9             10    
% *   clg_avlb         clg_unavlb        indicator     e_xb      sum_e_xb_c
% *      11                  12             13          14             15
% * sum_e_xb_ca   p_c(term2_1)              p_ca       term1     e_xb_choice 

%% Term 1

% col9 e_xb
e_xb = exp(sample(:,[4 5]) * params(1:2)); 
sample(:, end+1) = e_xb;
% col10 sum_e_xb_c
group_sum = accumarray(sample(:,1), e_xb);
sample(:, end+1) = group_sum(sample(:,1));
% col11 sum_e_xb_ca 
group_sum = accumarray(sample(sample(:,6)==1,1), e_xb(sample(:,6)==1,:));
sample(:, end+1) = group_sum(sample(:,1));
% col12-13 p_c p_ca
sample(:, end+1) = sample(:,9) ./ sample(:,10);
sample(:, end+1) = sample(:,9) ./ sample(:,11);
% col14 term1
sample(:, end+1) = (1-params(3).*sample(:,8)).*sample(:, 13);
term1 = sample(sample(:,3)==1, 14);
% col15 e_xb_choice
group_sum = accumarray(sample(sample(:,3)==1,1), e_xb(sample(:,3)==1,1));
sample(:, end+1) = group_sum(sample(:,1));

%% Term 2toEmax
term2toEmax = [unique(sample(:,1), 'rows'), sample(sample(:,3)==1,12)];
for i = 1:max(sample(:,1))
    temp_table6 = sample(sample(:,1)==i & sample(:,7)==1,[9 10 15]); %e_xb sumexbc exbchoice
    if size(temp_table6,1)>=4 && Emax>=5
        e = 5;
        C5_mod = C5(all(C5(:,1:e-1)<=size(temp_table6,1), 2),:);
        term2toEmax(i, 6) = cal_term(C5_mod, temp_table6, e, sample(sample(:,1)==1 & sample(:,3)==1,8));
    end
    if size(temp_table6,1)>=3 && Emax>=4
        e = 4;
        C4_mod = C4(all(C4(:,1:e-1)<=size(temp_table6,1), 2),:);
        term2toEmax(i, 5) = cal_term(C4_mod, temp_table6, e, sample(sample(:,1)==1 & sample(:,3)==1,8));
    end
    if size(temp_table6,1)>=2 && Emax>=3
        e = 3;
        C3_mod = C3(all(C3(:,1:e-1)<=size(temp_table6,1), 2),:);
        term2toEmax(i, 4) = cal_term(C3_mod, temp_table6, e, sample(sample(:,1)==1 & sample(:,3)==1,8));
    end    
    if size(temp_table6,1)>=1 && Emax>=2
        e = 2;
        C2_mod = C2(all(C2(:,1:e-1)<=size(temp_table6,1), 2),:);
        term2toEmax(i, 3) = cal_term(C2_mod, temp_table6, e, sample(sample(:,1)==1 & sample(:,3)==1,8));
    end  
end
%%
f_obj = -sum(log(term1 + params(3)*sum(term2toEmax(:,2:end),2)));