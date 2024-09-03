function Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,people_opt,suspFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2024 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

if (people_opt(1))
    Vehicle.Chassis.(suspFieldName).Steer.DriverHuman.class.Value = 'Human';
else
    Vehicle.Chassis.(suspFieldName).Steer.DriverHuman.class.Value = 'None';
end

if (people_opt(2))
    Vehicle.Chassis.Body.Passenger.FL.class.Value = 'Human';
else
    Vehicle.Chassis.Body.Passenger.FL.class.Value = 'None';
end

if (people_opt(3))
    Vehicle.Chassis.Body.Passenger.FR.class.Value = 'Human';
else
    Vehicle.Chassis.Body.Passenger.FR.class.Value = 'None';
end

if (people_opt(4))
    Vehicle.Chassis.Body.Passenger.RL.class.Value = 'Human';
else
    Vehicle.Chassis.Body.Passenger.RL.class.Value = 'None';
end

if (people_opt(5))
    Vehicle.Chassis.Body.Passenger.RR.class.Value = 'Human';
else
    Vehicle.Chassis.Body.Passenger.RR.class.Value = 'None';
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end