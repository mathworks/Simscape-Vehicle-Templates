for vehi = 0:137
    eval(['load Vehicle_' pad(num2str(vehi),3,'left','0')]);
    eval(['load Vehicle_a' pad(num2str(vehi),3,'left','0')]);
    veh_var_0 = eval(['Vehicle_' pad(num2str(vehi),3,'left','0')]);
    veh_var_a = eval(['Vehicle_a' pad(num2str(vehi),3,'left','0')]);
    [common, d1, d2] = comp_struct(veh_var_0,veh_var_a);
    if(isempty(d1) && isempty(d2))
        disp(['Vehicle ' num2str(vehi) ': OK']);
    else
        disp(['Vehicle ' num2str(vehi) ': Mismatch']);
    end
end
    