function scene_data = sm_car_import_scene_data

curr_dir = pwd;
cd(fileparts(which('sm_car.slx')));
scene_data_file_list = dir('**/sm_car_scenedata_*.m');

[~, alpha_ind] = sort({scene_data_file_list.name});

scene_data = '';
for scene_i = 1:length(scene_data_file_list)
    [~,fname] = fileparts(scene_data_file_list(alpha_ind(scene_i)).name);
    disp(['Adding ' fname]);
    eval(['new_scene_data = ' fname  ';']);
    if(~isempty(scene_data))
        scene_names = fieldnames(scene_data);
    else
        scene_names = '';
    end
    new_scene_name = matlab.lang.makeValidName(new_scene_data.Name);
    if(~isempty(scene_data))
        unique_names = matlab.lang.makeUniqueStrings({scene_names{:} new_scene_name});
    else
        unique_names = {new_scene_name};
    end
    scene_data.(unique_names{end}) = new_scene_data;
end

scene_data.Reference.yaw   = 0; % rad
scene_data.Reference.pitch = 0; % rad
scene_data.Reference.roll  = 0; % rad
cd(curr_dir)