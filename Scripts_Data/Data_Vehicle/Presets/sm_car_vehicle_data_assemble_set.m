function sm_car_vehicle_data_assemble_set
% Script to generate Vehicle data structures for various configurations
% Copyright 2019-2020 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

% If VDatabase does not exist in base workspace, create it
W = evalin('base','whos'); %or 'base'
doesExist = ismember('VDatabase',{W(:).name});
if(~doesExist)
   VDatabase = sm_car_import_vehicle_data('sm_car_database_Vehicle.xlsx',{'Structure','NameConvention'},0);
   assignin('base','VDatabase',VDatabase)
end

% Sets for which to generate configurations
Aero_Set  =  {'Sedan_HambaLG'};
ArbF_Set  =  {'Droplink_Sedan_HambaLG_f'};
ArbR_Set  =  {'Droplink_Sedan_HambaLG_r'};
Body_Set  =  {'Sedan_HambaLG'};
BodyGeometry_Set  =  {'Sedan_Scalable'};
Passenger_Set  =  {'Sedan_HambaLG_0111'};
Power_Set = {'Ideal2Motor_default'};
Brakes_Set = {'Pedal_Sedan_HambaLG'};
SteerF_Set  =  {'RackWheel_Sedan_HambaLG_f'};
SteerR_Set  =  {'None_default'};
DriverHumanF_Set  =  {'Sedan_HambaLG'};
Springs_Set  =  {'in_linFlinR_SHL'};
Dampers_Set  =  {'in_linFlinR_SHL'};
SuspR_Set = {'dwa_SHL'};
SuspF_Set = {'dwb_SHL','dwa_SHL','S2LAF_SHL','S2LAR_SHL','5S2LAF_SHL','5S2LAR_SHL','5CS2LAF_SHL','15DOF_SHL'};
Tire_Set  = {'MFEval_Generic_235_50R24','MFSwift_Generic_235_50R24'};
Tire_Dyn_Set = {'steady','lintra'};
%TireBody_Set = {'Parameterized'};
Drv_Set = {'f1Dr1D_SHL','f1D3Dr1D_SHL','fCVpCVr1D_SHL','fCVpCVflexr1D_SHL'};

%% Assemble individual configurations by looping on sets defined above

% Vehicle configuration index: 0 --> num configs
veh_ind = -1;
for AEi = 1:length(Aero_Set)
for AFi = 1:length(ArbF_Set)
for ARi = 1:length(ArbR_Set)
for BOi = 1:length(Body_Set)
for BGi = 1:length(BodyGeometry_Set)
for PAi = 1:length(Passenger_Set)
for POi = 1:length(Power_Set)
for BRi = 1:length(Brakes_Set)
for SPi = 1:length(Springs_Set)
for DAi = 1:length(Dampers_Set)
for SRi = 1:length(SuspR_Set)
for SFi = 1:length(SuspF_Set)
for ERi = 1:length(SteerR_Set)
for EFi = 1:length(SteerF_Set)
for DFi = 1:length(DriverHumanF_Set)
for TYi = 1:length(Tire_Set)
for TDi = 1:length(Tire_Dyn_Set)
%for TBi = 1:length(TireBody_Set)
    for DRi = 1:length(Drv_Set)
        veh_ind = veh_ind+1;

        % Assemble vehicle configuration set
        vehcfg_set = {
            'Aero',         Aero_Set{AEi},      '';...
            'Body',         Body_Set{BOi},      '';...
            'BodyGeometry', BodyGeometry_Set{BGi},      '';...
            'Passenger',    Passenger_Set{PAi},      '';...
            'Power',        Power_Set{POi},     '';...
            'Brakes',       Brakes_Set{BRi},    '';...
            'Springs',      Springs_Set{SPi},   '';...
            'Dampers',      Dampers_Set{DAi},   '';...
            'Susp',         SuspF_Set{SFi},     'front';
            'Susp',         SuspR_Set{SRi},     'rear';
            'Steer',        SteerF_Set{EFi},    'front';...
            'Steer',        SteerR_Set{ERi},    'rear';...
            'DriverHuman',  DriverHumanF_Set{DFi},    'front';...
            'AntiRollBar',  ArbF_Set{AFi},      'front';...
            'AntiRollBar',  ArbR_Set{ARi},      'rear';...
            'Tire',         Tire_Set{TYi},      'front';
            'Tire',         Tire_Set{TYi},      'rear';
            'TireDyn',      Tire_Dyn_Set{TDi},  'front';
            'TireDyn',      Tire_Dyn_Set{TDi},  'rear';
            'Driveline',    Drv_Set{DRi},       ''};
        assignin('base','vehcfg_set',vehcfg_set)
        % Assemble vehicle
        Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
        
        % For Constraint variant, only overwrite class.Value
        if(strcmpi(SuspF_Set{SFi},'5CS2LAF'))
            Vehicle.Chassis.SuspF.Linkage.class.Value = 'FiveLinkConstraintShockFront';
        end

        % Assemble configuration description in string
        bodystrings = strsplit(Body_Set{BOi},'_');
        
        Vehicle.config = [bodystrings{2} '_' SuspF_Set{SFi} '_' Tire_Set{TYi} '_' Tire_Dyn_Set{TDi} '_' Drv_Set{DRi}];

        % Remove suffixes that indicate platform and tire properties
        remove_str = {'_SHL', '_SH', '_235_50R24', '_213_40R21', '_Generic'};
        Vehicle.config = replace(Vehicle.config,remove_str,'');
        
        % Save under Vehicle_###
        veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
        eval([veh_var_name ' = Vehicle;']);
        save(veh_var_name,veh_var_name);
        disp([pad(veh_var_name,12) ': ' Vehicle.config]);
    end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
