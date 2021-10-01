function Vehicle = sm_car_vehcfg_setTire(Vehicle,tire_opt,tireFieldName)
% Copy data from VDatabase to Vehicle data structure
% 
% tire_opt contains options encoded in a string
%      <tire model>_<1x/2x>_<geometry>_<tire data>
%
%   <tire_model>    "MFEval" or "Delft"
%   <1x/2x>         "1x" One wheel 
%                   "2x" two wheels on a corner
%   <geometry>      "Generic" for parameterized geometry
%                   "CAD" for CAD geometry
%   <tire_data>     string corresponding to .tir file
%
% tireFieldName     Field name in Vehicle data structure where tire data is stored
%
% Copyright 2019-2021 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Determine if multiple tires are on axle
% and remove number of tires option from tire_opt
if(contains(tire_opt,'_2x'))
    tire_opt = strrep(tire_opt,'_2x','');
    tire_config = '2x';
else
    % Do not need to remove 1x from tire_opt
    tire_config = '1x';
end

% Determine which type of geometry is requested
% and remove geometry flag from tire_opt
if(contains(tire_opt,'_Generic_'))
    tire_opt = strrep(tire_opt,'Generic_','');
    tire_body = 'Parameterized';
    tire_2xinst   = replace(tire_opt,{'MFMbody_','MFEval_','MFSwift_','Delft_'},'');
else
    tire_opt = strrep(tire_opt,'_CAD','');
    % Create tire_body variable with selected CAD option
    tire_body   = replace(tire_opt,{'MFMbody','MFEval','MFSwift','Delft'},'CAD');
    tire_2xinst = replace(tire_body,'CAD_','');
end

% Logic to handle single tire/multiple tires
% Place parameters at correct level and assign to one/multiple tires
if(strcmp(tire_config,'1x'))
    % Assign parameters to single tire
    Vehicle.Chassis.(tireFieldName) = VDatabase.Tire.(tire_opt);

    % If requested geometry option not in database, use parameterized geometry
    if(isfield(VDatabase.TireBody,tire_body))
        Vehicle.Chassis.(tireFieldName).TireBody = VDatabase.TireBody.(tire_body);
    else
        Vehicle.Chassis.(tireFieldName).TireBody = VDatabase.TireBody.Parameterized;
    end
else
    % Two tires - 
    % **Future Enhancement** 
    % Additional logic will be needed for >2 tires
    % Instance is also currently hardcoded 
    if(isfield(VDatabase.Tire,['Tire2x_' tire_2xinst]))
        Vehicle.Chassis.(tireFieldName) = VDatabase.Tire.(['Tire2x_' tire_2xinst]);
        Vehicle.Chassis.(tireFieldName).TireInner = VDatabase.Tire.(tire_opt);
        Vehicle.Chassis.(tireFieldName).TireOuter = VDatabase.Tire.(tire_opt);
    else
        error(['No tire field ''Tire2x_' tire_2xinst ' in VDatabase.Tire']);
    end

    if(isfield(VDatabase.TireBody,[tire_body '_2x']))
        % If geometry with two tires in database, assign that geometry
        % to outer wheel, no geometry to inner wheel
        Vehicle.Chassis.(tireFieldName).TireInner.TireBody = VDatabase.TireBody.None;
        Vehicle.Chassis.(tireFieldName).TireOuter.TireBody = VDatabase.TireBody.([tire_body '_2x']);
    elseif(isfield(VDatabase.TireBody,tire_body) && ~strcmp(tire_body,'Parameterized'))
        % Else if CAD geometry for individual tires is in database, use that
        Vehicle.Chassis.(tireFieldName).TireInner.TireBody = VDatabase.TireBody.(tire_body);
        Vehicle.Chassis.(tireFieldName).TireOuter.TireBody = VDatabase.TireBody.(tire_body);
    else
        % Else if no CAD data available, use parameterized geometry
        Vehicle.Chassis.(tireFieldName).TireInner.TireBody = VDatabase.TireBody.Parameterized;
        Vehicle.Chassis.(tireFieldName).TireOuter.TireBody = VDatabase.TireBody.Parameterized;
    end
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end