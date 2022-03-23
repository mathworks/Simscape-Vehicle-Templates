function Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,cooling_opt)
% Set Power.Cooling fields of Vehicle data structure
%
% Copyright 2019-2022 The MathWorks, Inc.


if(isfield(Vehicle.Powertrain.Power,'Cooling'))
    % Only set field if field is already present
    if(contains(Vehicle.Powertrain.Power.class.Value,'Electric'))
        % Only set field for Electric variants
        Vehicle.Powertrain.Power.Cooling.class.Value = cooling_opt;
    end
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end
