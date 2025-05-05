function Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,axle_opt,arm_opt,connFieldName)
% Copy data from VDatabase to Vehicle data structure
%   This function copies data concerning the subframe connection to the
%   Vehicle data structure.  This is typically used to enable or disable
%   compliance at the joints in the suspension
%
%   axle_opt     Which axle: A1, A2, A3
%   arm_opt      Name abbreviation for arm, associated with suspension type
%                         'UA'  Upper arm wishbone
%                         'UAF' Upper arm link, front
%                         'UAR' Upper arm link, rear
%                         'LA'  Lower arm wishbone
%                         'LAF' Lower arm link, front
%                         'LAR' Lower arm link, rear
% connFieldName contains name of field from VDatabase.
% The name is a label composed of
%      <bushing type> <chassis type front/rear> <suspension type> <arm type>
%
% Copyright 2019-2024 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Compose axle name
axle_name = ['Susp' axle_opt];

% Convert arm option to Vehicle structure field name where subframe
% connection parameters are stored.
switch arm_opt
    case 'UA',  conn_name = 'Upper_Arm_to_Subframe';
    case 'LA',  conn_name = 'Lower_Arm_to_Subframe';
    case 'UAF', conn_name = 'UpperArmF_to_Subframe';
    case 'LAF', conn_name = 'LowerArmF_to_Subframe';
    case 'UAR', conn_name = 'UpperArmR_to_Subframe';
    case 'LAR', conn_name = 'LowerArmR_to_Subframe';
    case 'ARB', conn_name = 'SubframeConnection';
    otherwise, error(['Arm option ' arm_opt ' unknown']);
end

% Map database data to correct level in Vehicle data structure

if(isfield(VDatabase.Subframe_Conn,connFieldName))    
    % If requested connection parameter set exists
    if(isfield(Vehicle.Chassis,axle_name))
        if(~strcmp(arm_opt,'ARB'))
            % If (vehicle has requested axle name)
            if(isfield(Vehicle.Chassis.(axle_name),'Linkage'))
            	% If (vehicle has suspension with linkage)
                Vehicle.Chassis.(axle_name).Linkage.(conn_name) = ...
                    VDatabase.Subframe_Conn.(connFieldName);
            else
                warning(['Vehicle does not have Linkage field in ' axle_name]);
            end
        else
            % If (vehicle has requested axle name)
            if(isfield(Vehicle.Chassis.(axle_name),'AntiRollBar'))
            	% If (vehicle has suspension with linkage)
                Vehicle.Chassis.(axle_name).AntiRollBar.(conn_name) = ...
                    VDatabase.Subframe_Conn.(connFieldName);
            else
                warning(['Vehicle does not have AntiRollBar field in ' axle_name]);
            end
        end

    else
        warning(['Vehicle does not have axle field ' axle_name ' within Chassis']);
    end
else
    warning(['VDatabase does not have subframe connection field ' connFieldName ]);
end    

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end