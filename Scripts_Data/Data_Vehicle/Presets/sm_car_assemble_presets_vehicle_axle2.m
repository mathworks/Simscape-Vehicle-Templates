function sm_car_assemble_presets_vehicle_axle2
% Script to generate Vehicle data structures for various configurations
% Copyright 2019-2021 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

% If VDatabase does not exist in base workspace, create it
W = evalin('base','whos'); %or 'base'
doesExist = ismember('VDatabase',{W(:).name});
if(~doesExist)
   VDatabase = sm_car_import_vehicle_data(0,1);
   assignin('base','VDatabase',VDatabase)
end

% Sets for which to generate configurations
Aero_Set  =  {'Sedan_HambaLG'};
ArbF_Set  =  {'Droplink_Sedan_HambaLG_f'};
ArbR_Set  =  {'Droplink_Sedan_HambaLG_r'};
Body_Set  =  {'Sedan_HambaLG'};
BodyGeometry_Set  =  {'Sedan_HambaLG'};
Passenger_Set  =  {'Sedan_HambaLG_0111'};
Power_Set = {'Ideal_A1_A2_default'};
Brakes_Set = {'Axle2_PedalAbstract_DiscDisc_Sedan_HambaLG'};
SteerF_Set  =  {'RackWheel_Sedan_HambaLG_f'};
SteerR_Set  =  {'None_default'};
DriverHumanF_Set  =  {'Sedan_HambaLG'};
Springs_Set  =  {'SHLlinA1_SHLlinA2'};
Dampers_Set  =  {'SHLlinA1_SHLlinA2'};
%SuspA2_Set_cfg = {'dwa_SHL'};
SuspR_Set = {'DoubleWishboneA_Sedan_HambaLG_r'};
SuspF_Set_cfg = {'dwb_SHL','dwa_SHL','S2LAF_SHL','S2LAR_SHL','5S2LAF_SHL','5S2LAR_SHL','5CS2LAF_SHL','15DOF_SHL'};
SuspF_Set = {'DoubleWishbone_Sedan_HambaLG_f','DoubleWishboneA_Sedan_HambaLG_f','SplitLowerArmShockFront_Sedan_HambaLG_f','SplitLowerArmShockRear_Sedan_HambaLG_f','FiveLinkShockFront_Sedan_HambaLG_f','FiveLinkShockRear_Sedan_HambaLG_f','5CS2LAF_SHL_f','Simple15DOF_Sedan_HambaLG_f'};
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
        
        if strcmp(SuspF_Set_cfg{SFi},'15DOF_SHL')
            % For presets, if 15DOF in front, use it in the rear
            suspr_set_i  = 'Simple15DOF_Sedan_HambaLG_r';
            % Ackermann steering for 15DOF only 
            steerf_set_i = 'Ackermann_HambaLG_f';
        else
            suspr_set_i  = SuspR_Set{SRi};
            steerf_set_i = SteerF_Set{EFi};
        end
        
        % Assemble vehicle configuration set
        vehcfg_set = {
            'Aero',         Aero_Set{AEi},        '';...
            'Body',         Body_Set{BOi},        '';...
            'BodyGeometry', BodyGeometry_Set{BGi},'';...
            'BodyLoad',     'None',               '';...
            'Passenger',    Passenger_Set{PAi},   '';...
            'Power',        Power_Set{POi},       '';...
            'Brakes',       Brakes_Set{BRi},      '';...
            'Springs',      'Axle2_Independent',   Springs_Set{SPi};...
            'Dampers',      'Axle2_Independent',   Dampers_Set{DAi};...
            'Susp',         SuspF_Set{SFi},      'SuspA1';
            'Susp',         suspr_set_i,         'SuspA2';
            'Steer',        steerf_set_i,        'SuspA1';...
            'Steer',        SteerR_Set{ERi},     'SuspA2';...
            'DriverHuman',  DriverHumanF_Set{DFi},    'SuspA1';...
            'AntiRollBar',  ArbF_Set{AFi},       'SuspA1';...
            'AntiRollBar',  ArbR_Set{ARi},       'SuspA2';...
            'Tire',         Tire_Set{TYi},       'TireA1';
            'Tire',         Tire_Set{TYi},       'TireA2';
            'TireDyn',      Tire_Dyn_Set{TDi},   'TireA1';
            'TireDyn',      Tire_Dyn_Set{TDi},   'TireA2';
            'Driveline',    Drv_Set{DRi},        ''};
        assignin('base','vehcfg_set',vehcfg_set)
        % Assemble vehicle
        Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
        
        % For Constraint variant, only overwrite class.Value
        if(strcmpi(SuspF_Set_cfg{SFi},'5CS2LAF_f'))
            Vehicle.Chassis.SuspA1.Linkage.class.Value = 'FiveLinkConstraintShockFront';
        end

        % Assemble configuration description in string
        bodystrings = strsplit(Body_Set{BOi},'_');
        
        %Vehicle.config = [bodystrings{2} '_' SuspF_Set{SFi} '_' Tire_Set{TYi} '_' Tire_Dyn_Set{TDi} '_' Drv_Set{DRi}];
        Vehicle.config = [bodystrings{2} '_' SuspF_Set_cfg{SFi} '_' Tire_Set{TYi} '_' Tire_Dyn_Set{TDi} '_' Drv_Set{DRi}];

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
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_A1_default');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_HambaLG','SuspA1');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_HydraulicValves_Channel4_Sedan_HambaLG');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_nlFlinR_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Independent','SHLnonlinA1_SHLlinA2');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'con_linFnlR_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Interconnected','SHLlinA1_SHLnonlinA2');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'lin_linFlinR_SHL');
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Linear','SHLlinA1_SHLlinA2');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Linear_Sedan_HambaLG','None');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linFnlR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Independent','SHLlinA1_SHLnonlinA2');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setDamper(Vehicle,'con_nlFlinR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Interconnected','SHLnonlinA1_SHLlinA2');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Independent','SHLlinStiffA1_SHLlinStiffA2');
%Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Independent','SHLlinStiffA1_SHLlinStiffA2');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
%Vehicle = sm_car_vehcfg_setSpring(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Independent','SHLlinStiffA1_SHLlinStiffA2');
%Vehicle = sm_car_vehcfg_setDamper(Vehicle,'in_linStiffFlinStiffR_SHL');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Independent','SHLlinStiffA1_SHLlinStiffA2');

Vehicle = sm_car_vehcfg_setSteer(Vehicle,'WheelDrivenRack_Sedan_HambaLG_f','SuspA1');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_HambaLG','SuspA1');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFEval_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_213_40R21;

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA2');

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFSwift_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_213_40R21;

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA2');

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Tire2x_270_70R22;
Vehicle.Chassis.TireA2.TireOuter = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA2.TireInner = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA2.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireA2.TireInner.TireBody = VDatabase.TireBody.None;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_270_70R22;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Tire2x_270_70R22;
Vehicle.Chassis.TireA2.TireOuter = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireA2.TireInner = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireA2.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireA2.TireInner.TireBody = VDatabase.TireBody.None;

% Configure tire dynamics
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.Damper.Axle1 = VDatabase.Damper.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Damper.Axle2 = VDatabase.Damper.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.MFSwift_270_70R22;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_270_70R22;

% Configure tire dynamics
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
%Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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
Vehicle.Chassis.Body.BodyGeometry = VDatabase.BodyGeometry.Sedan_HambaLG;
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.CFL_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.Parameterized;
Vehicle.Chassis.TireA2 = VDatabase.Tire.CFL_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.Parameterized;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Sedan_Hamba_0111;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_Hamba_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_Hamba;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Sedan_Hamba_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Sedan_Hamba_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Sedan_Hamba_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Sedan_Hamba_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.Testrig_Post_213_40R21;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_213_40R21;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Testrig_Post_213_40R21;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_213_40R21;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Sedan_Hamba_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Sedan_Hamba;

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.None;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.Testrig_Post_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Testrig_Post_270_70R22;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.CAD_270_70R22;

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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

Vehicle.Chassis.TireA1 = VDatabase.Tire.Testrig_Post_235_50R24;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.Parameterized;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Testrig_Post_235_50R24;
Vehicle.Chassis.TireA2.TireBody = VDatabase.TireBody.Parameterized;

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

Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.Rack_Sedan_HambaLG_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

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

Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Sedan_HambaLG_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

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

Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackStaticShafts_Sedan_HambaLG_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

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

Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackDrivenShafts_Sedan_HambaLG_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

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

Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.WheelDrivenRack_Sedan_HambaLG_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Sedan_HambaLG;

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
Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_HydraulicValves_Channel4_Sedan_Hamba');

% Configure tire dynamics
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');

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
Vehicle.Chassis.Body.BodyLoad = VDatabase.BodyLoad.None;
Vehicle.Chassis.Body.Passenger = VDatabase.Passenger.Bus_Makhulu_1111;
Vehicle.Chassis.Aero = VDatabase.Aero.Bus_Makhulu;

Vehicle.Chassis.SuspA1.Linkage = VDatabase.Linkage.DoubleWishbone_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer = VDatabase.Steer.RackWheel_Bus_Makhulu_f;
Vehicle.Chassis.SuspA1.Steer.DriverHuman = VDatabase.DriverHuman.Bus_Makhulu;

Vehicle.Chassis.SuspA2.Linkage = VDatabase.Linkage.DoubleWishboneA_Bus_Makhulu_r;
Vehicle.Chassis.SuspA2.AntiRollBar = VDatabase.AntiRollBar.Droplink_Bus_Makhulu_r;

Vehicle.Chassis.Spring.Axle1 = VDatabase.Spring.Bus_Makhulu_Linear_A1;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.Bus_Makhulu_Linear_A2;

Vehicle.Chassis.TireA1 = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA1.TireBody = VDatabase.TireBody.CAD_270_70R22;
Vehicle.Chassis.TireA2 = VDatabase.Tire.Tire2x_270_70R22;
Vehicle.Chassis.TireA2.TireOuter = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA2.TireInner = VDatabase.Tire.MFEval_270_70R22;
Vehicle.Chassis.TireA2.TireOuter.TireBody = VDatabase.TireBody.CAD_270_70R22_2x;
Vehicle.Chassis.TireA2.TireInner.TireBody = VDatabase.TireBody.None;

Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA2');

Vehicle.Powertrain.Driveline.DifferentialA1 = VDatabase.Differential.Gear1DShafts3D_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftL1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;
Vehicle.Powertrain.Driveline.DriveshaftR1.Shaft = VDatabase.Shaft.Rigid_Bus_Makhulu_f;

Vehicle.Brakes = VDatabase.Brakes.Axle2_PedalAbstract_DiscDisc_Bus_Makhulu;

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
Vehicle.Chassis.SuspA2 = VDatabase.Susp.LiveAxle_Sedan_Hamba_r;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.No_Spring;
Vehicle.Chassis.Damper.Axle2 = VDatabase.Damper.Sedan_Hamba_LiveAxle_A2;

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
Vehicle.Chassis.SuspA2 = VDatabase.Susp.LiveAxle_Sedan_Hamba_r;
Vehicle.Chassis.Spring.Axle2 = VDatabase.Spring.No_Spring;
Vehicle.Chassis.Damper.Axle2 = VDatabase.Damper.Sedan_Hamba_LiveAxle_A2;

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
Vehicle.Powertrain.Power = VDatabase.Power.Electric_A1_A2_default;
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
Vehicle.Powertrain.Power = VDatabase.Power.Electric_A1_A2_default;
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
Vehicle.Powertrain.Power = VDatabase.Power.Electric_A1_L2_R2_default;
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
Vehicle.Powertrain.Power = VDatabase.Power.Electric_A1_L2_R2_default;
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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Liquid_Loop1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Liquid_Loop1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_L2_R2_default');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Liquid_Loop1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_L2_R2_default');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Liquid_Loop1');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
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
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','TireA1');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','TireA2');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','TireA2');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','TireA2');
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
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');

