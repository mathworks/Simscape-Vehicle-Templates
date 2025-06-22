function [tireK, tireW, tireFields] = sm_car_get_tire_params(Vehicle)
% sm_car_get_tire_params  Extract key tire parameters 
%     [tireK] = sm_car_get_tire_params(Vehicle);
%     This function returns key parameters for the tire. Different vehicle
%     types store the relevant parameters in different fields. 
%
%     Vehicle   MATLAB structure with vehicle parameters
%
%     Outputs include
%        tireK           Tire Stiffness (N/m)
%

% Find fieldnames for tires
chassis_fnames = fieldnames(Vehicle.Chassis);
fname_inds_tire = startsWith(chassis_fnames,'Tire');
tireFields = chassis_fnames(fname_inds_tire);
tireFields = sort(tireFields); % Order important for copying Body sAxle values


% Loop over tire field names (by axle)
for axle_i = 1:length(tireFields)
    tireField = tireFields{axle_i};
    
    %% Determine if .tir file used to define radius
    if(isfield(Vehicle.Chassis.(tireField),'tirFile'))
        % Single tire defined by .tir file
        tir_file{axle_i} = Vehicle.Chassis.(tireField).tirFile.Value;
    elseif(isfield(Vehicle.Chassis.(tireField),'TireInner'))
        if(isfield(Vehicle.Chassis.(tireField).TireInner,'tirFile'))
            % 2x tire defined by .tir file, take inner tire definition
            tir_file{axle_i} = Vehicle.Chassis.(tireField).TireInner.tirFile.Value;
        elseif(isfield(Vehicle.Chassis.(tireField).TireInner,'tire_radius'))
            % Testrig tire used, get radius value directly from structure
            tir_file{axle_i} = 'check_tire_radius_Inner';
        else
            error('tirFile field not found in Vehicle data structure');
        end
    elseif(isfield(Vehicle.Chassis.(tireField),'tire_radius'))
        % .tir file not used
        tir_file{axle_i} = 'check_tire_radius';
    else
        % Unknown method used to define tire
        error('tirFile field not found in Vehicle data structure');
    end
    
    % Get tire radius
    if(~startsWith(tir_file{axle_i},'check_tire_radius'))
        tir_file{axle_i} = strrep(tir_file{axle_i},'which(''','');
        tir_file{axle_i} = strrep(tir_file{axle_i},''')','');
        temptirparams = simscape.multibody.tirread(which(tir_file{axle_i}));
        %tire_radius(axle_i) = temptirparams.UNLOADED_RADIUS;
        tireK(axle_i) = temptirparams.VERTICAL.VERTICAL_STIFFNESS;
        tireW(axle_i) = temptirparams.DIMENSION.WIDTH;
    else
        if(strcmp(tir_file{axle_i},'check_tire_radius'))
            % Single tire, Testrig test
            %tire_radius(axle_i) = Vehicle.Chassis.(tireField).tire_radius.Value;
            tireK(axle_i) = Vehicle.Chassis.(tireField).K.Value;
            tireW(axle_i) = 0;
        elseif(strcmp(tir_file{axle_i},'check_tire_radius_Inner'))
            % 2x tire, Testrig test
            tire_radius(axle_i) = Vehicle.Chassis.(tireField).TireInner.K.Value;
            tireW(axle_i) = 0;
        else
            error('Tire stiffness not found in Vehicle data structure');
        end
    end
end


%{

% Get Tire File name
if(isfield(Vehicle.Chassis.TireA1,'tirFile'))
    tireFile = Vehicle.Chassis.TireA1.tirFile.Value;

    if(contains(tireFile,'which'))
        tireFile = evalin('base',tireFile);
    end

    tireParams    = simscape.multibody.tirread(tireFile);
    tireK = tireParams.VERTICAL.VERTICAL_STIFFNESS;
elseif(isfield(Vehicle.Chassis.TireA1,'K'))
    tireK = Vehicle.Chassis.TireA1.K.Value;
else
    error('Cannot find find tire stiffness in structure Vehicle.Chassis.TireA1');
end
%}