%end

% For comparison purposes only
%Vehicle_000 = Vehicle_a000;
%Vehicle_002 = Vehicle_a002;

% Use _000 as initial vehicle (default)
Vehicle = Vehicle_000;

%% Custom Configuration 1: One Driveshaft
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_1sh_SHL');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal1Motor_default');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_HambaLG','front');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_oneShaft';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 2: CVpCV Front and Rear
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVrCVpCV_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_fCVrCV';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 3: ABS
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'ABS_Sedan_HambaLG');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_1D3DABS';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 4: Nonlinear Spring
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_nlFlinR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_sprFnl';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 5: Interconnected Springs, Nonlinear Rear
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'con_linFnlR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_sprconRnl';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 6: Independent Spring, Linear only (no variants)
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'lin_linFlinR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_sprLin';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 7: Independent Damper, Nonlinear Rear
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linFnlR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_daminRnl';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 8: Interconnected Damper, Nonlinear Front
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D3Dr1D_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'con_nlFlinR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_damconFnl';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 9: Driveline CVCVp
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVCVpr1D_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_CVCVp1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 10: Stiff Suspension
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linStiffFlinStiffR_SHL');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_f1Dr1D_stiff';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 11: Stiff Suspension, Wheel Steer
veh_ind = veh_ind+1;
Vehicle = Vehicle_000;
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linStiffFlinStiffR_SHL');

Vehicle = sm_car_vehcfg_setSteer(Vehicle,'WheelDrivenRack_Sedan_HambaLG_f','front');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_HambaLG','front');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_f1Dr1D_stiff_RC';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 12: Sedan Hamba MFEval, Steady State
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Sedan_Hamba;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireR = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 13: Sedan Hamba MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Sedan_Hamba;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireR = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 14: Sedan Hamba MFEval, Linear
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Sedan_Hamba;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireR = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_213_40R21;

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','rear');

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_MFEval_lintra_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 13: Sedan Hamba MFSwift, Linear
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Sedan_Hamba;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireR = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_213_40R21;

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','rear');

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_MFSwift_lintra_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 14: Bus Makhulu, 6 tires MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.Tire2x_Bus_Makhulu;
Vehicle.Chassis.TireR.TireOuter = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireR.TireInner = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireR.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireR.TireInner.TireBody = VDatabase.TireBody.None;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFEval2x_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 15: Bus Makhulu 4 tires MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_270_70R22;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 16: Bus Makhulu 6 tires MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.Tire2x_Bus_Makhulu;
Vehicle.Chassis.TireR.TireOuter = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireR.TireInner = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireR.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireR.TireInner.TireBody = VDatabase.TireBody.None;

