function Vehicle = sm_car_vehcfg_setSteer(Vehicle,steer_opt,suspFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2023 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Get body from Vehicle.config to select consistent
% Init, Maneuver, and Driver
veh_config = Vehicle.config;
veh_config_set = strsplit(veh_config,'_');
veh_body =  veh_config_set{1};

% Code to permit Ackermann or none steering only with 15DOF suspension
% Issue warning if other type requested, set steering to None
if(strcmpi(Vehicle.Chassis.(suspFieldName).class.Value,'simple'))
    if(~strcmpi(steer_opt,'none_default') && ~contains(lower(steer_opt),'ackermann'))
        warning(['Requested steering option ' steer_opt ' not possible with simple suspension. Setting steering for ' suspFieldName ' to None.']);
        steer_opt = ['None_default'];        
    end
end

% If DriverHuman data exists within Steer already, store it and
% re-insert it into the data structure.
dh_exists = false;
if(isfield(Vehicle.Chassis.(suspFieldName),'Steer'))
    if(isfield(Vehicle.Chassis.(suspFieldName).Steer,'DriverHuman'))
        dh_exists = true;
        dh_data = Vehicle.Chassis.(suspFieldName).Steer.DriverHuman;
    end
end
        
% Copy data from database into Vehicle data structure
Vehicle.Chassis.(suspFieldName).Steer = VDatabase.Steer.(steer_opt);

% If DriverHuman data was already in Steer, re-insert it
% Note that DriverHuman location may not be compatible with Steer
% as the human needs to be close to the steering wheel mount hardpoint
if(dh_exists)
    Vehicle.Chassis.(suspFieldName).Steer.DriverHuman = dh_data;
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end