% Must use Delft Tire Software for RDF tests
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA1');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','TireA1');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','TireA2');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','TireA2');
Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','TireA2');
Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','TireA2');

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
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'None_default','SuspA2');
Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,'Sedan_Hamba','SuspA1');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell_A1_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_PressureAbstract_DiscDisc_Sedan_Hamba');
Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value*5;

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
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell_A1_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_PressureAbstract_DiscDisc_Sedan_Hamba');
Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value*5;

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
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','TireA2');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA2');
Vehicle.Chassis.SuspA1.Simple.Roll.d.Value = Vehicle.Chassis.SuspA1.Simple.Roll.d.Value*0.5;
Vehicle.Chassis.SuspA2.Simple.Roll.d.Value = Vehicle.Chassis.SuspA2.Simple.Roll.d.Value*0.5;
Vehicle.Chassis.SuspA1.Simple.Roll.K.Value = Vehicle.Chassis.SuspA1.Simple.Roll.K.Value*0.5;
Vehicle.Chassis.SuspA2.Simple.Roll.K.Value = Vehicle.Chassis.SuspA2.Simple.Roll.K.Value*0.5;
Vehicle.config = 'Hamba_15DOF_MFEval_lintra_f1Dr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 44: Real-Time Full, MFeval with lintra
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFEval_CAD_213_40R21','TireA2');
Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'lintra','TireA2');
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
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell_A1_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_PressureAbstract_DiscDisc_Bus_Makhulu');
Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFSwift2x_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 46: Makhulu dwb, MFeval, 1D Fuel Cell
veh_ind = veh_ind+1;
Vehicle = Vehicle_143;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCV_FC1m');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'FuelCell_A1_default');

