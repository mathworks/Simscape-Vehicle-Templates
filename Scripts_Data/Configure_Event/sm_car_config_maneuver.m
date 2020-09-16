function sm_car_config_maneuver(modelname,maneuver)
%sm_car_config_maneuver  Configure maneuver for Simscape Vehicle Model
%   sm_car_config_maneuver(modelname,maneuver)
%   This function configures the model to execute the desired maneuver.
%
% Copyright 2018-2020 The MathWorks, Inc.

% Find variant subsystems for settings
f=Simulink.FindOptions('regexp',1);
drive_h    =Simulink.findBlocks(modelname,'popup_driver_type','.*',f);
override_h =Simulink.findBlocks(modelname,'popup_override_type','.*',f);

% Get body from Vehicle.config to select consistent
% Init, Maneuver, and Driver
veh_config = evalin('base','Vehicle.config');
veh_config_set = strsplit(veh_config,'_');
veh_body =  veh_config_set{1};
maneuver_str = lower(maneuver);
if(~strcmpi(maneuver,'default'))
    maneuver_str =  lower([maneuver ' ' veh_body]);
end

% Assume no road surface height change
set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','None');

% Assume typical simulation stop conditions
set_param([modelname '/Check'],'start_check_time','5','stop_speed','0.1');
set_param(override_h,'popup_override_type','None');

% Assume no wind
sm_car_config_wind(modelname,0,0)

% Assume all points on trajectory will be checked
set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','No');

