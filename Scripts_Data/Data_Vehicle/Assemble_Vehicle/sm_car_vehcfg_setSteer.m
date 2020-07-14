function Vehicle = sm_car_vehcfg_setSteer(Vehicle,steer_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Get body from Vehicle.config to select consistent
% Init, Maneuver, and Driver
veh_config = Vehicle.config;
veh_config_set = strsplit(veh_config,'_');
veh_body =  veh_config_set{1};

% Code to permit Ackermann or none steering only with 15DOF suspension
if(strcmpi(Vehicle.Chassis.SuspF.class.Value,'simple')...
        && strcmpi(frontRear,'front'))
    if(~strcmpi(steer_opt,'none_default'))
        steer_opt = ['Ackermann_' veh_body '_f'];
    end
end

% Switch to select instance for steering
if(strcmpi(frontRear,'front'))
    switch steer_opt
        case              'Ackermann_HambaLG_f',  instance = 'Ackermann_HambaLG_f';
        case                'Ackermann_Hamba_f',  instance = 'Ackermann_Hamba_f';
        case             'Rack_Sedan_HambaLG_f',  instance = 'Rack_Sedan_HambaLG_f';
        case        'RackWheel_Sedan_HambaLG_f',  instance = 'RackWheel_Sedan_HambaLG_f';
        case 'RackStaticShafts_Sedan_HambaLG_f',  instance = 'RackStaticShafts_Sedan_HambaLG_f';
        case 'RackDrivenShafts_Sedan_HambaLG_f',  instance = 'RackDrivenShafts_Sedan_HambaLG_f';
        case  'WheelDrivenRack_Sedan_HambaLG_f',  instance = 'WheelDrivenRack_Sedan_HambaLG_f';
        case          'RackWheel_Sedan_Hamba_f',  instance = 'RackWheel_Sedan_Hamba_f';
        case          'RackWheel_Bus_Makhulu_f',  instance = 'RackWheel_Bus_Makhulu_f';
        case 'None_default',                      instance = 'None_default';
    end
    suspfield = 'SuspF';
elseif(strcmpi(frontRear,'rear'))
    switch steer_opt
        case 'Rack_Sedan_HambaLG_r',  instance = 'Rack_Sedan_HambaLG_r';
        case 'None_default',          instance = 'None_default';
    end
    suspfield = 'SuspR';
end

% Copy data from database into Vehicle data structure
Vehicle.Chassis.(suspfield).Steer = VDatabase.Steer.(instance);

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end