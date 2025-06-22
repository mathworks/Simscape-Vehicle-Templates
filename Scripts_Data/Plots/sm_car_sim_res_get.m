function simres = sm_car_sim_res_get(logsout,simlog,Vehicle,varName)
% sm_car_get_sim_res  Extract results from Simscape Vehicle Templates output
%    sm_car_get_sim_res(logsout,simlog,Vehicle,varName)
%
%    Provide one strings that are abbreviations for simulation results to
%    be obtained from logsout and simlog variables.  Data structure Vehicle
%    is needed for some results to obtain tire radius.
%
% Copyright 2018-2025 The MathWorks, Inc.

logsout_VehBus = logsout.get('VehBus');

switch varName
    case {'vWhl','wWhl'}
        [tire_radius, ~] = sm_car_get_TireRadius(Vehicle);

        chassis_log_fieldnames = fieldnames(logsout_VehBus.Values.Chassis);
        whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
        whlnames = sort(chassis_log_fieldnames(whl_inds));

        for whl_i = 1:length(whl_inds)
            w = logsout_VehBus.Values.Chassis.(whlnames{whl_i}).n.Data;
            if(strcmp(varName,'wWhl'))
                simres.data(:,whl_i) = w;
                simres.units = 'rad/s';
            else
                radius_ind = str2num(whlnames{whl_i}(end));
                simres.data(:,whl_i) = w*tire_radius(radius_ind);
                simres.units = 'm/s';
            end
        end
        simres.name   = 'Wheel Speed';
        simres.labels = whlnames;
    case {'pxWhl','pyWhl','pzWhl'}
        %[tire_radius, ~] = sm_car_get_TireRadius(Vehicle);
        posInd = strfind('xyz',varName(2));

        chassis_log_fieldnames = fieldnames(logsout_VehBus.Values.Chassis);
        whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
        whlnames = sort(chassis_log_fieldnames(whl_inds));

        for whl_i = 1:length(whl_inds)
            p = logsout_VehBus.Values.Chassis.(whlnames{whl_i}).xyz.Data(:,posInd);
                simres.data(:,whl_i) = p;
                simres.units = 'm';
        end
        simres.name   = ['Wheel Center ' upper(varName(2)) ' Position'];
        simres.labels = whlnames;
    case 'pxVeh'
        simres.data  = logsout_VehBus.Values.World.x.Data;
        simres.name  = 'Vehicle x';
        simres.units = 'm';
    case 'pyVeh'
        simres.data  = logsout_VehBus.Values.World.y.Data;
        simres.name  = 'Vehicle y';
        simres.units = 'm';
    case 'pzVeh'
        simres.data  = logsout_VehBus.Values.World.z.Data;
        simres.name  = 'Vehicle z';
        simres.units = 'm';
    case 'dxVeh'
        logsout_xCar = logsout_VehBus.Values.World.x;
        logsout_yCar = logsout_VehBus.Values.World.y;

        simres.data = [0;cumsum(sqrt((diff(logsout_xCar.Data)).^2+diff(logsout_yCar.Data).^2))];
        simres.name  = 'Distance Traveled';
        simres.units = 'm';
    case 'vxVeh'
        simres.data  = logsout_VehBus.Values.World.vx.Data;
        simres.name  = 'Vehicle vx';
        simres.units = 'm/s';
    case 'vyVeh'
        simres.data  = logsout_VehBus.Values.World.vy.Data;
        simres.name  = 'Vehicle vy';
        simres.units = 'm/s';
    case 'vVeh'
        logsout_vxVeh = logsout_VehBus.Values.World.vx;
        logsout_vyVeh = logsout_VehBus.Values.World.vy;
        logsout_vzVeh = logsout_VehBus.Values.World.vz;
        simres.data   = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2+logsout_vzVeh.Data.^2);
        simres.name   = 'Vehicle v';
        simres.units  = 'm/s';
    case 'slipAngVeh'
        logsout_vxVeh = logsout_VehBus.Values.Chassis.Body.CG.vx;
        logsout_vyVeh = logsout_VehBus.Values.Chassis.Body.CG.vy;
        simres.data   = atan2(logsout_vyVeh.Data, logsout_vxVeh.Data);
        simres.name   = 'Vehicle Slip Angle';
        simres.units  = 'rad';
    case 'aPitch'
        simres.data  = logsout_VehBus.Values.World.aPitch.Data(:);
        simres.name  = 'Vehicle Pitch';
        simres.units = 'rad';
    case 'aRoll'
        simres.data  = logsout_VehBus.Values.World.aRoll.Data(:);
        simres.name  = 'Vehicle Roll';
        simres.units = 'rad';
    case 'aYaw'
        simres.data  = logsout_VehBus.Values.World.aYaw.Data(:);
        simres.name  = 'Vehicle Yaw';
        simres.units = 'rad';
    case 'nPitch'
        simres.data  = logsout_VehBus.Values.World.nPitch.Data(:);
        simres.name  = 'Vehicle Pitch Rate';
        simres.units = 'rad/s';
    case 'nRoll'
        simres.data  = logsout_VehBus.Values.World.nRoll.Data(:);
        simres.name  = 'Vehicle Roll Rate';
        simres.units = 'rad/s';
    case 'nYaw'
        simres.data  = logsout_VehBus.Values.World.nYaw.Data(:);
        simres.name  = 'Vehicle Yaw Rate';
        simres.units = 'rad/s';
    case 'time'
        simres.data  = logsout_VehBus.Values.Chassis.SuspA1.WhlL.aToe.Time;
        simres.name  = 'Time';
        simres.units = 's';
    case {'fxWhl','fyWhl','fzWhl','mxWhl','myWhl','mzWhl'}
        chassis_log_fieldnames = fieldnames(logsout_VehBus.Values.Chassis);
        whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
        whlnames = sort(chassis_log_fieldnames(whl_inds));
        fName = [upper(varName(1)) varName(2)];
        simres.name = strrep(fName,'F','Wheel Force ');
        simres.name = strrep(simres.name,'M','Wheel Moment ');
        for whl_i = 1:length(whl_inds)
            simres.data(:,whl_i) = logsout_VehBus.Values.Chassis.(whlnames{whl_i}).(fName).Data;
        end
        if (strcmpi(varName(1),'m'))
            simres.units = 'N*m';
        else
            simres.units = 'N';
        end
        simres.labels = whlnames;
    case 'toeWhl'
        simres.data(:,1) = -logsout_VehBus.Values.Chassis.SuspA1.WhlL.aToe.Data*pi/180;
        simres.data(:,2) = logsout_VehBus.Values.Chassis.SuspA1.WhlR.aToe.Data*pi/180;
        simres.labels = {'WhlL1','WhlR1'};
        if(isfield(logsout_VehBus.Values.Chassis,'SuspA2'))
            simres.data(:,3) = -logsout_VehBus.Values.Chassis.SuspA2.WhlL.aToe.Data*pi/180;
            simres.data(:,4) = logsout_VehBus.Values.Chassis.SuspA2.WhlR.aToe.Data*pi/180;
            simres.labels = {'WhlL1','WhlR1','WhlL2','WhlR2'};
        end
        simres.name   = 'Wheel Toe Angle';
        simres.units  = 'rad';
        simres.note   = '+ is CCW from top view';
    case 'camWhl'
        simres.data(:,1) = -logsout_VehBus.Values.Chassis.SuspA1.WhlL.aCamber.Data*pi/180;
        simres.data(:,2) = logsout_VehBus.Values.Chassis.SuspA1.WhlR.aCamber.Data*pi/180;
        simres.labels = {'WhlL1','WhlR1'};
        if(isfield(logsout_VehBus.Values.Chassis,'SuspA2'))
            simres.data(:,3) = -logsout_VehBus.Values.Chassis.SuspA2.WhlL.aCamber.Data*pi/180;
            simres.data(:,4) = logsout_VehBus.Values.Chassis.SuspA2.WhlR.aCamber.Data*pi/180;
            simres.labels = {'WhlL1','WhlR1','WhlL2','WhlR2'};
        end
        simres.name   = 'Wheel Camber Angle';
        simres.units  = 'rad';
        simres.note   = '+ is CCW from rear view';
    case 'fRack'
        simres.data  = logsout_VehBus.Values.Chassis.SuspA1.Steer.FRack.Data(:);
        simres.name  = 'Rack Actuation Force';
        simres.units = 'N';
    case 'xRack'
        simres.data  = logsout_VehBus.Values.Chassis.SuspA1.Steer.xRack.Data(:);
        simres.name  = 'Rack Position';
        simres.units = 'm';
    case 'aSteer'
        simres.data  = logsout_VehBus.Values.Chassis.SuspA1.Steer.aWheel.Data(:);
        simres.name  = 'Steering Wheel Angle';
        simres.units = 'rad';
    case 'qTrackRod'
        % Suspension may not have a track rod, or it may require extra
        % logic to obtain the correct field.  Use try-catch.
        try 
            % Obtain joint angles (deviation from design position)
            suspType = simlog.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_L.childIds;
            UJLqx = simlog.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_L.(suspType{1}).Universal_Rack_Rod.Universal_Joint.Rx.q.series.values('rad');
            UJLqy = simlog.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_L.(suspType{1}).Universal_Rack_Rod.Universal_Joint.Ry.q.series.values('rad');

            UJRqx = simlog.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_R.(suspType{1}).Universal_Rack_Rod.Universal_Joint.Rx.q.series.values('rad');
            UJRqy = simlog.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_R.(suspType{1}).Universal_Rack_Rod.Universal_Joint.Ry.q.series.values('rad');

            % Obtain angle in design position using hardpoints
            dxyz0 = Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value-...
                  Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value;
            qx0 = atan2(dxyz0(3),dxyz0(2)); 
            qy0 = atan2(dxyz0(1),dxyz0(2));
            
            % Calculate angle between rack and track rod
            simres.data(:,1)  = atand(sqrt(tan(UJLqx+qx0).^2 + tan(UJLqy+qy0).^2));
            simres.data(:,2)  = atand(sqrt(tan(-UJRqx+qx0).^2 + tan(-UJRqy+qy0).^2));
            simres.name  = 'Track Rod Angle';
            simres.units = 'deg';
            simres.labels = {'qRodL1','qRodR1'};
            simres.note   = 'Angle between rack and track rod';
        catch
            error('Cannot calculate track rod joint angle.  Ensure your suspension has a track rod and check the code to extract angle');
        end
end
