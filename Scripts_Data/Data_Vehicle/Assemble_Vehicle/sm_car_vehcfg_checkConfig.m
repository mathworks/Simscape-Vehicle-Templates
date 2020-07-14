function Vehicle = sm_car_vehcfg_checkConfig(Vehicle_in)
%sm_car_vehcfg_checkConfig   Check and adjust Vehicle data structure
%
% This function is called in the InitFcn callback of sm_car.  It makes
% adjustments to the Vehicle data structure that can only be done when the
% structure is complete.  
%
% Examples include 
% 1. Ensuring values that appear in two different parts of the structure
%    are in fact identical (wheel center location).
% 2. Putting tire radius in an explicit field (instead of having it buried
%    in the .tir file).
%
% Copyright 2019-2020 The MathWorks, Inc.

Vehicle = Vehicle_in;

%% Tire radius is needed in many places
%  Copy to TireF, TireR fields

% Get tire radius
[trF, trR] = sm_car_vehcfg_getTireRadius(Vehicle);

% Assign to Tire-level field
Vehicle.Chassis.TireF.tire_radius.Value = trF;
Vehicle.Chassis.TireR.tire_radius.Value = trR;

%% Testrig 4Post needs axle and wheel center location to place posts
%  Copy hardpoint data from Suspension subfield to Tire subfield
% Front
veh_tire_f = Vehicle_in.Chassis.TireF.class.Value;
if(strcmp(veh_tire_f,'Testrig_Post'))
    % If tires configured to Testrig_Post, copy hardpoints into Tire structure
    % Hardpoint for axle location
    Vehicle.Chassis.TireF.sAxle =                      Vehicle_in.Chassis.Body.sAxleF;
    Vehicle.Chassis.TireF.sAxle.Comments =             'Copied from Body.sAxleF for Testrig_4Post';
    
    % Hardpoint for wheel center location.  Field depends on suspension type
    if(isfield(Vehicle_in.Chassis.SuspF,'Linkage'))
        Vehicle.Chassis.TireF.sWheelCentre =           Vehicle_in.Chassis.SuspF.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireF.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
    elseif(isfield(Vehicle_in.Chassis.SuspF,'Simple'))
        Vehicle.Chassis.TireF.sWheelCentre =           Vehicle_in.Chassis.SuspF.Simple.sWheelCentre;
        Vehicle.Chassis.TireF.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
    end
    
elseif(strcmp(Vehicle.Chassis.TireF.class.Value,'Tire2x'))
    % If more than one wheel on corner, get tire type from subfield
    veh_tire_f = Vehicle_in.Chassis.TireF.TireInner.class.Value;
    % Get offset along axle between wheel centers
    xoffset    = Vehicle.Chassis.TireF.xOffset.Value;
    
    % If tires configured to Testrig_Post, copy hardpoints into Tire structure
    % Hardpoint for axle location
    if(strcmp(veh_tire_f,'Testrig_Post'))
        Vehicle.Chassis.TireF.TireInner.sAxle =            Vehicle_in.Chassis.Body.sAxleF;
        Vehicle.Chassis.TireF.TireInner.sAxle.Comments =   'Copied from Body.sAxleF for Testrig_4Post';
        Vehicle.Chassis.TireF.TireOuter.sAxle =            Vehicle_in.Chassis.Body.sAxleF;
        Vehicle.Chassis.TireF.TireOuter.sAxle.Comments =   'Copied from Body.sAxleF for Testrig_4Post';
    end
    
    % Hardpoint for wheel center location.  Field depends on suspension type
    if(isfield(Vehicle_in.Chassis.SuspF,'Linkage'))
        Vehicle.Chassis.TireF.TireInner.sWheelCentre =           Vehicle_in.Chassis.SuspF.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireF.TireInner.sWheelCentre.Value = Vehicle.Chassis.TireF.TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
        Vehicle.Chassis.TireF.TireInner.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre =           Vehicle_in.Chassis.SuspF.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Value = Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
    elseif(isfield(Vehicle_in.Chassis.SuspF,'Simple'))
        Vehicle.Chassis.TireF.TireInner.sWheelCentre =           Vehicle_in.Chassis.SuspF.Simple.sWheelCentre;
        Vehicle.Chassis.TireF.TireInner.sWheelCentre.Value = Vehicle.Chassis.TireF.TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
        Vehicle.Chassis.TireF.TireInner.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre =           Vehicle_in.Chassis.SuspF.Simple.sWheelCentre;
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Value = Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
        Vehicle.Chassis.TireF.TireOuter.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
    end
    
