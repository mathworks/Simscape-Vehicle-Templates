function Vehicle = sm_car_vehcfg_setBodyGeometry(Vehicle,body_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

switch body_opt
    case 'Sedan_Scalable',      instance = 'Sedan_Scalable';    % Parameterized
    case 'CAD_Sedan_HambaLG',   instance = 'CAD_Sedan_HambaLG';
    case 'CAD_Sedan_Hamba',     instance = 'CAD_Sedan_Hamba';
    case 'CAD_Bus_Makhulu',     instance = 'CAD_Bus_Makhulu';
    case 'Trailer_Elula',       instance = 'Trailer_Elula';
    case 'CAD_Trailer_Thwala',  instance = 'CAD_Trailer_Thwala';
end

% Copy data from database into Vehicle data structure
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.(instance);

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end