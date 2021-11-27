function sm_car_config_maneuver(modelname,maneuver)
%sm_car_config_maneuver  Configure maneuver for Simscape Vehicle Model
%   sm_car_config_maneuver(modelname,maneuver)
%   This function configures the model to execute the desired maneuver.
%
% Copyright 2018-2021 The MathWorks, Inc.

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
set_param(override_h,'popup_override_type','None');

% Assume no wind
sm_car_config_wind(modelname,0,0)

% Assume constant gravity
set_param([modelname '/World'],'popup_gravity','Constant');

% Assume no constrants on vehicle
set_param([modelname '/Vehicle/Vehicle Constraint'],'LabelModeActiveChoice','NoConstraint');


% Assume all points on trajectory will be checked
set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','No');

% Add case for new events here
% Set initial vehicle state and configure inputs
switch maneuver_str

    % --- DEFAULT
    case 'default'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.WOT_Braking.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only

    % --- EMPTY
    case 'none'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only
        
    % --- Wide open throttle then braking
    case 'wot braking'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.WOT_Braking.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');
        
    % --- Ice patch
    case 'ice patch'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Ice_Patch.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Ice Patch');

    % --- Low Speed Steer
    case 'low speed steer'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Low_Speed_Steer.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');

    % --- Turn with braking
    case 'turn'
        evalin('base',['Init = IDatabase.Flat.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Flat.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Turn.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','40');
        sm_car_config_road(modelname,'Plane Grid');

    % --- Rough road based on RDF file
    case 'rdf rough road'
        evalin('base',['Init = IDatabase.RDF_Rough_Road.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.RDF_Rough_Road.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.RDF_Rough_Road.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Straight_Constant_Speed.' veh_inst ';']);
        set_param(modelname,'StopTime','34');
        sm_car_config_road(modelname,'RDF Rough Road');
        
    % --- Rough road based on RDF file, height only
    case 'rough road z only'
        evalin('base',['Init = IDatabase.RDF_Rough_Road.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.RDF_Rough_Road.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.RDF_Rough_Road.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Straight_Constant_Speed.' veh_inst ';']);
        set_param(modelname,'StopTime','34');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Rough_Road');
        sm_car_config_road(modelname,'Rough Road Z Only');

    % --- Plateau based on RDF file
    case 'rdf plateau'
        evalin('base',['Init = IDatabase.RDF_Plateau.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.RDF_Plateau.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Accel_NoBrake.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        sm_car_config_road(modelname,'RDF Plateau');

    % --- Plateau, height only (no slope at tire)
    case 'plateau z only'
        evalin('base',['Init = IDatabase.RDF_Plateau.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.RDF_Plateau.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Accel_NoBrake.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Plateau');
        sm_car_config_road(modelname,'Plateau Z Only');

    % --- Plateau
    case 'crg plateau'
        evalin('base',['Init = IDatabase.RDF_Plateau.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.RDF_Plateau.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Accel_NoBrake.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Plateau);');
        sm_car_config_road(modelname,'CRG Plateau');

    % --- Double Lane Change
    case 'double lane change'
        evalin('base',['Init = IDatabase.Double_Lane_Change.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Double_Lane_Change.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Double_Lane_Change.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Double_Lane_Change.' veh_inst ';']);
        sm_car_config_road(modelname,'Double Lane Change');
        set_param(modelname,'StopTime','35');

    % --- Drive Cycle FTP75
    case 'drive cycle ftp75'
        evalin('base',['Init = IDatabase.DriveCycle_FTP75.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.DriveCycle_FTP75.' init_inst_trl ';']);
        evalin('base','Maneuver = MDatabase.DriveCycle.FTP75;');
        set_param(drive_h,'popup_driver_type','Drive Cycle');
        evalin('base',['Driver = DDatabase.DriveCycle_FTP75.' veh_inst ';']);
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'Plane Grid');
        set_param(modelname,'StopTime','900');

    % --- Drive Cycle Urban Cycle 1
    case 'drive cycle urbancycle1'
        evalin('base',['Init = IDatabase.DriveCycle_UrbanCycle1.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.DriveCycle_UrbanCycle1.' init_inst_trl ';']);
        evalin('base','Maneuver = MDatabase.DriveCycle.UrbanCycle1;');
        set_param(drive_h,'popup_driver_type','Drive Cycle');
        evalin('base',['Driver = DDatabase.DriveCycle_UrbanCycle1.' veh_inst ';']);
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'Plane Grid');
        set_param(modelname,'StopTime','195');

    % --- Skidpad from Formula Student
    case 'skidpad'
        evalin('base',['Init = IDatabase.Skidpad.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Skidpad.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Skidpad.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Skidpad.' veh_inst ';']);
        sm_car_config_road(modelname,'Skidpad');
        set_param(modelname,'StopTime','50');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');

    % --- Constant Radius
    case 'constant radius closed-loop'
        evalin('base',['Init = IDatabase.Constant_Radius_CL.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Constant_Radius_CL.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Constant_Radius_CL.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Constant_Radius_CL.' veh_inst ';']);
        sm_car_config_road(modelname,'Constant Radius');
        set_param(modelname,'StopTime','25');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');

    % --- Straightline at constant speed
    case 'straight constant speed'
        evalin('base',['Init = IDatabase.Double_Lane_Change.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Double_Lane_Change.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Straight_Constant_Speed_12_50.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Straight_Constant_Speed.' veh_inst ';']);
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');

    % --- Trailer Disturbance
    case 'trailer disturbance'
        evalin('base',['Init = IDatabase.Double_Lane_Change.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Double_Lane_Change.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Straight_Constant_Speed_12_50.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Straight_Constant_Speed.' veh_inst ';']);
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
        sm_car_config_wind(modelname,0,1)

    % --- Mallory Park Circuit, Flat (not based on CRG)
    case 'mallory park'
        evalin('base',['Init = IDatabase.Mallory_Park.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Mallory_Park.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Mallory_Park.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Mallory_Park.' veh_inst ';']);
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');

    % --- Mallory Park Circuit Counterclockwise, flat (not based on CRG)
    case 'mallory park ccw'
        evalin('base',['Init = IDatabase.Mallory_Park.CCW_' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Mallory_Park.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Mallory_Park.CCW_' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Mallory_Park.' veh_inst ';']);
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');

    % --- Mallory Park Circuit with stoplights, flat (not based on CRG)
    case 'mallory park obstacle'
        evalin('base',['Init = IDatabase.Mallory_Park.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.Mallory_Park.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.Mallory_Park.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.Mallory_Park.' veh_inst ';']);
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        set_param(override_h,'popup_override_type','Track Mallory Park Obstacle');
        sm_car_config_road(modelname,'Track Mallory Park Obstacle');
        set_param(modelname,'StopTime','200');

    % --- MCity
    case 'mcity'
        evalin('base',['Init = IDatabase.MCity.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.MCity.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.MCity.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.MCity.' veh_inst ';']);
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'MCity');
        set_param(modelname,'StopTime','50');

    % --- crg kyalami
    case 'crg kyalami'
        evalin('base',['Init = IDatabase.CRG_Kyalami.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Kyalami.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Kyalami.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Kyalami.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Kyalami);');
        sm_car_config_road(modelname,'CRG Kyalami');
        set_param(modelname,'StopTime','280');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');        

    % --- crg kyalami f 
    case 'crg kyalami f'
        evalin('base',['Init = IDatabase.CRG_Kyalami_F.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Kyalami_F.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Kyalami_F.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Kyalami.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Kyalami_F);');
        sm_car_config_road(modelname,'CRG Kyalami F');
        set_param(modelname,'StopTime','280');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Mallory Park Circuit based on CRG with slope
    case 'crg mallory park'
        evalin('base',['Init = IDatabase.CRG_Mallory_Park.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Mallory_Park.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Mallory_Park.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Mallory_Park.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Mallory_Park);');
        sm_car_config_road(modelname,'CRG Mallory Park');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Mallory Park Circuit based on CRG, no slope
    case 'crg mallory park f'
        evalin('base',['Init = IDatabase.CRG_Mallory_Park_F.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Mallory_Park_F.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Mallory_Park_F.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Mallory_Park.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Mallory_Park_F);');
        sm_car_config_road(modelname,'CRG Mallory Park F');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');

    % --- CUSTOM EVENT based on CRG: placeholder for custom race circuit
    case 'crg custom'
        evalin('base',['Init = IDatabase.CRG_Custom.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Custom.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Custom.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Custom.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Custom);');
        sm_car_config_road(modelname,'CRG Custom');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- CUSTOM EVENT based on CRG, no slope: placeholder for custom race circuit
    case 'crg custom f'
        evalin('base',['Init = IDatabase.CRG_Custom_F.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Custom_F.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Custom_F.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Custom.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Custom_F);');
        sm_car_config_road(modelname,'CRG Custom F');
        set_param(modelname,'StopTime','200');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Nurburgring Nordschleife based on CRG with slope
    case 'crg nurburgring n'
        evalin('base',['Init = IDatabase.CRG_Nurburgring_N.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Nurburgring_N.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Nurburgring_N.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Nurburgring_N.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Nurburgring_N);');
        sm_car_config_road(modelname,'CRG Nurburgring N');
        set_param(modelname,'StopTime','1134');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Nurburgring Nordschleife based on CRG, no slope
    case 'crg nurburgring n f'
        evalin('base',['Init = IDatabase.CRG_Nurburgring_N_F.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Nurburgring_N_F.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Nurburgring_N_F.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Nurburgring_N.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Nurburgring_N_F);');
        sm_car_config_road(modelname,'CRG Nurburgring N F');
        set_param(modelname,'StopTime','1140');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Suzuka Circuit based on CRG, with slope
    case 'crg suzuka'
        evalin('base',['Init = IDatabase.CRG_Suzuka.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Suzuka.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Suzuka.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Suzuka.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Suzuka);');
        sm_car_config_road(modelname,'CRG Suzuka');
        set_param(modelname,'StopTime','310');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Suzuka Circuit based on CRG, no slope
    case 'crg suzuka f'
        evalin('base',['Init = IDatabase.CRG_Suzuka_F.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Suzuka_F.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Suzuka_F.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Suzuka.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Suzuka_F);');
        sm_car_config_road(modelname,'CRG Suzuka F');
        set_param(modelname,'StopTime','310');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        set_param([modelname '/Check'],'start_check_time_end_lap','20');
        
    % --- Pikes Peak Ascent based on CRG, with slope
    case 'crg pikes peak'
        evalin('base',['Init = IDatabase.CRG_Pikes_Peak.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Pikes_Peak.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Pikes_Peak.' veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Pikes_Peak.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Pikes_Peak);');
        sm_car_config_road(modelname,'CRG Pikes Peak');
        set_param(modelname,'StopTime','1485');
        
    % --- Pikes Peak Descent based on CRG, with slope
    case 'crg pikes peak down'
        evalin('base',['Init = IDatabase.CRG_Pikes_Peak_Down.' init_inst ';']);
        evalin('base',['Init_Trailer = IDatabase.CRG_Pikes_Peak_Down.' init_inst_trl ';']);
        evalin('base',['Maneuver = MDatabase.CRG_Pikes_Peak.Down_'  veh_inst ';']);
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base',['Driver = DDatabase.CRG_Pikes_Peak.' veh_inst ';']);
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Pikes_Peak);');
        sm_car_config_road(modelname,'CRG Pikes Peak');
        set_param(modelname,'StopTime','1485');
        
    % --- 4 Post Testrig
    case 'testrig 4 post'
        evalin('base','Init = IDatabase.Testrig_Post.Default;');
        evalin('base',['Init_Trailer = IDatabase.Testrig_Post.Default;']);
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Testrig 4 Post');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Test_Cycle_1');
        set_param([modelname '/Check'],'start_check_time','100');
        
end