end

% Copy hardpoint data from Suspension subfield to Tire subfield
% Rear
veh_tire_r = Vehicle_in.Chassis.TireR.class.Value;
if(strcmp(veh_tire_r,'Testrig_Post'))
    % If tires configured to Testrig_Post, copy hardpoints into Tire structure
    % Hardpoint for axle location
    Vehicle.Chassis.TireR.sAxle =                      Vehicle_in.Chassis.Body.sAxleR;
    Vehicle.Chassis.TireR.sAxle.Comments =             'Copied from Body.sAxleR for Testrig_4Post';
    
    % Hardpoint for wheel center location.  Field depends on suspension type
    if(isfield(Vehicle_in.Chassis.SuspR,'Linkage'))
        Vehicle.Chassis.TireR.sWheelCentre =           Vehicle_in.Chassis.SuspR.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireR.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
    elseif(isfield(Vehicle_in.Chassis.SuspR,'Simple'))
        Vehicle.Chassis.TireR.sWheelCentre =           Vehicle_in.Chassis.SuspR.Simple.sWheelCentre;
        Vehicle.Chassis.TireR.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
    end
elseif(strcmp(Vehicle.Chassis.TireR.class.Value,'Tire2x'))
    % If more than one wheel on corner, get tire type from subfield
    veh_tire_r = Vehicle_in.Chassis.TireR.TireInner.class.Value;
    % Get offset along axle between wheel centers
    xoffset    = Vehicle.Chassis.TireR.xOffset.Value;
    
    % If tires configured to Testrig_Post, copy hardpoints into Tire structure
    % Hardpoint for axle location   
    if(strcmp(veh_tire_r,'Testrig_Post'))
        Vehicle.Chassis.TireR.TireInner.sAxle =            Vehicle_in.Chassis.Body.sAxleR;
        Vehicle.Chassis.TireR.TireInner.sAxle.Comments =   'Copied from Body.sAxleR for Testrig_4Post';
        Vehicle.Chassis.TireR.TireOuter.sAxle =            Vehicle_in.Chassis.Body.sAxleR;
        Vehicle.Chassis.TireR.TireOuter.sAxle.Comments =   'Copied from Body.sAxleR for Testrig_4Post';
    end
    
    % Hardpoint for wheel center location.  Field depends on suspension type
    if(isfield(Vehicle_in.Chassis.SuspR,'Linkage'))
        Vehicle.Chassis.TireR.TireInner.sWheelCentre =           Vehicle_in.Chassis.SuspR.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireR.TireInner.sWheelCentre.Value = Vehicle.Chassis.TireR.TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
        Vehicle.Chassis.TireR.TireInner.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre =           Vehicle_in.Chassis.SuspR.Linkage.Upright.sWheelCentre;
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Value = Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
    elseif(isfield(Vehicle_in.Chassis.SuspF,'Simple'))
        Vehicle.Chassis.TireR.TireInner.sWheelCentre =           Vehicle_in.Chassis.SuspR.Simple.sWheelCentre;
        Vehicle.Chassis.TireR.TireInner.sWheelCentre.Value = Vehicle.Chassis.TireR.TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
        Vehicle.Chassis.TireR.TireInner.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre =           Vehicle_in.Chassis.SuspR.Simple.sWheelCentre;
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Value = Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
        Vehicle.Chassis.TireR.TireOuter.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
    end
    
end

