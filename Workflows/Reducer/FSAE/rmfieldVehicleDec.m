function [Vehicle_out] = rmfieldVehicleDec(Vehicle)

% Remove sTop, sBottom from Spring Heave
Vehicle_out = Vehicle;
tempSpHeAx1  = rmfield(Vehicle_out.Chassis.Spring.Axle1.Heave,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle1.Heave = tempSpHeAx1;
tempSpHeAx2  = rmfield(Vehicle_out.Chassis.Spring.Axle2.Heave,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle2.Heave = tempSpHeAx2;

% Remove sTop, sBottom from Spring Roll
tempSpRoAx1  = rmfield(Vehicle_out.Chassis.Spring.Axle1.Roll,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle1.Roll = tempSpRoAx1;
tempSpRoAx2  = rmfield(Vehicle_out.Chassis.Spring.Axle2.Roll,{'sTop','sBottom'});
Vehicle_out.Chassis.Spring.Axle2.Roll = tempSpRoAx2;

% Remove sTop, sBottom from Damper Heave
tempDaHeAx1  = rmfield(Vehicle_out.Chassis.Damper.Axle1.Heave.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle1.Heave.Damping = tempDaHeAx1;
tempDaHeAx2  = rmfield(Vehicle_out.Chassis.Damper.Axle2.Heave.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle2.Heave.Damping = tempDaHeAx2;

% Remove sTop, sBottom from Damper Roll
tempDaRoAx1  = rmfield(Vehicle_out.Chassis.Damper.Axle1.Roll.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle1.Roll.Damping = tempDaRoAx1;
tempDaRoAx2  = rmfield(Vehicle_out.Chassis.Damper.Axle2.Roll.Damping,{'sTop','sBottom'});
Vehicle_out.Chassis.Damper.Axle2.Roll.Damping = tempDaRoAx2;

% Remove xMax, xMin from Endstop Heave
tempEnAx1  = rmfield(Vehicle_out.Chassis.Damper.Axle1.Heave.Endstop,{'xMin','xMax'});
Vehicle_out.Chassis.Damper.Axle1.Heave.Endstop = tempEnAx1;
tempEnAx2  = rmfield(Vehicle_out.Chassis.Damper.Axle2.Heave.Endstop,{'xMin','xMax'});
Vehicle_out.Chassis.Damper.Axle2.Heave.Endstop = tempEnAx2;

% Remove sOutboard from Steering
tempSuspA1Rack = rmfield(Vehicle_out.Chassis.SuspA1.Steer.Rack,{'sOutboard'});
Vehicle_out.Chassis.SuspA1.Steer.Rack = tempSuspA1Rack;

