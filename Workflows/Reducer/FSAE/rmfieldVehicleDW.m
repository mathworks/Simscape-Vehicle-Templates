function [Vehicle_out] = rmfieldVehicleDW(Vehicle)
% Remove sTop, sBottom from Spring
Vehicle_out = Vehicle;
tempSpAx1  = rmfield(Vehicle_out.Chassis.Spring.Axle1,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle1 = tempSpAx1;
tempSpAx2  = rmfield(Vehicle_out.Chassis.Spring.Axle2,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle2 = tempSpAx2;

% Remove sTop, sBottom from Damper
tempDaAx1  = rmfield(Vehicle_out.Chassis.Damper.Axle1.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle1.Damping = tempDaAx1;
tempDaAx2  = rmfield(Vehicle_out.Chassis.Damper.Axle2.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle2.Damping = tempDaAx2;

% Remove xMax, xMin from Endstop
tempEnAx1  = rmfield(Vehicle_out.Chassis.Damper.Axle1.Endstop,{'xMin','xMax'});
Vehicle_out.Chassis.Damper.Axle1.Endstop= tempEnAx1;
tempEnAx2  = rmfield(Vehicle_out.Chassis.Damper.Axle2.Endstop,{'xMin','xMax'});
Vehicle_out.Chassis.Damper.Axle2.Endstop = tempEnAx2;

% Remove sOutboard from Steering
tempSuspA1Rack = rmfield(Vehicle_out.Chassis.SuspA1.Steer.Rack,{'sOutboard'});
Vehicle_out.Chassis.SuspA1.Steer.Rack = tempSuspA1Rack;


