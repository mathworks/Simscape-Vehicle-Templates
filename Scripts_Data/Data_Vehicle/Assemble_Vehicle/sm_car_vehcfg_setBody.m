function Vehicle = sm_car_vehcfg_setBody(Vehicle,body_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2021 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Copy data from database into Vehicle data structure
Vehicle.Chassis.Body = VDatabase.Body.(body_opt);

% Modify config string to indicate configuration has been modified
% Platform is decided by body type, which defines length
    % Field config does not exist when Vehicle structure is first created
    veh_body_set =  strsplit(body_opt,'_');
    Vehicle.config =  veh_body_set{2};
end