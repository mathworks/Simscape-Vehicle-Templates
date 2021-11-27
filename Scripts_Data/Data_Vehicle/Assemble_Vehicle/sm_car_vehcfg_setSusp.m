function Vehicle = sm_car_vehcfg_setSusp(Vehicle,susp_opt,suspFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% susp_opt contains name of field from VDatabase.
% The name is usually of this form
%      <suspension type> <vehicle platform> <front/rear>
%
%   <suspension type>   Type of suspension (double wishbone, etc.)
%   <platform>          Abbreviation for Sedan Hamba "SH", etc.
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Check for suspension composed of distance constraints
constraintSusp = false;
if(strcmpi(susp_opt,'5CS2LAF_SHL_f'))
    constraintSusp = true;
    susp_opt = 'FiveLinkShockFront_Sedan_HambaLG_f';
elseif(strcmpi(susp_opt,'5CS2LAF_SHL_r'))
    constraintSusp = true;
    susp_opt = 'FiveLinkShockFront_Sedan_HambaLG_r';
end

% Map database data to correct level in Vehicle data structure
if(isfield(VDatabase.Linkage,susp_opt))
    
    % If (not filling an empty Vehicle)
    if(isfield(Vehicle.Chassis,suspFieldName))
    	% 'Linkage' suspension requires removing 'Simple' field
        if(isfield(Vehicle.Chassis.(suspFieldName),'Simple'))
            temp_susp = rmfield(Vehicle.Chassis.(suspFieldName),'Simple');
            Vehicle.Chassis.(suspFieldName) = temp_susp;
        end
    end
    
    % Copy Linkage instance data to Vehicle data structure
    Vehicle.Chassis.(suspFieldName).Linkage = VDatabase.Linkage.(susp_opt);
    if(contains(susp_opt,'Decoupled'))
        Vehicle.Chassis.(suspFieldName).class.Value = 'Decoupled';
    else
        Vehicle.Chassis.(suspFieldName).class.Value = 'Linkage';
    end
    
    if(~isfield(Vehicle.Chassis.(suspFieldName),'AntiRollBar'))
        Vehicle.Chassis.(suspFieldName).AntiRollBar = VDatabase.AntiRollBar.None;
        %disp('Note: AntiRollBar was not present; configuration set to ''None''.');
    end

elseif(isfield(VDatabase.Susp,susp_opt))
    
    % If (not filling an empty Vehicle)
    if(isfield(Vehicle.Chassis,suspFieldName))
        % 'Simple' suspension requires removing 'Linkage' field
        if(isfield(Vehicle.Chassis.(suspFieldName),'Linkage'))
            temp_susp = rmfield(Vehicle.Chassis.(suspFieldName),'Linkage');
            Vehicle.Chassis.(suspFieldName) = temp_susp;
        end
        
        % Save Steer Instance if suspension has it already
        % Need to save it if suspension type changes (Linkage -> other)
        % Not all suspensions have steering
        if(isfield(Vehicle.Chassis.(suspFieldName),'Steer'))
            steer_instance = Vehicle.Chassis.(suspFieldName).Steer.Instance;
        end
    end
    
    % Copy Linkage instance data to Vehicle data structure
    Vehicle.Chassis.(suspFieldName) = VDatabase.Susp.(susp_opt);
    %Vehicle.Chassis.(suspFieldName).class.Value = 'Simple';
    
    if(exist('steer_instance','var'))
        Vehicle.Chassis.(suspFieldName).Steer = VDatabase.Steer.(steer_instance);
    end
    
else
    warning(['Suspension data ''' susp_opt ''' not found in database.']); 
end

% Alter class only to select variant with constraints instead of joints
if(constraintSusp)
    Vehicle.Chassis.(suspFieldName).Linkage.class.Value = 'FiveLinkConstraintShockFront';
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end