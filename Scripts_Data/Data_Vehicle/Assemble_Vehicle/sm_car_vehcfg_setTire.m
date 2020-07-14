function Vehicle = sm_car_vehcfg_setTire(Vehicle,tire_opt,frontRear)
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
% Copyright 2019-2020 The MathWorks, Inc.

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
    tire_opt = strrep(tire_opt,'_Generic','');
    tire_body = 'Parameterized';
else
    tire_opt = strrep(tire_opt,'_CAD','');
    % Create tire_body variable with selected CAD option
    tire_body = strrep(tire_opt,'MFEval','CAD');
    tire_body = strrep(tire_body,'Delft','CAD');
end

% Switch to select instance for tire model and tire data
if(strcmpi(frontRear,'front'))
    switch tire_opt
        case 'MFEval_235_50R24',   instance = 'MFEval_235_50R24';
        case 'MFEval_213_40R21',   instance = 'MFEval_213_40R21';
        case 'MFEval_270_70R22',   instance = 'MFEval_270_70R22';
        case 'MFEval_145_70R13',   instance = 'MFEval_145_70R13';
        case 'Delft_235_50R24',    instance = 'Delft_235_50R24';
        case 'Delft_213_40R21',    instance = 'Delft_213_40R21';
        case 'Delft_270_70R22',    instance = 'Delft_270_70R22';
        case 'Delft_145_70R13',    instance = 'Delft_145_70R13';
        case 'MFSwift_235_50R24',  instance = 'MFSwift_235_50R24';
        case 'MFSwift_213_40R21',  instance = 'MFSwift_213_40R21';
        case 'MFSwift_270_70R22',  instance = 'MFSwift_270_70R22';
        case 'MFSwift_145_70R13',  instance = 'MFSwift_145_70R13';
    end
    tirefield = 'TireF';
elseif(strcmpi(frontRear,'rear'))
    switch tire_opt
        case 'MFEval_235_50R24',   instance = 'MFEval_235_50R24';
        case 'MFEval_213_40R21',   instance = 'MFEval_213_40R21';
        case 'MFEval_270_70R22',   instance = 'MFEval_270_70R22';
        case 'MFEval_145_70R13',   instance = 'MFEval_145_70R13';
        case 'Delft_235_50R24',    instance = 'Delft_235_50R24';
        case 'Delft_213_40R21',    instance = 'Delft_213_40R21';
        case 'Delft_270_70R22',    instance = 'Delft_270_70R22';
        case 'Delft_145_70R13',    instance = 'Delft_145_70R13';
        case 'MFSwift_235_50R24',  instance = 'MFSwift_235_50R24';
        case 'MFSwift_213_40R21',  instance = 'MFSwift_213_40R21';
        case 'MFSwift_270_70R22',  instance = 'MFSwift_270_70R22';
        case 'MFSwift_145_70R13',  instance = 'MFSwift_145_70R13';
    end
    tirefield = 'TireR';
end

%disp(['Instance: ' instance '  | Body: ' tire_body])

% Logic to handle single tire/multiple tires
% Place parameters at correct level and assign to one/multiple tires
if(strcmp(tire_config,'1x'))
    % Assign parameters to single tire
    Vehicle.Chassis.(tirefield) = VDatabase.Tire.(instance);

    % If requested geometry option not in database, use parameterized geometry
    if(isfield(VDatabase.TireBody,tire_body))
        Vehicle.Chassis.(tirefield).TireBody = VDatabase.TireBody.(tire_body);
    else
        Vehicle.Chassis.(tirefield).TireBody = VDatabase.TireBody.Parameterized;
    end
else
    % Two tires - 
    % **Future Enhancement** 
    % Additional logic will be needed for >2 tires
    % Instance is also currently hardcoded 
    Vehicle.Chassis.(tirefield) = VDatabase.Tire.Tire2x_Bus_Makhulu;
    Vehicle.Chassis.(tirefield).TireInner = VDatabase.Tire.(instance);
    Vehicle.Chassis.(tirefield).TireOuter = VDatabase.Tire.(instance);
    
    if(isfield(VDatabase.TireBody,[tire_body '_2x']))
        % If geometry with two tires in database, assign that geometry
        % to outer wheel, no geometry to inner wheel
        Vehicle.Chassis.(tirefield).TireInner.TireBody = VDatabase.TireBody.None;
        Vehicle.Chassis.(tirefield).TireOuter.TireBody = VDatabase.TireBody.([tire_body '_2x']);
    elseif(isfield(VDatabase.TireBody,tire_body) && ~strcmp(tire_body,'Parameterized'))
        % Else if CAD geometry for individual tires is in database, use that
        Vehicle.Chassis.(tirefield).TireInner.TireBody = VDatabase.TireBody.(tire_body);
        Vehicle.Chassis.(tirefield).TireOuter.TireBody = VDatabase.TireBody.(tire_body);
    else
        % Else if no CAD data available, use parameterized geometry
        Vehicle.Chassis.(tirefield).TireInner.TireBody = VDatabase.TireBody.Parameterized;
        Vehicle.Chassis.(tirefield).TireOuter.TireBody = VDatabase.TireBody.Parameterized;
    end
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end