function Vehicle = sm_car_vehcfg_setBrakes(Vehicle,brk_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2021 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Copy data from database into Vehicle data structure
% If "Pressure" selected, use Pedal parameters but set class to "Pressure"
usePressure = 0;
if(contains(brk_opt,'_Pressure'))
    % If "Pressure" selected, use Pedal parameters
    brk_opt = strrep(brk_opt,'_Pressure','_Pedal');
    usePressure = 1;
end
Vehicle.Brakes = VDatabase.Brakes.(brk_opt);
if(usePressure)
    % If "Pressure" selected, set "class.Value" to 'Pressure'
    class_str = strrep(Vehicle.Brakes.class.Value,'Pedal','Pressure');
    Vehicle.Brakes.class.Value = class_str;
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end