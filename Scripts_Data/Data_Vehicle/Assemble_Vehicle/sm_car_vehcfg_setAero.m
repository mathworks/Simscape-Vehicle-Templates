function Vehicle = sm_car_vehcfg_setAero(Vehicle,aero_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2023 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Copy data from database into Vehicle data structure
Vehicle.Chassis.Aero = VDatabase.Aero.(aero_opt);

% Modify config string to indicate configuration has been modified

veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end
