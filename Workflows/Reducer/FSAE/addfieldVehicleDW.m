function [Vehicle_out] = addfieldVehicleDW(Vehicle)

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
    Vehicle_out.Chassis.Spring.(axleList{i,1}).sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.sTop;
    Vehicle_out.Chassis.Spring.(axleList{i,1}).sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.sBottom;

    % Spring Roll sTop sBottom - copy values from Linkage to Spring
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Damping.sTop = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.sTop;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Damping.sBottom = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Shock.sBottom;

    % Endstop Heave xMin xMax - copy values from Linkage to Damper
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Endstop.xMin = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.xMin;
    Vehicle_out.Chassis.Damper.(axleList{i,1}).Endstop.xMax = ...
        Vehicle.Chassis.(axleList{i,2}).Linkage.Endstop.xMax;
end

Vehicle_out.Chassis.SuspA1.Steer.Rack.sOutboard = ...
    Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard;