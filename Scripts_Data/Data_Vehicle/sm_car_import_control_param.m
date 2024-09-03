function control_param = sm_car_import_control_param

curr_dir = pwd;
cd(fileparts(which('sm_car.slx')));
dirStr = ['.' filesep 'Libraries' filesep '**' filesep 'sm_car_controlparam_*.m'];
control_param_file_list = dir(dirStr);

[~, alpha_ind] = sort({control_param_file_list.name});

control_param = '';
for control_i = 1:length(control_param_file_list)
    [~,fname] = fileparts(control_param_file_list(alpha_ind(control_i)).name);
    disp(['Adding ' fname]);
    eval(['new_control_param = ' fname  ';']);
    if(~isempty(control_param))
        control_names = fieldnames(control_param);
    else
        control_names = '';
    end
    new_control_name = matlab.lang.makeValidName(new_control_param.Name);
    if(~isempty(control_param))
        unique_names = matlab.lang.makeUniqueStrings({control_names{:} new_control_name});
    else
        unique_names = {new_control_name};
    end
    control_param.(unique_names{end}) = new_control_param;
end

cd(curr_dir)