% Configure tire dynamics
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFSwift2x_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 17: Bus Makhulu 4 tires MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.Damper.Front = VDatabase.Damper.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Damper.Rear = VDatabase.Damper.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_270_70R22;

% Configure tire dynamics
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 18: Sedan Hamba CFL
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.Sedan_Scalable;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.CFL_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.Parameterized;
Vehicle.Chassis.TireR = VDatabase.Tire.CFL_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.Parameterized;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_CFL_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 19: Sedan Hamba Testrig Post
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Sedan_Hamba;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Sedan_Hamba;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Sedan_Hamba_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_r;

Vehicle.Chassis.TireF = VDatabase.Tire.Testrig_Post_213_40R21;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireR = VDatabase.Tire.Testrig_Post_213_40R21;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Sedan_Hamba;

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_TestrigPost_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 20: Bus Makhulu Testrig Post
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.None;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.Testrig_Post_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.Testrig_Post_270_70R22;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.CAD_270_70R22;

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_TestrigPost_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 20: Sedan HambaLG Testrig Post
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.TireF = VDatabase.Tire.Testrig_Post_235_50R24;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.Parameterized;
Vehicle.Chassis.TireR = VDatabase.Tire.Testrig_Post_235_50R24;
Vehicle.Chassis.TireR.TireBody = VDatabase.TireBody.Parameterized;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_TestrigPost_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 21: Sedan HambaLG Steering Rack_Sedan_HambaLG
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.Rack_Sedan_HambaLG_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_Rack';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 22: Sedan HambaLG Steering RackWheel_Sedan_HambaLG_f
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Sedan_HambaLG_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_RackWheel';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 23: Sedan HambaLG Steering RackStaticShafts_Sedan_HambaLG_f
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackStaticShafts_Sedan_HambaLG_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_RackStaticShafts';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 24: Sedan HambaLG Steering RackDrivenShafts_Sedan_HambaLG_f
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackDrivenShafts_Sedan_HambaLG_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_RackStaticShafts';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 25: Sedan HambaLG Steering WheelDrivenRack_Sedan_HambaLG_f
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');

Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.WheelDrivenRack_Sedan_HambaLG_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

% Assemble configuration description in string
Vehicle.config = 'HambaLG_dwb_MFEval_steady_WheelDrivenRack';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 26: ABS Hamba
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'ABS_Sedan_Hamba');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');

% Assemble configuration description in string
Vehicle.config = 'Hamba_dwb_MFEval_steady_1D3DABS';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 27: Bus Makhulu, 6 tires MFEval lintra
veh_ind = veh_ind+1;
Vehicle = Vehicle_002;
VDatabase = evalin('base','VDatabase');
Vehicle.Chassis.Body = VDatabase.Body.Bus_Makhulu;
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.CAD_Bus_Makhulu;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspF.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspF.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspR.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspR.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Front = VDatabase.Spring.Linear_Bus_Makhulu_f;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Bus_Makhulu_r;

Vehicle.Chassis.TireF = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireF.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireR = VDatabase.Tire.Tire2x_Bus_Makhulu;
Vehicle.Chassis.TireR.TireOuter = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireR.TireInner = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireR.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireR.TireInner.TireBody = VDatabase.TireBody.None;

Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','rear');

Vehicle.Powertrain.Driveline.DifferentialF = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFL.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftFR.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Pedal_Bus_Makhulu;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFEval2x_lintra_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 28: Hamba Live Axle, MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle.Chassis.SuspR = VDatabase.Susp.LiveAxle_Sedan_Hamba_r;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_LiveAxle_r;
Vehicle.Chassis.Damper.Rear = VDatabase.Damper.Linear_Sedan_Hamba_LiveAxle_r;

