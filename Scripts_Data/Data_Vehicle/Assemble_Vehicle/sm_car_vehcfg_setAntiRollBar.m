function Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,arb_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

if(strcmpi(frontRear,'front'))
    switch arb_opt
        case 'Droplink_Sedan_HambaLG_f',    instance = 'Droplink_Sedan_HambaLG_f';
        case 'Droplink_Sedan_Hamba_f',      instance = 'Droplink_Sedan_Hamba_f';
        case 'Simple_default_f',            instance = 'Simple_default_f';
        case 'None',                        instance = 'None';
        case 'Droplink_Bus_Makhulu_f',      instance = 'Droplink_Bus_Makhulu_f';
    end
    suspfield = 'SuspF';
elseif(strcmpi(frontRear,'rear'))
    switch arb_opt
        case 'Droplink_Sedan_HambaLG_r',    instance = 'Droplink_Sedan_HambaLG_r';
        case 'Droplink_Sedan_Hamba_r',      instance = 'Droplink_Sedan_Hamba_r';
        case 'Simple_default_r',            instance = 'Simple_default_r';
        case 'None',                        instance = 'None';
        case 'Droplink_Bus_Makhulu_r',      instance = 'Droplink_Bus_Makhulu_r';
    end
    suspfield = 'SuspR';
end

% Only permit anti-roll bar with Linkage suspension
if(strcmpi(Vehicle.Chassis.(suspfield).class.Value,'Linkage'))
    Vehicle.Chassis.(suspfield).AntiRollBar = VDatabase.AntiRollBar.(instance);
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end