function Vehicle = sm_car_vehcfg_setAero(Vehicle,aero_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

switch aero_opt
    case 'Bus_Makhulu',         instance = 'Bus_Makhulu';
    case 'Sedan_HambaLG',       instance = 'Sedan_HambaLG';
    case 'Sedan_Hamba',         instance = 'Sedan_Hamba';
    case 'Trailer_Elula',       instance = 'Trailer_Elula';
    case 'Trailer_Thwala',      instance = 'Trailer_Thwala';
end

% Copy data from database into Vehicle data structure
Vehicle.Chassis.Aero = VDatabase.Aero.(instance);

% Modify config string to indicate configuration has been modified

veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
end