% Assemble configuration description in string
Vehicle.config = 'Hamba_LiveAxle_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 29: Hamba Live Axle, MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle.Chassis.SuspR = VDatabase.Susp.LiveAxle_Sedan_Hamba_r;
Vehicle.Chassis.Spring.Rear = VDatabase.Spring.Linear_Sedan_Hamba_LiveAxle_r;
Vehicle.Chassis.Damper.Rear = VDatabase.Damper.Linear_Sedan_Hamba_LiveAxle_r;

% Assemble configuration description in string
Vehicle.config = 'Hamba_LiveAxle_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 30: Hamba Electric2Motor, MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle.Powertrain.Power = VDatabase.Power.Electric2Motor_default;
% Assemble configuration description in string
Vehicle.config = 'Hamba_E2sha_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 31: Hamba Electric2Motor, MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle.Powertrain.Power = VDatabase.Power.Electric2Motor_default;
% Assemble configuration description in string
Vehicle.config = 'Hamba_E2sha_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 32: Hamba 3 power shaft, MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle.Powertrain.Power = VDatabase.Power.Electric3Motor_default;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
% Assemble configuration description in string
Vehicle.config = 'Hamba_E3sha_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 33: Hamba 3 power shaft, MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle.Powertrain.Power = VDatabase.Power.Electric3Motor_default;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
% Assemble configuration description in string
Vehicle.config = 'Hamba_E3sha_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 34: Hamba 15DOF, MFEval
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 35: Hamba 15DOF, MFSwift
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 36: Hamba 15DOF, MFEval, 2Motor Cooling
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric2Motor_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF2MotC_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 37: Hamba 15DOF, MFSwift, 2 Motor Cooling
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric2Motor_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF2MotC_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 36: Hamba 15DOF, MFEval, 3Motor Cooling
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric3Motor_default');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF3MotC_MFEval_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 37: Hamba 15DOF, MFSwift, 3Motor Cooling
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric3Motor_default');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF3MotC_MFSwift_steady_fCVpCVr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 38: Hamba 15DOF, MFSwift, 1D
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1Dr1D_SHL');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF_MFSwift_steady_f1Dr1D_SHL';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 39: Hamba double wishbone, Delft, fCVpCVr1D
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;

hold_config = Vehicle.config;
% Must use Delft Tire Software for RDF tests
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','front');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','front');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','rear');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','rear');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','rear');
% Put original config string back in Vehicle.config
Vehicle.config = hold_config;
Vehicle.config = strrep(Vehicle.config,'MFSwift','Delft');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')];
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 40: Makhulu, Delft, fCVpCVr1D
veh_ind = veh_ind+1;
Vehicle = Vehicle_146;

% Save configuration - needed for post-processing
hold_config = Vehicle.config;

% Take driver and people out of bus so it goes straight
% Modifies Vehicle.config
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0]);

% Must use Delft Tire Software for RDF tests
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','front');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','front');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','rear');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','rear');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','rear');

% Put original config string back in Vehicle.config
Vehicle.config = hold_config;
Vehicle.config = strrep(Vehicle.config,'MFSwift','Delft');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')];
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 41: Hamba 15DOF, MFSwift, 1D Fuel Cell
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','front');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'15DOF_SH','rear');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','front');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','rear');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','front');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell1Motor_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Pressure_Sedan_Hamba');
Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF_MFSwift_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 42: Hamba 15DOF, MFeval, 1D Fuel Cell
veh_ind = veh_ind+1;
Vehicle = Vehicle_164;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell1Motor_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Pressure_Sedan_Hamba');
Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF_MFEval_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 43: Real-Time Basic, MFeval with lintra
veh_ind = veh_ind+1;
Vehicle = Vehicle_170;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','front');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','rear');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','rear');
Vehicle.Chassis.SuspF.Simple.Roll.d.Value = Vehicle.Chassis.SuspF.Simple.Roll.d.Value*0.5;
Vehicle.Chassis.SuspR.Simple.Roll.d.Value = Vehicle.Chassis.SuspR.Simple.Roll.d.Value*0.5;
Vehicle.Chassis.SuspF.Simple.Roll.K.Value = Vehicle.Chassis.SuspF.Simple.Roll.K.Value*0.5;
Vehicle.Chassis.SuspR.Simple.Roll.K.Value = Vehicle.Chassis.SuspR.Simple.Roll.K.Value*0.5;
Vehicle.config = 'Hamba_15DOF_MFEval_lintra_f1Dr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 44: Real-Time Full, MFeval with lintra
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','front');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','front');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','rear');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','rear');
Vehicle.config = 'Hamba_dwb_MFEval_lintra_f1Dr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 45: Makhulu dwb, MFSwift, 1D Fuel Cell
veh_ind = veh_ind+1;
Vehicle = Vehicle_145;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell1Motor_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Pressure_Bus_Makhulu');
Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFSwift_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 46: Makhulu dwb, MFeval, 1D Fuel Cell
veh_ind = veh_ind+1;
Vehicle = Vehicle_143;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell1Motor_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Pressure_Bus_Makhulu');
Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Front.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFEval_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Trailer Elula MFEval
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula',      '';...
    'BodyGeometry', 'Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'in_linF_TrElu',   '';...
    'Dampers',      'in_linF_TrElu',   '';...
    'Susp',         '15DOF_TrElu',     'front';
    'Steer',        'None_default',    'front';...
    'Tire',         'MFEval_Generic_213_40R21',      'front';
    'TireDyn',      'steady',  'front';
    'Driveline',    'Axle1_None',       ''};

