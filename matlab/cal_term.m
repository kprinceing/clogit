function output = cal_term(C_mod, temp_table6, e, indicator)

e = e - 1;
inter = temp_table6(C_mod(:,1),1);    
for k = 2:e
    inter(:,end+1) = temp_table6(C_mod(:,k),1);
end
inter(:,end+1) = temp_table6(1,3);
inter(:,end+1) =  temp_table6(1,2);
  perms_e = perms([1:e]);

if e==1
    out = sum([inter(:,1)./inter(:,end)...
                        .*inter(:,end-1)./(inter(:,end)-inter(:,1))]);
elseif e==2
    for l = 1:size(perms_e,1)
    out = [out; sum([inter(:,perms_e(l,1))./inter(:,end).*inter(:,perms_e(l,2))./(inter(:,end)-inter(:,perms_e(l,1))) ...
                        .*inter(:,end-1)./(inter(:,end)-inter(:,perms_e(l,1)))])];
    end
elseif e==3
    for l = 1:size(perms_e,1)
    out = [out; sum([inter(:,perms_e(l,1))./inter(:,end).*inter(:,perms_e(l,2))./(inter(:,end)-inter(:,perms_e(l,1))) ...
                        .*inter(:,perms_e(l,3))./(inter(:,end)-inter(:,perms_e(l,1))-inter(:,perms_e(l,2))) ...
                        .*inter(:,end-1)./(inter(:,end)-inter(:,perms_e(l,1))-inter(:,perms_e(l,2))-inter(:,perms_e(l,3)))])];
    end
elseif e==4
    for l = 1:size(perms_e,1)
        out = [out; sum([inter(:,perms_e(l,1))./inter(:,end).*inter(:,perms_e(l,2))./(inter(:,end)-inter(:,perms_e(l,1))) ...
                            .*inter(:,perms_e(l,3))./(inter(:,end)-inter(:,perms_e(l,1))-inter(:,perms_e(l,2))) ...
                            .*inter(:,perms_e(l,4))./(inter(:,end)-inter(:,perms_e(l,1))-inter(:,perms_e(l,2))-inter(:,perms_e(l,3))) ...
                            .*inter(:,end-1)./(inter(:,end)-inter(:,perms_e(l,1))-inter(:,perms_e(l,2))-inter(:,perms_e(l,3))-inter(:,perms_e(l,4)))])];
    end
end
output = indicator*sum(out);