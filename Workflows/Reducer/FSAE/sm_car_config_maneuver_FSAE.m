function sm_car_config_maneuver(modelname,maneuver)
%sm_car_config_maneuver  Configure maneuver for Simscape Vehicle Model
%   sm_car_config_maneuver(modelname,maneuver)
%   This function configures the model to execute the desired maneuver.
%
% Copyright 2018-2025 The MathWorks, Inc.

% Find variant subsystems for settings
f=Simulink.FindOptions('regexp',1);
drive_h    =Simulink.findBlocks(modelname,'popup_driver_type','.*',f);
override_h =Simulink.findBlocks(modelname,'popup_override_type','.*',f);

% Get body from Vehicle.config to select consistent
% Init, Maneuver, and Driver
veh_config = evalin('base','Vehicle.config');
veh_config_set = strsplit(veh_config,'_');
veh_body =  lower(veh_config_set{1});

switch veh_body
    case 'hamba',        veh_inst = 'Sedan_Hamba';   init_inst = 'Sedan_Hamba';
    case 'hambalg',      veh_inst = 'Sedan_HambaLG'; init_inst = 'Sedan_HambaLG';
    case 'amandla3axle', veh_inst = 'Truck_Amandla'; init_inst = 'Truck_Amandla';
    case 'makhulu',      veh_inst = 'Bus_Makhulu';   init_inst = 'Bus_Makhulu';
    case 'makhulu3axle', veh_inst = 'Bus_Makhulu';   init_inst = 'Bus_Makhulu_Axle3';
    case 'achilles',     veh_inst = 'FSAE_Achilles'; init_inst = 'FSAE_Achilles';
    otherwise
        error(['Vehicle type ' veh_body ' not recognized.']);
end

% Get trailer type from model (Trailer.config, dropdown setting)
% to set consistent initial values for wheel speeds
trl_body = sm_car_vehcfg_getTrailerType(modelname);

switch trl_body
    case 'None',        trl_inst = 'None';      init_inst_trl = 'None';
    otherwise
        trl_inst = ['Trailer_' trl_body];       init_inst_trl = ['Trailer_' trl_body];
end

maneuver_str = lower(maneuver);
%if(~strcmpi(maneuver,'default'))
%    maneuver_str =  lower([maneuver ' ' veh_body]);
%end

% Assume no road surface height change
set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','None');

% Assume typical simulation stop conditions
set_param([modelname '/Check'],'start_check_time','5','stop_speed','0.1');
set_param([modelname '/Check'],'start_check_time_max_speed','20000','max_speed','0.4');
set_param([modelname '/Check'],'start_check_time_ld','10000','lat_dev_threshold','8');
set_param([modelname '/Check'],'start_check_time_end_lap','10000');
set_param([modelname '/Check'],'start_check_time_max_dist','10000','max_dist_threshold','10000');
set_param(override_h,'popup_override_type','None');

% Assume no wind
sm_car_config_wind(modelname,0,0)

% Assume constant gravity
set_param([modelname '/World'],'popup_gravity','Constant');

% Assume no constraints on vehicle
set_param([modelname '/Vehicle/Vehicle Constraint'],'LabelModeActiveChoice','NoConstraint');
set_param([modelname '/Vehicle/Vehicle'],'popup_BodyToWorld','Free');
set_param([modelname '/Vehicle/Vehicle'],'popup_wheel_spin','Free');


% Assume all points on trajectory will be checked
set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','No');


% Add case for new events here
% Set initial vehicle state and configure inputs
switch maneuver_str

    % --- Skidpad from Formula Student
    case 'skidpad'
        evalin('base',['Init_data_skidpad;']);
        evalin('base',['Maneuver_data_skidpad;']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Skidpad.' veh_inst ';']);
        sm_car_config_road(modelname,'Skidpad');

        % Ensure event runs until vehicle crosses finish line
        set_param(modelname,'StopTime','100');        
        % Stop maneuver when vehicle crosses finish line (xMax)
        set_param([modelname '/Check'],'start_check_time_max_dist','2','max_dist_threshold','Maneuver.xMax.Value');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        set_param([modelname '/World'],'popup_scene','Skidpad');

        % --- crg hockenheim
    case 'crg hockenheim'
        evalin('base',['Init_data_hockenheim;']);
        evalin('base',['Maneuver_data_hockenheim;']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Hockenheim.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Hockenheim);');
        sm_car_config_road(modelname,'CRG Hockenheim');
        %evalin('base',['roadFile = 'which(''CRG_Hockenheim.crg'')';
        set_param(modelname,'StopTime','400');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        set_param([modelname '/World'],'popup_scene','CRG Hockenheim');

        % --- crg hockenheim f
    case 'crg hockenheim f'
        evalin('base',['Init_data_hockenheim_f;']);
        evalin('base',['Maneuver_data_hockenheim_f;']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Hockenheim.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Hockenheim_F);');
        sm_car_config_road(modelname,'CRG Hockenheim F');
        set_param(modelname,'StopTime','400');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        set_param([modelname '/World'],'popup_scene','CRG Hockenheim F');

    case 'wot braking'
        evalin('base',['Init_data_wot_braking;']);
        evalin('base',['Maneuver_data_wot_braking']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');
end

