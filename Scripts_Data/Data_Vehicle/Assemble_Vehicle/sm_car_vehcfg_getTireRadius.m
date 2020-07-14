function [tire_radiusF, tire_radiusR] = sm_car_vehcfg_getTireRadius(Vehicle)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

%% Determine if .tir file used to define radius
%  Front
if(isfield(Vehicle.Chassis.TireF,'tirFile'))
    % Single tire defined by .tir file
    tir_fileF = Vehicle.Chassis.TireF.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireF,'TireInner'))
    if(isfield(Vehicle.Chassis.TireF.TireInner,'tirFile'))
        % 2x tire defined by .tir file, take inner tire definition
        tir_fileF = Vehicle.Chassis.TireF.TireInner.tirFile.Value;
    elseif(isfield(Vehicle.Chassis.TireF.TireInner,'tire_radius'))
        % Testrig tire used, get radius value directly from structure
        tir_fileF = 'check_tire_radius_Inner';
    else
        error('tirFile field not found in Vehicle data structure');
    end
elseif(isfield(Vehicle.Chassis.TireF,'tire_radius'))
    % .tir file not used
    tir_fileF = 'check_tire_radius';
else
    % Unknown method used to define tire
    error('tirFile field not found in Vehicle data structure');
end

%  Rear
if(isfield(Vehicle.Chassis.TireR,'tirFile'))
    tir_fileR = Vehicle.Chassis.TireR.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireR,'TireInner'))
    if(isfield(Vehicle.Chassis.TireR.TireInner,'tirFile'))
        % 2x tire defined by .tir file, take inner tire definition
        tir_fileR = Vehicle.Chassis.TireR.TireInner.tirFile.Value;
    elseif(isfield(Vehicle.Chassis.TireR.TireInner,'tire_radius'))
        % Testrig tire used, get radius value directly from structure
        tir_fileR = 'check_tire_radius_Inner';
    else
        error('tirFile field not found in Vehicle data structure');
    end
elseif(isfield(Vehicle.Chassis.TireR,'tire_radius'))
    tir_fileR = 'check_tire_radius';
else
    error('tirFile field not found in Vehicle data structure');
end

%% Get tire radius
%  Front
if(~startsWith(tir_fileF,'check_tire_radius'))
    tir_fileF = strrep(tir_fileF,'which(''','');
    tir_fileF = strrep(tir_fileF,''')','');
    temptirparams = mfeval.readTIR(which(tir_fileF));
    tire_radiusF = temptirparams.UNLOADED_RADIUS;
else
    if(strcmp(tir_fileF,'check_tire_radius'))
        % Single tire, Testrig test
        tire_radiusF = Vehicle.Chassis.TireF.tire_radius.Value;
    elseif(strcmp(tir_fileF,'check_tire_radius_Inner'))
        % 2x tire, Testrig test
        tire_radiusF = Vehicle.Chassis.TireF.TireInner.tire_radius.Value;
    else
        error('Tire radius not found in Vehicle data structure');
    end
end

%  Rear
if(~startsWith(tir_fileR,'check_tire_radius'))
    tir_fileR = strrep(tir_fileR,'which(''','');
    tir_fileR = strrep(tir_fileR,''')','');
    temptirparams = mfeval.readTIR(which(tir_fileR));
    tire_radiusR = temptirparams.UNLOADED_RADIUS;
else
    if(strcmp(tir_fileR,'check_tire_radius'))
        % Single tire, Testrig test
        tire_radiusR = Vehicle.Chassis.TireR.tire_radius.Value;
    elseif(strcmp(tir_fileR,'check_tire_radius_Inner'))
        % 2x tire, Testrig test
        tire_radiusR = Vehicle.Chassis.TireR.TireInner.tire_radius.Value;
    else
        error('Tire radius not found in Vehicle data structure');
    end
end
