function [simOut, simInput, filename_ggv] = sm_car_sweep_ggv_pts(baseModelName,Vehicle,acc_theta_npts,veh_spd_vec,useParallel)
%sm_car_sweep_ggv_pts Produce a GGV diagram through a set of virtual tests
%   [simOut, simIn, filename_ggv] = sm_car_sweep_ggv_pts(baseModelName,Vehicle,
%                              acc_theta_npts,veh_spd_vec,useParallel)
%
%   This function runs a series of tests to obtain the points on the
%   surface of a GGV diagram.  
% 
%   You can specify:
%       baseModelName        Main model (usually sm_car)
%       Vehicle              Vehicle dataset
%       acc_theta_npts       Number of points around the friction circle
%       veh_spd_vec          Vector of vehicle speeds (drag and downforce)
%       useParallel          true for parsim, false for sim
%
% Example:
% [simOut, simInput, filename_ggv] = sm_car_sweep_ggv_pts('sm_car',Vehicle,4,[0 15 30],false);

% Copyright 2021 The MathWorks, Inc.

%% Model name
modelName     = [baseModelName '_test_ggv_new'];

%% Set up model
if(~bdIsLoaded(modelName))
    % If not loaded, open sm_car and resave
    % Model will be adjusted to accommodate parallel sweep
    open_system(baseModelName)
    save_system(baseModelName,modelName)
end

% Ensure Fast Restart is off so model can be properly configured
set_param(modelName,'FastRestart','off');

% Disable animation
set_param(modelName,'SimMechanicsOpenEditorOnUpdate','off');

% Remove PreLoadFcn and PostLoadFcn
% These will overwrite desired model configuration for GGV sweep
set_param(modelName,'PreLoadFcn','% PreLoadFcn Removed for GGV Sweep');
set_param(modelName,'PostLoadFcn','% PostLoadFcn Removed for GGV Sweep');

% Add annotation stating model has been modified
annotation_string = 'Model Modified for GGV Sweep';
add_block('built-in/Note',[modelName '/' annotation_string],...
    'FontSize',14,...
    'FontName','Arial',...
    'FontWeight','Bold',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'BackgroundColor','[1.000000, 0.796078, 0.800000]',...
    'Position',[492   345   700   373]);

% Configure model
sm_car_config_maneuver(modelName,'WOT Braking');
set_param([modelName '/Vehicle/Vehicle Constraint'],'LabelModeActiveChoice','NoYaw')
set_param([modelName '/World'],'popup_gravity','Ramp x and y components')
set_param([modelName '/Road/Input fWindCar'],...
    'fWind','[drag_frc 0 lift_frc]',...
    'tWind','10000',...
    'dWind','0');

% Ensure model is properly configured
sm_car_config_vehicle(modelName);

% Ensure Vehicle data structure has all required values
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

% Copy Vehicle data structure to a unique name in the workspace
% The workspace is copied to each worker.
Vehicle_GGV_Sweep = Vehicle;
assignin('base',"Vehicle_GGV_Sweep",Vehicle_GGV_Sweep)

%% Ensure simulation will run long enough
% Ensure we can reach around 3gs
accel_ramp_rate = 0.1;
assignin('base','accel_ramp_rate',accel_ramp_rate)
stop_time = 30/accel_ramp_rate;
set_param(modelName,'StopTime',num2str(stop_time));

%% Function to adjust settings for simulation
% Necessary for parsim and regular sim
% Use this function for both cases
sm_car_sweep_ggv_pts_presim(modelName, stop_time)

%% Define parameter sweep set

% Set of angles in x-y plane for acceleration
acc_theta_vec = linspace(0,2*pi,acc_theta_npts+1);      % Default 17, set lower for faster sweep
acc_theta_vec = acc_theta_vec(1:end-1);  % Do not repeat first point

% Set of vehicle speeds, used to calculate lift and drag forces
%veh_spd_vec   = linspace(0,42,6);        % Default 6, set lower for faster sweep