Vehicle = sm_car_vehcfg_setBrakes(Vehicle,'Axle2_PressureAbstract_DiscDisc_Bus_Makhulu');
Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value = Vehicle.Brakes.Axle1.Caliper.lCylinderDiameter.Value*5;

% Assemble configuration description in string
Vehicle.config = 'Makhulu_dwb_MFEval_steady_fwd3D_FuelCell';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 47: Sedan, MFeval, Battery 2 Motor for Regen
veh_ind = veh_ind+1;
Vehicle = Vehicle_166;
vehcfg = Vehicle.config;

Vehicle.Brakes.class.Value = 'PressureAbstract_DiscDisc';
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_regen'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 48: Sedan, MFSwift, Battery 2 Motor for Regen
veh_ind = veh_ind+1;
Vehicle = Vehicle_167;
vehcfg = Vehicle.config;

Vehicle.Brakes.class.Value = 'PressureAbstract_DiscDisc';
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_regen'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 49: Sedan, MFeval, Ideal 4 motor
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D_r1D_4sh_SH');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_4motor'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 50: Sedan, MFSwift, Ideal 4 motor
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'f1D_r1D_4sh_SH');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_4motor'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 51: Achilles, MFEval, Ideal 2 motor
veh_ind = veh_ind+1;

vehcfg_set = {
    'Aero',         'FSAE_Achilles',                                '';...
    'Body',         'FSAE_Achilles',                                '';...
    'BodyGeometry', 'FSAE_Achilles',                                '';...
    'BodyLoad',     'None',                                         '';...
    'Passenger',    'None',                                         '';...
    'Power',        'Ideal_A1_A2_default',                          '';...
    'Brakes',       'Axle2_PedalAbstract_DiscDisc_FSAE_Achilles',   '';...
    'Springs',      'Axle2_Independent',                            'AClinA1_AClinA2';...
    'Dampers',      'Axle2_Independent',                            'AClinA1_AClinA2';...
    'Susp',         'DoubleWishbonePushUA_FSAE_Achilles_f',         'SuspA1';
    'Susp',         'DoubleWishbonePushUAnoSteer_FSAE_Achilles_r',  'SuspA2';
    'Steer',        'WheelDrivenRack1UJoint_Achilles',              'SuspA1';...
    'Steer',        'None_default',                                 'SuspA2';...
    'DriverHuman',  'None',                                         'SuspA1';...
    'AntiRollBar',  'DroplinkRod_FSAE_Achilles_f',                  'SuspA1';...
    'AntiRollBar',  'DroplinkRod_FSAE_Achilles_r',                  'SuspA2';...
    'Tire',         'MFEval_Generic_190_50R10',                     'TireA1';
    'Tire',         'MFEval_Generic_190_50R10',                     'TireA2';
    'TireDyn',      'steady',                                       'TireA1';
    'TireDyn',      'steady',                                       'TireA2';
    'Driveline',    'f1Dr1D_SHL',                                   ''};

Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Achilles_dwpua_MFEval_steady_f1Dr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 51: Achilles, MFSwift, Ideal 2 motor
veh_ind = veh_ind+1;

