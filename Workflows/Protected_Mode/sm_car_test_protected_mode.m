% Test tuning parameters in Model Reference Protected Mode
% Copyright 2022 The MathWorks, Inc.

% Move to folder where code is located
cd(fileparts(which(mfilename)));

%% Open model in test configuration

orig_mdl = 'sm_car';
mdl = [orig_mdl '_protected'];
refmdl = 'Vehicle_sys';
refsys = [mdl '/' refmdl];
open_system(orig_mdl);

% Select vehicle
sm_car_load_vehicle_data('sm_car','002'); % DW Front Rear MFeval
%sm_car_load_vehicle_data('sm_car','189'); % DW Front Rear MFMBody
%sm_car_load_vehicle_data('sm_car','032'); % Split to LAF
%sm_car_load_vehicle_data('sm_car','056'); % Split to LAR
%sm_car_load_vehicle_data('sm_car','072'); % 5Link to LAF
%sm_car_load_vehicle_data('sm_car','088'); % 5Link to LAR
%sm_car_load_vehicle_data('sm_car','104'); % 5Link to LAF Constr

% Run these commands as well to set abstract rear suspension
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_HambaLG_r','SuspA2');

% Run these commands as well to rear tires to MFMBody (R21b and higher)
if(~verLessThan('matlab','9.11'))
    Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_235_50R24','TireA1');
    Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_235_50R24','TireA2');
end

% FSAE
%sm_car_load_vehicle_data('sm_car','198'); % FSAE DW Pushrod
%sm_car_load_vehicle_data('sm_car','206'); % FSAE DW Decoupled  (code gen fast)
%sm_car_load_vehicle_data('sm_car','209'); % FSAE 5Link Decoupled

sm_car_config_maneuver('sm_car','WOT Braking');
sm_car_config_vehicle(bdroot);

%% Save under new name
save_system(orig_mdl,mdl);
set_param(mdl,'SimscapeLogType','none');
save_system(mdl);

%% Modify Init parameter structure so value scan be tuned.

% Reload from database
Init = IDatabase.Flat.Sedan_Hamba;
Init_tune = Init;
clear Init

% Remove fields that are strings
Init_tune = rmfield(Init_tune,{'Instance','Type'});
Init_tune.Chassis.aChassis = rmfield(Init_tune.Chassis.aChassis,{'Units','Comments'});
Init_tune.Chassis.sChassis = rmfield(Init_tune.Chassis.sChassis,{'Units','Comments'});
Init_tune.Chassis.vChassis = rmfield(Init_tune.Chassis.vChassis,{'Units','Comments'});

Init_tune.Axle1.nWheel = rmfield(Init_tune.Axle1.nWheel,{'Units','Comments'});
Init_tune.Axle2.nWheel = rmfield(Init_tune.Axle2.nWheel,{'Units','Comments'});

Init = Simulink.Parameter(Init_tune);

Init.CoderInfo.StorageClass = 'SimulinkGlobal';

%% Set up model to create Model Reference
% Turn off logging
ph = get_param([mdl '/Vehicle'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging','off',...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','TrlBus');

set_param(ph.Outport(2),...
    'DataLogging','off',...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','VehBus');


%% Create subsystem to be protected
bh(1) = get_param([mdl '/Vehicle'],'Handle');
bh(2) = get_param([mdl '/World'],'Handle');
bh(3) = get_param([mdl '/Camera Frames'],'Handle');
Simulink.BlockDiagram.createSubSystem(bh);

set_param([mdl '/Subsystem'],...
    'Name',refmdl);

%% Create Reference Model
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off')
set_param(refsys,'TreatAsAtomicUnit','on');
warning('off','Simulink:protectedModel:ProtectedModelCallbackLostWarning')
if(verLessThan('matlab','9.8'))
    Simulink.SubSystem.convertToModelReference(...
        refsys,refmdl, ...
        'AutoFix',true,...
        'ReplaceSubsystem',true);
else
    % Starting in R2020a
    Simulink.SubSystem.convertToModelReference(...
        refsys,refmdl, ...
        'AutoFix',true,...
        'ReplaceSubsystem',true,...
        'CreateBusObjectsForAllBuses',true);
end
%% Configure Reference Model
open_system(refmdl);
set_param(refmdl,'SimscapeLogType','none');
set_param(refmdl,'ModelReferenceNumInstancesAllowed','single');
set_param(refmdl,'SimMechanicsOpenEditorOnUpdate','off')
save_system(refmdl);

%% Create and reference protected model
if(verLessThan('matlab','9.12'))
[harnessHandle, neededVars] = ...
    Simulink.ModelReference.protect(refmdl,...
    'Harness', false,...
    'Webview',false);
else
    % Starting R2022a, must specify tunable parameters
    [harnessHandle, neededVars] = ...
    Simulink.ModelReference.protect(refmdl,...
    'Harness', false,...
    'Webview',false,...
    'TunableParameters', {'Init'});
end
set_param(refsys,'ModelName',[refmdl '.slxp']);
bdclose(refmdl);

%% Enable logging
ph = get_param([mdl '/' refmdl],'PortHandles');
set_param(ph.Outport(3),...
    'DataLogging','on',...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','VehBus');

%% Adjust location of block
set_param([mdl '/' refmdl],'Position',[405    35   540   105])

%% Once model is protected, this section can be run by itself 
%  as long as model <mdl> with protected system is open.

% Test with two maneuvers
% Note - for releases earlier than R2020a, initial conditions
%        are likely not tunable in this protected model.

% WOT Braking
Init.Value.Chassis.sChassis.Value = IDatabase.Flat.Sedan_Hamba.Chassis.sChassis.Value;
Maneuver = MDatabase.WOT_Braking.Sedan_Hamba;
set_param([mdl '/Driver'],'popup_driver_type','Open Loop');
set_param(mdl,'StopTime','40');

sim(mdl)
sm_car_test_protected_mode_plot1speed
saveas(gcf,'MRPM_Test_WOTBraking.png')
%logsout_VehBus = logsout_sm_car.get('VehBus');
%logsout_xCar = logsout_VehBus.Values.World.x;
%logsout_px0_t1 = logsout_xCar.Data(1);
%disp(['Initial position global x, test 1: ' num2str(logsout_px0_t1)])

% Double-Lane Change
Init.Value.Chassis.sChassis.Value = IDatabase.Double_Lane_Change.Sedan_Hamba.Chassis.sChassis.Value;
Maneuver = MDatabase.Double_Lane_Change.Sedan_Hamba;
set_param([mdl '/Driver'],'popup_driver_type','Closed Loop');
Driver = DDatabase.Double_Lane_Change.Sedan_Hamba;
set_param(mdl,'StopTime','35');

sim(mdl)
sm_car_test_protected_mode_plot1speed
saveas(gcf,'MRPM_Test_DoubleLaneChange.png')
%logsout_VehBus = logsout_sm_car.get('VehBus');
%logsout_xCar = logsout_VehBus.Values.World.x;
%logsout_px0_t2 = logsout_xCar.Data(1);
%disp(['Initial position global x, test 1: ' num2str(logsout_px0_t2)])
