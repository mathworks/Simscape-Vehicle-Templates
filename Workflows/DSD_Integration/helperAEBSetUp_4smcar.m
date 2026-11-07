function helperAEBSetUp_4smcar(varargin)
% Set up and Run Model Script for the Autonomous Emergency Brake (AEB) Example
%
% This script initializes the AEB example model. It loads necessary control
% constants and sets up the buses required for the referenced model
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2018-2024 The MathWorks, Inc.

% To clean up setup values from workspace, call:
%   >> helperAEBSetUp(true)
persistent origPath origFigs origVars origAns
if isempty(origPath)
    origPath = path();
    origFigs = findobj('type','figure');
    origVars = evalin('base','whos');
    if evalin('base',"exist('ans','var')")
        origAns = evalin('base','ans');
    end
end
if nargin && ~(ischar(varargin{1}) || isstring(varargin{1})) && varargin{1}
    helperAEBCleanUp(origPath,origFigs,origVars,origAns);
    origPath = [];
    origFigs = [];
    origVars = [];
    origAns = [];
    return
end

%% General Model parameters
% This sample time is used across the model
% and should not be modified
SimParams.Ts = 0.1;               % Simulation sample time  (s)

%% Add library of Prebuilt Scenarios to MATLAB path
Path = fullfile(matlabroot,'toolbox','shared','drivingscenario', ...
    'PrebuiltScenarios', 'EuroNCAP', 'AutonomousEmergencyBraking');
addpath(genpath(Path)); % put scenario on path 

%% Create driving scenario
% The scenario name is a scenario function created by the Driving Scenario Designer App. 
defaultScenarioFcnName = 'AEB_PedestrianChild_Nearside_50width_overrun';
validScenarioFcnNames = {                              
    'AEB_CCRs_100overlap',...                           % scenarioID = 1
    'AEB_CCRm_100overlap',...                           % scenarioID = 2
    'AEB_CCRb_2_initialGap_12m_stop_inf',...            % scenarioID = 3
    'AEB_CCRb_6_initialGap_40m_stop_inf',...            % scenarioID = 4   
    'AEB_PedestrianChild_Nearside_50width_overrun'};    % scenarioID = 5
    
% Parse input
checkScenarioFncName = @(x) any(strcmp(x,validScenarioFcnNames));
p = inputParser;
addOptional(p,'ScenarioFcnName',defaultScenarioFcnName,checkScenarioFncName);
parse(p,varargin{:});
scenarioFcnName = p.Results.ScenarioFcnName;
scenarioID = find(strcmp(scenarioFcnName,validScenarioFcnNames));

if scenarioID == 5 
    SimParams.bep_xRange = [0, 30]; % x, y ranges of bird's-eye plot
    SimParams.bep_yRange = [-10,10];
    SimParams.simStopTime = 5;   % simulation stop time (sec)
else
    SimParams.bep_xRange = [0, 60];
    SimParams.bep_yRange = [-20,20];
    SimParams.simStopTime = 9;   % simulation stop time (sec)
end

