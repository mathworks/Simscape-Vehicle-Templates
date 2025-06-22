function par_list = sm_car_param_short_name(par_list)

% Create short name 
for par_i = 1:length(par_list)
    par_name = strrep(par_list(par_i).path2Val,'.Value','');
    perInd   = strfind(par_name,'.');
    par_name = par_name(perInd(end-1)+1:end);
    par_list(par_i).name = par_name;
end
