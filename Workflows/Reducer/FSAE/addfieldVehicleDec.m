function [Vehicle_out] = addfieldVehicleDec(Vehicle)

% Some fields within the Vehicle data structure must be identical.  This
% function copies values from one field to another.  This includes
% hardpoint definitions and other shock parameters that are used in both
% the 3D mechanical model and 1D mechanical model as well as a hardpoint
% used within the Linkage and Steering systems.

% Copy entire data structure to output
Vehicle_out = Vehicle;

% Loop over axles.  First column is where 1D parameters live, second column
% is where 3D parameters live
axleList = {...
    'Axle1','SuspA1';...
    'Axle2','SuspA2'};

for i = 1:size(axleList,1)

    % Spring Heave sTop sBottom - copy from Linkage to Spring
    %    Left -> Top, Right -> Bottom
    Vehicle_out.Chassis.Spring.(axleList{i,1}).Heave.sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Heave.sLeft;
    Vehicle_out.Chassis.Spring.(axleList{i,1}).Heave.sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Heave.sRight;

    % Spring Roll sTop sBottom - copy values from Linkage to Spring
    %    Left -> Top, Right -> Bottom
    Vehicle_out.Chassis.Spring.(axleList{i,1}).Roll.sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Roll.sLeft;
    Vehicle_out.Chassis.Spring.(axleList{i,1}).Roll.sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Roll.sRight;

    % Damper Heave sTop sBottom - copy values from Linkage to Damper
    %    Left -> Top, Right -> Bottom
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Heave.Damping.sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Heave.sLeft;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Heave.Damping.sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Heave.sRight;

    % Damper Roll sTop sBottom - copy values from Linkage to Damper
    %    Left -> Top, Right -> Bottom
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Roll.Damping.sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Roll.sLeft;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Roll.Damping.sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.Roll.sRight;

    % Endstop Heave xMin xMax - copy values from Linkage to Damper
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Heave.Endstop.xMin = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.Heave.xMin;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Heave.Endstop.xMax = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.Heave.xMax;

    % Endstop Roll xMin xMax - copy values from Linkage to Damper 
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Roll.Endstop.xMin = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.Roll.xMin;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Roll.Endstop.xMax = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.Roll.xMax;
end

% For front axle only, copy steering hardpoint from Linkage to Steer
Vehicle_out.Chassis.SuspA1.Steer.Rack.sOutboard = ...
    Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard;