Trailer_01 = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer_01.config = 'Elula_MFEval';

save Trailer_01 Trailer_01

%% Trailer Thwala MFEval
vehcfg_set = {
    'Aero',         'Trailer_Thwala',      '';...
    'Body',         'Trailer_Thwala',      '';...
    'BodyGeometry', 'CAD_Trailer_Thwala',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'in_linF_TrThw',   '';...
    'Dampers',      'in_linF_TrThw',   '';...
    'Susp',         '15DOF_TrThw',     'front';
    'Steer',        'None_default',    'front';...
    'Tire',         'MFEval_CAD_145_70R13',      'front';
    'TireDyn',      'steady',  'front';
    'Driveline',    'Axle1_None',       ''};

Trailer_02 = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer_02.config = 'Thwala_MFEval';

save Trailer_02 Trailer_02

%% Trailer Elula MFSwift
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula',      '';...
    'BodyGeometry', 'Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'in_linF_TrElu',   '';...
    'Dampers',      'in_linF_TrElu',   '';...
    'Susp',         '15DOF_TrElu',     'front';
    'Steer',        'None_default',    'front';...
    'Tire',         'MFSwift_Generic_213_40R21',      'front';
    'TireDyn',      'steady',  'front';
    'Driveline',    'Axle1_None',       ''};

Trailer_03 = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer_03.config = 'Elula_MFSwift';

save Trailer_03 Trailer_03

%% Trailer Thwala MFSwift
vehcfg_set = {
    'Aero',         'Trailer_Thwala',      '';...
    'Body',         'Trailer_Thwala',      '';...
    'BodyGeometry', 'CAD_Trailer_Thwala',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'in_linF_TrThw',   '';...
    'Dampers',      'in_linF_TrThw',   '';...
    'Susp',         '15DOF_TrThw',     'front';
    'Steer',        'None_default',    'front';...
    'Tire',         'MFSwift_CAD_145_70R13',      'front';
    'TireDyn',      'steady',  'front';
    'Driveline',    'Axle1_None',       ''};

Trailer_04 = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer_04.config = 'Thwala_MFSwift';

save Trailer_04 Trailer_04

%% Trailer Elula MFEval Unstable
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula_Unstable',      '';...
    'BodyGeometry', 'Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'in_linF_TrElu',   '';...
    'Dampers',      'in_linF_TrElu',   '';...
    'Susp',         '15DOF_TrElu',     'front';
    'Steer',        'None_default',    'front';...
    'Tire',         'MFEval_Generic_213_40R21',      'front';
    'TireDyn',      'steady',  'front';
    'Driveline',    'Axle1_None',       ''};

Trailer_05 = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer_05.config = 'Elula_MFEval_Unstable';

save Trailer_05 Trailer_05


%% Return to main directory
cd(fileparts(which('sm_car')));

