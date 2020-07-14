function Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,drivehuman_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Switch to select instance for steering
if(strcmpi(frontRear,'front'))
    switch drivehuman_opt
        case    'Sedan_Hamba',    instance = 'Sedan_Hamba';
        case    'Sedan_HambaLG',  instance = 'Sedan_HambaLG';
        case    'Bus_Makhulu',    instance = 'Bus_Makhulu';
        case    'None',           instance = 'None';
    end
    suspfield = 'SuspF';
elseif(strcmpi(frontRear,'rear'))
    switch drivehuman_opt
        case    'Sedan_Hamba',    instance = 'Sedan_Hamba';
        case    'Sedan_HambaLG',  instance = 'Sedan_HambaLG';
        case    'Bus_Makhulu',    instance = 'Bus_Makhulu';
        case    'None',           instance = 'None';
    end
    suspfield = 'SuspR';
end

% Copy data from database into Vehicle data structure
Vehicle.Chassis.(suspfield).Steer.DriverHuman = VDatabase.DriverHuman.(instance);

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end