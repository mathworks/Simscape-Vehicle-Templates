function config = sm_car_vehcfg_getConfig(Vehicle)
% Get list of key selected variants

config.Aero         = Vehicle.Chassis.Aero.class.Value;
config.Body         = Vehicle.Chassis.Body.class.Value;
config.BodyGeometry = Vehicle.Chassis.Body.BodyGeometry.class.Value;

if(~strcmp(Vehicle.Chassis.SuspF.class.Value,'Linkage'))
    config.SuspF  = Vehicle.Chassis.SuspF.class.Value;
else
    config.SuspF = Vehicle.Chassis.SuspF.Linkage.Instance;
    config.AntiRollBarF = Vehicle.Chassis.SuspF.AntiRollBar.Instance;
end

if(~strcmp(Vehicle.Chassis.SuspR.class.Value,'Linkage'))
    config.SuspR = Vehicle.Chassis.SuspR.class.Value;
else
    config.SuspR = Vehicle.Chassis.SuspR.Linkage.Instance;
    config.AntiRollBarR = Vehicle.Chassis.SuspR.AntiRollBar.Instance;
end

config.SteerF = Vehicle.Chassis.SuspF.Steer.class.Value;
config.SteerR = Vehicle.Chassis.SuspR.Steer.class.Value;

config.SpringsF     = Vehicle.Chassis.Spring.Front.Instance;
config.SpringsR     = Vehicle.Chassis.Spring.Rear.Instance;
config.DamperF      = Vehicle.Chassis.Damper.Front.Instance;
config.DamperR      = Vehicle.Chassis.Damper.Rear.Instance;
config.TireF        = Vehicle.Chassis.TireF.Instance;

if(sum(strcmp(Vehicle.Chassis.TireF.class.Value,{'Tire2x'})))
    config.TireDynF = Vehicle.Chassis.TireF.TireInner.Dynamics.Value;
else
    config.TireDynF     = Vehicle.Chassis.TireF.Dynamics.Value;
end
config.TireR        = Vehicle.Chassis.TireR.Instance;
if(sum(strcmp(Vehicle.Chassis.TireR.class.Value,{'Tire2x'})))
    config.TireDynR = Vehicle.Chassis.TireR.TireInner.Dynamics.Value;
else
    config.TireDynR = Vehicle.Chassis.TireR.Dynamics.Value;
end
config.Power        = Vehicle.Powertrain.Power.class.Value;
config.Driveline    = Vehicle.Powertrain.Driveline.class.Value;
config.DriveShaftFL = Vehicle.Powertrain.Driveline.DriveshaftFL.class.Value;
config.Brakes       = Vehicle.Brakes.class.Value;
