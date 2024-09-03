function Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,arb_opt,suspFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2024 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Only permit anti-roll bar with Linkage suspension
if(strcmpi(Vehicle.Chassis.(suspFieldName).class.Value,'Linkage'))
    Vehicle.Chassis.(suspFieldName).AntiRollBar = VDatabase.AntiRollBar.(arb_opt);
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end