% Add case for new events here
% Set initial vehicle state and configure inputs
switch maneuver_str
    case 'default'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.WOT_Braking.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only

    case 'none hambalg'
        evalin('base','Init = IDatabase.Flat.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only
    case 'none hamba'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only
    case 'none makhulu'
        evalin('base','Init = IDatabase.Flat.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        sm_car_config_solver(modelname,'variable step'); % Default only
        
    case 'wot braking hambalg'
        evalin('base','Init = IDatabase.Flat.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.WOT_Braking.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'wot braking hamba'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.WOT_Braking.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'wot braking makhulu'
        evalin('base','Init = IDatabase.Flat.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.WOT_Braking.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        
    case 'ice patch hambalg'
        evalin('base','Init = IDatabase.Flat.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Ice_Patch.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Ice Patch');
    case 'ice patch hamba'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Ice_Patch.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Ice Patch');
    case 'ice patch makhulu'
        evalin('base','Init = IDatabase.Flat.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Ice_Patch.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Ice Patch');
        
    case 'low speed steer hambalg'
        evalin('base','Init = IDatabase.Flat.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Low_Speed_Steer.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'low speed steer hamba'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Low_Speed_Steer.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'low speed steer makhulu'
        evalin('base','Init = IDatabase.Flat.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Low_Speed_Steer.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        
    case 'turn hambalg'
        evalin('base','Init = IDatabase.Flat.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Turn.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'turn hamba'
        evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Turn.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
    case 'turn makhulu'
        evalin('base','Init = IDatabase.Flat.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Turn.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Plane Grid');
        
    case 'rdf rough road hambalg'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_HambaLG;');
        set_param(modelname,'StopTime','34');
        sm_car_config_road(modelname,'RDF Rough Road');
    case 'rdf rough road hamba'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_Hamba;');
        set_param(modelname,'StopTime','34');
        sm_car_config_road(modelname,'RDF Rough Road');
    case 'rdf rough road makhulu'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Bus_Makhulu;');
        set_param(modelname,'StopTime','34');
        sm_car_config_road(modelname,'RDF Rough Road');
        
    case 'rough road z only hambalg'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_HambaLG;');
        set_param(modelname,'StopTime','34');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Rough_Road');
        sm_car_config_road(modelname,'Rough Road Z Only');
    case 'rough road z only hamba'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_Hamba;');
        set_param(modelname,'StopTime','34');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Rough_Road');
        sm_car_config_road(modelname,'Rough Road Z Only');
    case 'rough road z only makhulu'
        evalin('base','Init = IDatabase.RDF_Rough_Road.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.RDF_Rough_Road.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Bus_Makhulu;');
        set_param(modelname,'StopTime','34');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Rough_Road');
        sm_car_config_road(modelname,'Rough Road Z Only');
        
    case 'rdf plateau hambalg'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        sm_car_config_road(modelname,'RDF Plateau');
    case 'rdf plateau hamba'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        sm_car_config_road(modelname,'RDF Plateau');
    case 'rdf plateau makhulu'
        evalin('base','Init = IDatabase.RDF_Plateau.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        sm_car_config_road(modelname,'RDF Plateau');
        
    case 'plateau z only hambalg'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Plateau');
        sm_car_config_road(modelname,'Plateau Z Only');
    case 'plateau z only hamba'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Plateau');
        sm_car_config_road(modelname,'Plateau Z Only');
    case 'plateau z only makhulu'
        evalin('base','Init = IDatabase.RDF_Plateau.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Plateau');
        sm_car_config_road(modelname,'Plateau Z Only');
        
    case 'crg plateau hambalg'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Plateau);');
        sm_car_config_road(modelname,'CRG Plateau');
    case 'crg plateau hamba'
        evalin('base','Init = IDatabase.RDF_Plateau.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Plateau);');
        sm_car_config_road(modelname,'CRG Plateau');
    case 'crg plateau makhulu'
        evalin('base','Init = IDatabase.RDF_Plateau.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Accel_NoBrake.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','30');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Plateau);');
        sm_car_config_road(modelname,'CRG Plateau');

    case 'double lane change hambalg'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Double_Lane_Change.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Double_Lane_Change.Sedan_HambaLG;');
        sm_car_config_road(modelname,'Double Lane Change');
        set_param(modelname,'StopTime','25');
    case 'double lane change hamba'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Double_Lane_Change.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Double_Lane_Change.Sedan_Hamba;');
        sm_car_config_road(modelname,'Double Lane Change');
        set_param(modelname,'StopTime','25');
    case 'double lane change makhulu'
        evalin('base','Init = IDatabase.Double_Lane_Change.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Double_Lane_Change.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Double_Lane_Change.Bus_Makhulu;');
        sm_car_config_road(modelname,'Double Lane Change');
        set_param(modelname,'StopTime','25');

    case 'drive cycle ftp75 hambalg'
        evalin('base','Init = IDatabase.DriveCycle_FTP75.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.DriveCycle.FTP75;');
        set_param(drive_h,'popup_driver_type','Drive Cycle');
        evalin('base','Driver = DDatabase.DriveCycle_FTP75.Sedan_HambaLG;');
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'Plane Grid');
        set_param(modelname,'StopTime','900');
    case 'drive cycle ftp75 hamba'
        evalin('base','Init = IDatabase.DriveCycle_FTP75.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.DriveCycle.FTP75;');
        set_param(drive_h,'popup_driver_type','Drive Cycle');
        evalin('base','Driver = DDatabase.DriveCycle_FTP75.Sedan_Hamba;');
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'Plane Grid');
        set_param(modelname,'StopTime','900');
    case 'drive cycle ftp75 makhulu'
        evalin('base','Init = IDatabase.DriveCycle_FTP75.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.DriveCycle.FTP75;');
        set_param(drive_h,'popup_driver_type','Drive Cycle');
        evalin('base','Driver = DDatabase.DriveCycle_FTP75.Bus_Makhulu;');
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'Plane Grid');
        set_param(modelname,'StopTime','900');
        
    case 'skidpad hamba'
        evalin('base','Init = IDatabase.Skidpad.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Skidpad.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Skidpad.Sedan_Hamba;');
        sm_car_config_road(modelname,'Skidpad');
        set_param(modelname,'StopTime','50');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
    case 'skidpad hambalg'
        evalin('base','Init = IDatabase.Skidpad.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Skidpad.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Skidpad.Sedan_HambaLG;');
        sm_car_config_road(modelname,'Skidpad');
        set_param(modelname,'StopTime','50');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
    case 'skidpad makhulu'
        evalin('base','Init = IDatabase.Skidpad.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Skidpad.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Skidpad.Bus_Makhulu;');
        sm_car_config_road(modelname,'Skidpad');
        set_param(modelname,'StopTime','50');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        
    case 'straight constant speed hambalg'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_HambaLG;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
    case 'straight constant speed hamba'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_Hamba;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
    case 'straight constant speed makhulu'
        evalin('base','Init = IDatabase.Double_Lane_Change.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Bus_Makhulu;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
        
    case 'trailer disturbance hambalg'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_HambaLG;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
        sm_car_config_wind('sm_car',0,1)
    case 'trailer disturbance hamba'
        evalin('base','Init = IDatabase.Double_Lane_Change.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Sedan_Hamba;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
        sm_car_config_wind('sm_car',0,1)
    case 'trailer disturbance makhulu'
        evalin('base','Init = IDatabase.Double_Lane_Change.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Straight_Constant_Speed_12_50.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Straight_Constant_Speed.Bus_Makhulu;');
        sm_car_config_road(modelname,'Road Two Lane');
        set_param(modelname,'StopTime','25');
        sm_car_config_wind('sm_car',0,1)
        
    case 'mallory park hambalg'
        evalin('base','Init = IDatabase.Mallory_Park.Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.Sedan_HambaLG;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
    case 'mallory park hamba'
        evalin('base','Init = IDatabase.Mallory_Park.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.Sedan_Hamba;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
    case 'mallory park makhulu'
        evalin('base','Init = IDatabase.Mallory_Park.Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.Bus_Makhulu;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
        
    case 'mallory park ccw hambalg'
        evalin('base','Init = IDatabase.Mallory_Park.CCW_Sedan_HambaLG;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.CCW_Sedan_HambaLG;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.CCW_Sedan_HambaLG;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
    case 'mallory park ccw hamba'
        evalin('base','Init = IDatabase.Mallory_Park.CCW_Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.CCW_Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.CCW_Sedan_Hamba;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
    case 'mallory park ccw makhulu'
        evalin('base','Init = IDatabase.Mallory_Park.CCW_Bus_Makhulu;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.CCW_Bus_Makhulu;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.CCW_Bus_Makhulu;');
        sm_car_config_road(modelname,'Track Mallory Park');
        set_param(modelname,'StopTime','200');
        
    case 'mallory park obstacle hamba'
        evalin('base','Init = IDatabase.Mallory_Park.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.Mallory_Park.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.Mallory_Park.Sedan_Hamba;');
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        set_param(override_h,'popup_override_type','Track Mallory Park Obstacle');
        sm_car_config_road(modelname,'Track Mallory Park Obstacle');
        set_param(modelname,'StopTime','200');
        
    case 'mcity hamba'
        evalin('base','Init = IDatabase.MCity.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.MCity.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.MCity.Sedan_Hamba;');
        set_param([modelname '/Check'],'start_check_time','30000','stop_speed','-50');
        sm_car_config_road(modelname,'MCity');
        set_param(modelname,'StopTime','50');
        
    case 'crg kyalami hamba'
        evalin('base','Init = IDatabase.CRG_Kyalami.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Kyalami.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Kyalami.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Kyalami);');
        sm_car_config_road(modelname,'CRG Kyalami');
        set_param(modelname,'StopTime','261');
        
    case 'crg kyalami f hamba'
        evalin('base','Init = IDatabase.CRG_Kyalami_F.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Kyalami_F.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Kyalami.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Kyalami_F);');
        sm_car_config_road(modelname,'CRG Kyalami F');
        set_param(modelname,'StopTime','261');
        
    case 'crg mallory park hamba'
        evalin('base','Init = IDatabase.CRG_Mallory_Park.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Mallory_Park.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Mallory_Park.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Mallory_Park);');
        sm_car_config_road(modelname,'CRG Mallory Park');
        set_param(modelname,'StopTime','200');
        
    case 'crg mallory park f hamba'
        evalin('base','Init = IDatabase.CRG_Mallory_Park_F.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Mallory_Park_F.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Mallory_Park.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Mallory_Park_F);');
        sm_car_config_road(modelname,'CRG Mallory Park F');
        set_param(modelname,'StopTime','200');
        
    case 'crg nurburgring n hamba'
        evalin('base','Init = IDatabase.CRG_Nurburgring_N.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Nurburgring_N.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Nurburgring_N.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Nurburgring_N);');
        sm_car_config_road(modelname,'CRG Nurburgring N');
        set_param(modelname,'StopTime','1134');
        
    case 'crg nurburgring n f hamba'
        evalin('base','Init = IDatabase.CRG_Nurburgring_N_F.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Nurburgring_N_F.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Nurburgring_N.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Nurburgring_N_F);');
        sm_car_config_road(modelname,'CRG Nurburgring N F');
        set_param(modelname,'StopTime','1140');
        
    case 'crg suzuka hamba'
        evalin('base','Init = IDatabase.CRG_Suzuka.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Suzuka.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Suzuka.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Suzuka);');
        sm_car_config_road(modelname,'CRG Suzuka');
        set_param(modelname,'StopTime','310');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        
    case 'crg suzuka f hamba'
        evalin('base','Init = IDatabase.CRG_Suzuka_F.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Suzuka_F.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Suzuka.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Suzuka_F);');
        sm_car_config_road(modelname,'CRG Suzuka F');
        set_param(modelname,'StopTime','310');
        % For only this maneuver, a window of points should be checked
        % The maneuver trajectory crosses itself.
        set_param([modelname '/Driver/Closed Loop/Maneuver'],'popup_window','Yes');
        
    case 'crg pikes peak hamba'
        evalin('base','Init = IDatabase.CRG_Pikes_Peak.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Pikes_Peak.Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Pikes_Peak.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Pikes_Peak);');
        sm_car_config_road(modelname,'CRG Pikes Peak');
        set_param(modelname,'StopTime','1485');
        
    case 'crg pikes peak down hamba'
        evalin('base','Init = IDatabase.CRG_Pikes_Peak_Down.Sedan_Hamba;');
        evalin('base','Maneuver = MDatabase.CRG_Pikes_Peak.Down_Sedan_Hamba;');
        set_param(drive_h,'popup_driver_type','Closed Loop');
        evalin('base','Driver = DDatabase.CRG_Pikes_Peak.Sedan_Hamba;');
        evalin('base','sm_car_scene_stl_create(Scene.CRG_Pikes_Peak);');
        sm_car_config_road(modelname,'CRG Pikes Peak');
        set_param(modelname,'StopTime','1485');
        
    case {'testrig 4 post hamba','testrig 4 post hambalg','testrig 4 post makhulu'}
        evalin('base','Init = IDatabase.Testrig_Post.Default;');
        evalin('base','Maneuver = MDatabase.None.Default;');
        set_param(drive_h,'popup_driver_type','Open Loop');
        set_param(modelname,'StopTime','20');
        sm_car_config_road(modelname,'Testrig 4 Post');
        set_param([modelname '/Road/Road Surface Height'],'LabelModeActiveChoice','Test_Cycle_1');
        set_param([modelname '/Check'],'start_check_time','100');
end

