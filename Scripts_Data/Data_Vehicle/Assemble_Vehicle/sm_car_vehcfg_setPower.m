function Vehicle = sm_car_vehcfg_setPower(Vehicle,power_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2022 The MathWorks, Inc.
VDatabase = evalin('base','VDatabase');

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
Vehicle.Powertrain.Power = VDatabase.Power.(power_opt);

% If subfield Cooling was previously defined, reload settings
if(isfield(Vehicle.Powertrain.Power,'Cooling') && ...
        ~strcmp(temp_cooling,'no data'))
    Vehicle.Powertrain.Power.Cooling = temp_cooling;
end

% Special case if configuration contains fuel cell (extra layers)
if(contains(power_opt,'FuelCell'))
    Vehicle.Powertrain.Power.Cooling = VDatabase.Cooling.(power_opt);
    Vehicle.Powertrain.Power.FuelCell = VDatabase.FuelCell.(power_opt);
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end