% Set of lift and drag forces
lift_frc_vec  = veh_spd_vec.*veh_spd_vec*...
    0.5*Vehicle.Chassis.Aero.rho_air.Value*Vehicle.Chassis.Aero.ARef.Value*Vehicle.Chassis.Aero.CL.Value;
drag_frc_vec  = sign(veh_spd_vec).*veh_spd_vec.*veh_spd_vec*...
    -0.5*Vehicle.Chassis.Aero.rho_air.Value*Vehicle.Chassis.Aero.ARef.Value*Vehicle.Chassis.Aero.CD.Value;

% Assign variables in base workspace so model can run interactively
assignin('base','acc_theta',acc_theta_vec(1));
assignin('base','lift_frc',lift_frc_vec(1));
assignin('base','drag_frc',drag_frc_vec(1));

% Number of simulations
nSims = length(acc_theta_vec)*length(veh_spd_vec);

%% Set up simulation input object
% Initialise empty Simulation Input Object
simInput =[];
simInput = Simulink.SimulationInput.empty(0,nSims);
iSim = 0;

for spd_i = 1:length(veh_spd_vec)
    for acc_i = 1:length(acc_theta_vec)
        iSim = iSim+1;
        % Define the model
        simInput(iSim) = Simulink.SimulationInput(modelName);
        % Define parameter values
        simInput(iSim) = simInput(iSim).setVariable('veh_spd',veh_spd_vec(spd_i));
        simInput(iSim) = simInput(iSim).setVariable('acc_theta',acc_theta_vec(acc_i));
        simInput(iSim) = simInput(iSim).setVariable('lift_frc',lift_frc_vec(spd_i));
        simInput(iSim) = simInput(iSim).setVariable('drag_frc',drag_frc_vec(spd_i));
        % Define model settings
        simInput(iSim) = simInput(iSim).setModelParameter('StopTime',num2str(stop_time));
        simInput(iSim) = simInput(iSim).setPreSimFcn(@(x) sm_car_sweep_ggv_pts_presim(modelName, stop_time));
    end
end

% Save before deploying for tests
save_system(modelName);

%% Run tests
simOut =[];

if (useParallel)
    simOut = parsim(simInput,'ShowSimulationManager','on',...
        'ShowProgress','off','UseFastRestart','on',...
        'TransferBaseWorkspaceVariables','on');
else
    simOut = sim(simInput,'ShowSimulationManager','on',...
        'ShowProgress','off','UseFastRestart','on');
end

vehicle_strs = strsplit(Vehicle.config,'_');
vehicle_name = vehicle_strs{1};

%% Get data for plots
acc_xy_tests = [ simOut.logsout_sm_car.get("accel_xy").Values];
acc_xy_res   = [];
acc_th_in = [];
vspd_in = [];
for iSim = 1:nSims
    acc_xy_res(iSim) = acc_xy_tests(iSim).Data(end);
    vspd_in(iSim)    = simInput(iSim).Variables(1).Value;
    acc_th_in(iSim)  = simInput(iSim).Variables(2).Value;
end

GGV_data.lat_acc_pts_g   =  sin(acc_th_in).*acc_xy_res/9.81;
GGV_data.lng_acc_pts_g   = -cos(acc_th_in).*acc_xy_res/9.81;
GGV_data.veh_spd_pts_mps = vspd_in;
GGV_data.veh_spd_vec     = veh_spd_vec;
GGV_data.acc_theta_vec   = acc_theta_vec;
GGV_data.vehicle_config  = Vehicle.config;
assignin('base','GGV_data',GGV_data)
%% Plot GGV diagram
fig_h_ggv = sm_car_plot_ggv_surf(GGV_data);

%% Save results to a file
date_str = strrep(strrep(strrep( ...
    simOut(end).SimulationMetadata.TimingInfo.WallClockTimestampStop,...
    '-',''),':',''),' ','_');

filename_ggv = ['GGV_' vehicle_name '_' date_str(1:end-2)];
saveas(fig_h_ggv,filename_ggv)
save(filename_ggv,'GGV_data');

%% Reset model
set_param(modelName,'FastRestart','off')
set_param(modelName,'SimMechanicsOpenEditorOnUpdate','on');
