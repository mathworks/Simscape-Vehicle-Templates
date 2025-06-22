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
% Copyright 2019-2024 The MathWorks, Inc.

Vehicle = Vehicle_in;

%% Tire radius is needed in many places
%  Copy to fields within TireXX

% Get tire radius
[tireRadii, tireFields]  = sm_car_get_TireRadius(Vehicle);

% Get fieldnames for axle hardpoints
bodyFields    = fieldnames(Vehicle_in.Chassis.Body);
axleFieldInds = find(contains(bodyFields,'Axle'));
axleFields = sort(bodyFields(axleFieldInds)); % Order important for copying Body sAxle values

% Get fieldnames for Suspensions
chassisFields    = fieldnames(Vehicle_in.Chassis);
suspFieldInds = find(contains(chassisFields,'Susp'));
suspFields = sort(chassisFields(suspFieldInds)); % Order important for copying Body sAxle values

for axle_i = 1:length(tireRadii)
    % Assign to Tire-level field
    tireField  = tireFields{axle_i};
    tireRadius = tireRadii(axle_i);
    axleField  = axleFields{axle_i};
    suspField  = suspFields{axle_i};
    Vehicle.Chassis.(tireField).tire_radius.Value = tireRadius;
    %Vehicle.Chassis.(tireField).tire_radius.Value = tireRadius;
    
    %% Testrig 4Post needs axle and wheel center location to place posts
    %  Copy hardpoint data from Suspension subfield to Tire subfield
    veh_tire_class = Vehicle_in.Chassis.(tireField).class.Value;
    if(strcmp(veh_tire_class,'Testrig_Post'))
        % If tires configured to Testrig_Post, copy hardpoints into Tire structure
        % Hardpoint for axle location
        Vehicle.Chassis.(tireField).sAxle =                      Vehicle_in.Chassis.Body.(axleField);
        Vehicle.Chassis.(tireField).sAxle.Comments =             ['Copied from Body.' axleField ' for Testrig_4Post'];
        
        % Hardpoint for wheel center location.  Field depends on suspension type
        if(isfield(Vehicle_in.Chassis.(suspField),'Linkage'))
            Vehicle.Chassis.(tireField).sWheelCentre =           Vehicle_in.Chassis.(suspField).Linkage.Upright.sWheelCentre;
            Vehicle.Chassis.(tireField).sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
        elseif(isfield(Vehicle_in.Chassis.(suspField),'Simple'))
            Vehicle.Chassis.(tireField).sWheelCentre =           Vehicle_in.Chassis.(suspField).Simple.sWheelCentre;
            Vehicle.Chassis.(tireField).sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
        elseif(isfield(Vehicle_in.Chassis.(suspField),'LiveAxle'))
            Vehicle.Chassis.(tireField).sWheelCentre =           Vehicle_in.Chassis.(suspField).LiveAxle.sWheelCentre;
            Vehicle.Chassis.(tireField).sWheelCentre.Comments =  'Copied from LiveAxle.sWheelCentre for Testrig_4Post';
        elseif(isfield(Vehicle_in.Chassis.(suspField),'TwistBeam'))
            Vehicle.Chassis.(tireField).sWheelCentre =           Vehicle_in.Chassis.(suspField).TwistBeam.TrailingArm.sWheelCentre;
            Vehicle.Chassis.(tireField).sWheelCentre.Comments =  'Copied from TrailingArm.sWheelCentre for Testrig_4Post';
        end
        
    elseif(strcmp(Vehicle.Chassis.(tireField).class.Value,'Tire2x'))
        % If more than one wheel on corner, get tire type from subfield
        veh_tire_class = Vehicle_in.Chassis.(tireField).TireInner.class.Value;
        % Get offset along axle between wheel centers
        xoffset    = Vehicle.Chassis.(tireField).xOffset.Value;
        
        % If tires configured to Testrig_Post, copy hardpoints into Tire structure
        % Hardpoint for axle location
        if(strcmp(veh_tire_class,'Testrig_Post'))
            Vehicle.Chassis.(tireField).TireInner.sAxle =            Vehicle_in.Chassis.Body.(axleField);
            Vehicle.Chassis.(tireField).TireInner.sAxle.Comments =   ['Copied from Body ' axleField ' for Testrig_4Post'];
            Vehicle.Chassis.(tireField).TireOuter.sAxle =            Vehicle_in.Chassis.Body.(axleField);
            Vehicle.Chassis.(tireField).TireOuter.sAxle.Comments =   ['Copied from Body ' axleField ' for Testrig_4Post'];
        end
        
        % Hardpoint for wheel center location.  Field depends on suspension type
        if(isfield(Vehicle_in.Chassis.(suspField),'Linkage'))
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre =           Vehicle_in.Chassis.(suspField).Linkage.Upright.sWheelCentre;
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Value = Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre =           Vehicle_in.Chassis.(suspField).Linkage.Upright.sWheelCentre;
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Value = Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Comments =  'Copied from Upright.sWheelCentre for Testrig_4Post';
        elseif(isfield(Vehicle_in.Chassis.(suspField),'Simple'))
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre =           Vehicle_in.Chassis.(suspField).Simple.sWheelCentre;
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Value = Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Value+[0 -xoffset/2 0];
            Vehicle.Chassis.(tireField).TireInner.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre =           Vehicle_in.Chassis.(suspField).Simple.sWheelCentre;
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Value = Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Value+[0 +xoffset/2 0];
            Vehicle.Chassis.(tireField).TireOuter.sWheelCentre.Comments =  'Copied from Simple.sWheelCentre for Testrig_4Post';
        end
    end
end

