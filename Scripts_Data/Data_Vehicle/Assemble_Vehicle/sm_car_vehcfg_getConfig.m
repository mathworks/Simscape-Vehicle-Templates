function config = sm_car_vehcfg_getConfig(Vehicle)
% Get list of key selected variants

config.Aero         = Vehicle.Chassis.Aero.class.Value;
config.Body         = Vehicle.Chassis.Body.class.Value;
config.BodyGeometry = Vehicle.Chassis.Body.BodyGeometry.class.Value;

chassisFields    = fieldnames(Vehicle.Chassis);
suspFieldInds = find(contains(chassisFields,'Susp'));
suspFields = sort(chassisFields(suspFieldInds));

for axle_i = 1:length(suspFields)
    suspField  = suspFields{axle_i};
    
    if(~strcmp(Vehicle.Chassis.(suspField).class.Value,'Linkage'))
        config.(suspField)  = Vehicle.Chassis.(suspField).class.Value;
    else
        config.(suspField) = Vehicle.Chassis.(suspField).Linkage.Instance;
        config.([suspField '_AntiRollBar']) = Vehicle.Chassis.(suspField).AntiRollBar.Instance;
    end
    if(isfield(Vehicle.Chassis.(suspField),'Steer'))
        config.([suspField '_Steer']) = Vehicle.Chassis.(suspField).Steer.class.Value;
    end
end

config.Springs   = Vehicle.Chassis.Spring.class.Value;
springFields    = fieldnames(Vehicle.Chassis.Spring);
springFieldInds = find(contains(springFields,'Axle'));
if(~isempty(springFieldInds))
    springFieldList = sort(springFields(springFieldInds));
    for axle_i = 1:length(springFieldInds)
        springField = springFieldList{axle_i};
        config.(['Spring_' springField]) = Vehicle.Chassis.Spring.(springField).Instance;
    end
end

config.Dampers   = Vehicle.Chassis.Damper.class.Value;
damperFields    = fieldnames(Vehicle.Chassis.Damper);
damperFieldInds = find(contains(damperFields,'Axle'));
if(~isempty(damperFieldInds))
    damperFieldList = sort(damperFields(damperFieldInds));
    for axle_i = 1:length(damperFieldInds)
        damperField = damperFieldList{axle_i};
        config.(['Damper_' damperField]) = Vehicle.Chassis.Damper.(damperField).Instance;
    end
end

chassis_fnames = fieldnames(Vehicle.Chassis);
fname_inds_tire = find(startsWith(chassis_fnames,'Tire'));

if(~isempty(fname_inds_tire))
    tireFields = sort(chassis_fnames(fname_inds_tire));
    for axle_i = 1:length(fname_inds_tire)
        tireField = tireFields{axle_i};
        config.(tireField)        = Vehicle.Chassis.(tireField).Instance;
        
        if(sum(strcmp(Vehicle.Chassis.(tireField).class.Value,{'Tire2x'})))
            if(isfield(Vehicle.Chassis.(tireField).TireInner,'Dynamics'))
                config.([tireField '_Dynamics']) = Vehicle.Chassis.(tireField).TireInner.Dynamics.Value;
            end
        else
            if(isfield(Vehicle.Chassis.(tireField),'Dynamics'))
                config.([tireField '_Dynamics']) = Vehicle.Chassis.(tireField).Dynamics.Value;
            end
        end
    end
end

config.Power        = Vehicle.Powertrain.Power.class.Value;
config.Driveline    = Vehicle.Powertrain.Driveline.class.Value;
%config.DriveShaftFL = Vehicle.Powertrain.Driveline.DriveshaftFL.class.Value;
config.Brakes       = Vehicle.Brakes.class.Value;
