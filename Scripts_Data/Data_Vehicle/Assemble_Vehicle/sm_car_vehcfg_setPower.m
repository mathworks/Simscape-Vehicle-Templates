function Vehicle = sm_car_vehcfg_setPower(Vehicle,power_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.
VDatabase = evalin('base','VDatabase');

switch power_opt
    case 'Ideal1Motor_default',      instance = 'Ideal1Motor_default';
    case 'Ideal2Motor_default',      instance = 'Ideal2Motor_default';
    case 'Electric2Motor_default',   instance = 'Electric2Motor_default';
    case 'Electric3Motor_default',   instance = 'Electric3Motor_default';
    case 'FuelCell1Motor_default',   instance = 'FuelCell1Motor_default';
    case 'None',                     instance = 'None';
end

% If subfield Cooling has been defined save the settings
temp_cooling = 'no data';
if(isfield(Vehicle,'Powertrain'))
    % Check for Powertrain field for creation of Vehicle data structure
    if(isfield(Vehicle.Powertrain,'Power'))
        % Check for Power field for creation of Vehicle data structure
        if(isfield(Vehicle.Powertrain.Power,'Cooling'))
            temp_cooling = Vehicle.Powertrain.Power;
        end
    end
end

% Load database of vehicle data into local workspace
Vehicle.Powertrain.Power = VDatabase.Power.(instance);

% If subfield Cooling was previously defined, reload settings
if(isfield(Vehicle.Powertrain.Power,'Cooling') && ...
        ~strcmp(temp_cooling,'no data'))
    Vehicle.Powertrain.Power.Cooling = temp_cooling;
end

if(strcmp(power_opt,'FuelCell1Motor_default'))
    Vehicle.Powertrain.Power.Cooling = VDatabase.Cooling.FuelCell1Motor_default;
    Vehicle.Powertrain.Power.FuelCell = VDatabase.FuelCell.FuelCell1Motor_default;
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end