vehcfg_set = {
    'Aero',         'FSAE_Achilles',                                '';...
    'Body',         'FSAE_Achilles',                                '';...
    'BodyGeometry', 'FSAE_Achilles',                                '';...
    'BodyLoad',     'None',                                         '';...
    'Passenger',    'None',                                         '';...
    'Power',        'Ideal_A1_A2_default',                          '';...
    'Brakes',       'Axle2_PedalAbstract_DiscDisc_FSAE_Achilles',   '';...
    'Springs',      'Axle2_Independent',                            'AClinA1_AClinA2';...
    'Dampers',      'Axle2_Independent',                            'AClinA1_AClinA2';...
    'Susp',         'DoubleWishbonePushUA_FSAE_Achilles_f',         'SuspA1';
    'Susp',         'DoubleWishbonePushUAnoSteer_FSAE_Achilles_r',  'SuspA2';
    'Steer',        'WheelDrivenRack1UJoint_Achilles',              'SuspA1';...
    'Steer',        'None_default',                                 'SuspA2';...
    'DriverHuman',  'None',                                         'SuspA1';...
    'AntiRollBar',  'DroplinkRod_FSAE_Achilles_f',                  'SuspA1';...
    'AntiRollBar',  'DroplinkRod_FSAE_Achilles_r',                  'SuspA2';...
    'Tire',         'MFSwift_Generic_190_50R10',                    'TireA1';
    'Tire',         'MFSwift_Generic_190_50R10',                    'TireA2';
    'TireDyn',      'steady',                                       'TireA1';
    'TireDyn',      'steady',                                       'TireA2';
    'Driveline',    'f1Dr1D_SHL',                                   ''};

Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Achilles_dwpua_MFSwift_steady_f1Dr1D';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 52: Sedan, MFeval, four wheel steering
veh_ind = veh_ind+1;
Vehicle = Vehicle_139;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DoubleWishbone_Sedan_Hamba_f','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Rack_Sedan_Hamba_r','SuspA2');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_4whlstr'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 53: Sedan, MFSwift, four wheel steering
veh_ind = veh_ind+1;
Vehicle = Vehicle_140;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DoubleWishbone_Sedan_Hamba_f','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Rack_Sedan_Hamba_r','SuspA2');

