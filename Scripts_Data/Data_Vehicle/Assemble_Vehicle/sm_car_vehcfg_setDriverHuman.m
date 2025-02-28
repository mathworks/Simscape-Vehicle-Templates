function Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,drivehuman_opt,suspFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2024 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Copy data from database into Vehicle data structure
Vehicle.Chassis.(suspFieldName).Steer.DriverHuman = VDatabase.DriverHuman.(drivehuman_opt);

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end