% Call scenario function to create drivingScenario and egoVehicle objects,
% and assign scenario object in base workspace
scenarioFcnHandle = str2func(scenarioFcnName);
[scenario, egoVehicle] = scenarioFcnHandle();
assignin('base','scenario',scenario);
disp(['Scenario ''' scenarioFcnName ''' loaded.']);

%Get ego vehicle ActorID for use in scenario reader block
SimParams.egoActorID = egoVehicle.ActorID;

%Define actor profiles
SimParams.actor_Profiles = actorProfiles(scenario);

%Define path curvature and set velocity
SimParams.K = 0;                            % curvature = 0 (straight path)
SimParams.v_set = norm(egoVehicle.Velocity);  % set ego velocity (m/s)

%Assign SimParams struct in base workspace
assignin('base','SimParams',SimParams);

%% Initial conditions for the ego car
EgoCarParams.v0_ego   = SimParams.v_set - 1;           % Initial speed of the ego car           (m/s)
EgoCarParams.x0_ego   = egoVehicle.Position(1);           % Initial x position of ego car          (m)
EgoCarParams.y0_ego   = egoVehicle.Position(2);           % Initial y position of ego car          (m)
EgoCarParams.yaw0_ego = deg2rad(egoVehicle.Yaw);         % Initial yaw angle of ego car           (rad)

%% FCW parameters
FCW.timeToReact  = 1.2;         % driver reaction time                   (sec)
FCW.driver_decel = 4.0;         % driver braking deceleration            (m/s^2)

%Assign FCW struct in base workspace
assignin('base','FCW',FCW);

%% AEB controller parameters
AEB.PB1_decel = 3.8;            % 1st stage Partial Braking deceleration (m/s^2)
AEB.PB2_decel = 5.3;            % 2nd stage Partial Braking deceleration (m/s^2)
AEB.FB_decel  = 9.8;            % Full Braking deceleration              (m/s^2)
AEB.headwayOffset = 3.7;        % headway offset                         (m)
AEB.timeMargin = 0;             % headway time margin                    (sec)

%Assign AEB struct in base workspace
assignin('base','AEB',AEB);

%% Tracking and Sensor Fusion Parameters                        Units
TrackingParams.clusterSize = 4;        % Distance for clustering               (m)
TrackingParams.assigThresh = 50;       % Tracker assignment threshold          (N/A)
TrackingParams.M           = 2;        % Tracker M value for M-out-of-N logic  (N/A)
TrackingParams.N           = 3;        % Tracker M value for M-out-of-N logic  (N/A)
TrackingParams.numCoasts   = 3;        % Number of track coasting steps        (N/A)
TrackingParams.numTracks   = 20;       % Maximum number of tracks              (N/A)
TrackingParams.numSensors  = 2;        % Maximum number of sensors             (N/A)

% Position and velocity selectors from track state
% The filter initialization function used in this example is initcvekf that 
% defines a state that is: [x;vx;y;vy;z;vz]. 
TrackingParams.posSelector = [1,0,0,0,0,0; 0,0,1,0,0,0]; % Position selector   (N/A)
TrackingParams.velSelector = [0,1,0,0,0,0; 0,0,0,1,0,0]; % Velocity selector   (N/A)

%Assign TrackingParams struct in base workspace
assignin('base','TrackingParams',TrackingParams);

%% Ego Car Parameters
% Dynamics modeling parameters
EgoCarParams.m       = 1575;     % Total mass of vehicle                          (kg)
EgoCarParams.Iz      = 2875;     % Yaw moment of inertia of vehicle               (m*N*s^2)
EgoCarParams.lf      = 1.2;      % Longitudinal distance from c.g. to front tires (m)
EgoCarParams.lr      = 1.6;      % Longitudinal distance from c.g. to rear tires  (m)
EgoCarParams.Cf      = 19000;    % Cornering stiffness of front tires             (N/rad)
EgoCarParams.Cr      = 33000;    % Cornering stiffness of rear tires              (N/rad)
EgoCarParams.tau1     = 0.5;     % Longitudinal time constant (throttle)          (N/A)
EgoCarParams.tau2     = 0.07;    % Longitudinal time constant (brake)             (N/A)

%Assign EgoCarParams struct in base workspace
assignin('base','EgoCarParams',EgoCarParams);

%% Speed Controller Parameters
SpeedController.Kp = 1.1;           % Proportional Gain of speed controller
SpeedController.Ki = 0.1;           % Integral Gain of speed controller
SpeedController.Amax = 3;           % Maximum acceleration                  (m/s^2)
SpeedController.Amin = -3;          % Minimum acceleration                  (m/s^2)
SpeedController.Kd = 0;
SpeedController.FilterCoeff = 0;

%Assign SpeedController struct in base workspace
assignin('base','SpeedController',SpeedController);

%% Driver steering control paramaters
SteeringController.Kp         = 0.2;  % Proportional gain                     (N/A)
SteeringController.Ki         = 0.1;  % Integral gain                         (N/A)
SteeringController.yawErrGain = 2;    % Yaw error gain                        (N/A)

%Assign SteeringController struct in base workspace
assignin('base','SteeringController',SteeringController);

%% Bus Creation
% clear BusActors bus if it exists
if exist('BusActors','var')
    clear BusActors
    clear BusActorsActors
end

% Load main test bench model
modelName = 'sm_car_Axle3_withDSD';
wasModelLoaded = bdIsLoaded(modelName);
if ~wasModelLoaded
    load_system(modelName)
end

% Create bus for scenario reader block
evalin('base','createBusScenarioReader');

%Create buses for detections (Input to the referenced model)
%blk=find_system(modelName,'System','visionDetectionGenerator');
%visionDetectionGenerator.createBus(blk{1});
%blk=find_system(modelName,'System','drivingRadarDataGenerator');
%drivingRadarDataGenerator.createBus(blk{1});

% Create the bus of tracks (output from referenced model)
%{
refModel = 'AEBWithSensorFusionMdlRef';
wasReModelLoaded = bdIsLoaded(refModel);
if ~wasReModelLoaded
    load_system(refModel)
    blk=find_system(refModel,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
    close_system(refModel)
else
    blk=find_system(refModel,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
end

if ~wasModelLoaded
    close_system(modelName)
end
%}

%% Code generation
% Uncomment this if you would like to generate code.
% rtwbuild(refModel);

function helperAEBCleanUp(origPath,origFigs,origVars,origAns)
path(origPath);

newFigs = setdiff(findobj('type','figure'),origFigs);
close(newFigs);

newVars = evalin('base','whos');
newVars = setdiff({newVars.name},{origVars.name});
if ~isempty(newVars)
    evalin('base',['clear ' strjoin(newVars)]);
end

if ~isempty(origAns)
    assignin('base','ans',origAns);
end