% Assemble configuration description in string
Vehicle.config = [vehcfg '_4whlstr'];

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 54: Sedan, MFeval, 2 Motor no cooling, four wheel steering
veh_ind = veh_ind+1;

Vehicle = Vehicle_166;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF2Mot_MFEval_steady_fCVpCVr1D_4whlstr';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 55: Sedan, MFSwift, 2 Motor no cooling, four wheel steering
veh_ind = veh_ind+1;

Vehicle = Vehicle_167;
vehcfg = Vehicle.config;

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_f','SuspA2');
Vehicle = sm_car_vehcfg_setSteer(Vehicle,'Ackermann_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

% Assemble configuration description in string
Vehicle.config = 'Hamba_15DOF2Mot_MFSwift_steady_fCVpCVr1D_4whlstr';

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 56: Sedan Hamba MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_140;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 57: Sedan Hamba MFMbody Live Axle
veh_ind = veh_ind+1;

Vehicle = Vehicle_159;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 58: Sedan Hamba MFMbody EMotor 2x
veh_ind = veh_ind+1;

Vehicle = Vehicle_161;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 59: Sedan Hamba MFMbody EMotor 3x
veh_ind = veh_ind+1;

Vehicle = Vehicle_163;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 60: Sedan Hamba MFMbody, 15DOF
veh_ind = veh_ind+1;

Vehicle = Vehicle_165;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 61: Sedan Hamba MFMbody, 15DOF E2x Cool
veh_ind = veh_ind+1;

Vehicle = Vehicle_167;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 62: Sedan Hamba MFMbody, 15DOF E3x Cool
veh_ind = veh_ind+1;

Vehicle = Vehicle_169;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 63: Sedan Hamba MFMbody, 15DOF Fuel Cell
veh_ind = veh_ind+1;

Vehicle = Vehicle_173;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 64: Sedan Hamba MFMbody, 15DOF E2x Reg
veh_ind = veh_ind+1;

Vehicle = Vehicle_180;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 65: FSAE Achilles MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_184;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_190_50R10','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_190_50R10','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 66: Makhulu 6whl MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_145;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Custom Configuration 67: Makhulu 4whl MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_146;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 68: Makhulu 6whl MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_177;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 69: Hamba 15DOF steady_f1dr1d_SHL MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_170;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 70: Hamba dwb steady ideal 4motor MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_182;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_213_40R21','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 71: Achilles DW Decoupled MFeval
veh_ind = veh_ind+1;

Vehicle = Vehicle_183;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DWDecoupled_Achilles_f','SuspA1');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DWDecoupledNoSteer_Achilles_r','SuspA2');
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Decoupled','ACdecLinA1_ACdecLinA2');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Decoupled','ACdecLinA1_ACdecLinA2');
Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,'None','SuspA1');
Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,'None','SuspA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'_dwpua','_dwdec');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 71: Achilles DW Decoupled MFSwift
veh_ind = veh_ind+1;

Vehicle = Vehicle_204;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFSwift_Generic_190_50R10','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFSwift_Generic_190_50R10','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFEval','MFSwift');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 72: FSAE Achilles MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_205;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_190_50R10','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_190_50R10','TireA2');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 73: Achilles FiveLink Decoupled MFeval
veh_ind = veh_ind+1;

Vehicle = Vehicle_204;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'L5Decoupled_Achilles_f','SuspA1');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'dwdec','5ldec');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 74: Achilles FiveLink Decoupled MFSwift
veh_ind = veh_ind+1;

Vehicle = Vehicle_205;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'L5Decoupled_Achilles_f','SuspA1');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'dwdec','5ldec');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Custom Configuration 75: Achilles FiveLink Decoupled MFMbody
veh_ind = veh_ind+1;

Vehicle = Vehicle_206;
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'L5Decoupled_Achilles_f','SuspA1');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'dwdec','5ldec');

% Save under Vehicle_###
veh_var_name = ['Vehicle_' pad(num2str(veh_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Return to main directory
curr_proj = simulinkproject;
cd(curr_proj.RootFolder)

