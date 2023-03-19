%% Full Vehicle with Multibody Suspension
%
% This example uses the Simscape Vehicle Templates to model and simulate
% vehicles using Simscape products.  This includes one-axle, two-axle,
% multi-axle and trailers.  It includes a highly configurable vehicle model
% that is integrated with controllers and other content from other
% MathWorks products. A modular library of components gives users a great
% starting point for creating custom vehicle models
%
% Copyright 2018-2023 The MathWorks, Inc.


%% Model
open_system('sm_car')
load Vehicle_160
Vehicle = Vehicle_160;
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Liquid_Loop1');
sm_car_config_vehicle('sm_car')

ann_h = find_system('sm_car','FindAll', 'on','type','annotation','Tag','ModelFeatures');
for i=1:length(ann_h)
    set_param(ann_h(i),'Interpreter','off');
end

%%
% <<sm_car_mechExp_Sedan_PikesPeakUp.png>>

%% Car Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle','force'); Open Subsystem>

set_param('sm_car/Vehicle','LinkStatus','none')
open_system('sm_car/Vehicle','force')

%% Chassis Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis','force')

%% Suspension, Front Axle Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1','force')

%% Suspension, Front Axle, Linkage Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage','force')

%% Suspension, Front Axle, Linkage L Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage%20L','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L','force')

%% Suspension, Double Wishbone Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage%20L/DoubleWishbone','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L/DoubleWishbone','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L/DoubleWishbone','force')

%% Steer Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer','force')

%% Steer Rack Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer/Rack','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer/Rack','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Steer/Rack','force')


%% Brakes Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Brakes','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes','force')

%% Brakes, Pedal Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/Pedal','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Brakes/PedalAbstract DiscDisc','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/PedalAbstract DiscDisc','force')

%% Brakes, ABS 4 Channel Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/ABS%204%20Channel','force'); Open Subsystem>

%load Vehicle_130
%Vehicle = Vehicle_130;
%sm_car_config_vehicle('sm_car')

set_param('sm_car/Vehicle/Vehicle/Brakes/HydraulicValves Channel4','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/HydraulicValves Channel4','force')

%% Brakes, ABS 4 Channel Valves Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/ABS%204%20Channel/Valves','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Brakes/HydraulicValves Channel4/Valves','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/HydraulicValves Channel4/Valves','force')


%% Tire L1 Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/Tire%L1/MFEval','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Chassis/Tire L1/MFEval','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/Tire L1/MFEval','force')

%% Powertrain Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')

%% Driveline, Two Powered Shafts Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Driveline/A1%20A2%20A1Diff%20A2Diff','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Driveline/A1 A2 A1Diff A2Diff','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Driveline/A1 A2 A1Diff A2Diff','force')


%% Power, Electric Two Motors Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric%20A1%20A2,'force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric A1 A2','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric A1 A2','force')

%% Power, Cooling System Two Motors Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric%20A1%20A2/Thermal/Liquid%20Loop1,'force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric A1 A2/Thermal/Liquid Loop1','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric A1 A2/Thermal/Liquid Loop1','force')


%% Simulation Results from Simscape Logging
%%
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%

bdclose('sm_car')
load_system('sm_car')
load Vehicle_000
Vehicle = Vehicle_000;
sm_car_config_vehicle('sm_car')

warning('off','Solver61:CoeffChecks:Eyk')
warning('off','Solver61:Limits:Exceeded')
warning('off','Solver61:CoeffChecks:Et')

%% Full Throttle, Braking, MFEval Tires
% 
sm_car_config_maneuver('sm_car','WOT Braking');

sim('sm_car')
sm_car_plot1speed;
sm_car_plot2whlspeed

%% Front Steering, Sequence Steer, Step Torque, MFEval Tires
% 
sm_car_config_maneuver('sm_car','Low Speed Steer');

sim('sm_car')
sm_car_plot1speed;
sm_car_plot2whlspeed


%% Double-Lane Change, MFEval Tires
%

sm_car_config_maneuver('sm_car','Double Lane Change');

sim('sm_car')
sm_car_plot1speed;
sm_car_plot3maneuver(Maneuver,logsout_sm_car)

%%

%clear all
close all
bdclose all
warning('on','Solver61:CoeffChecks:Eyk')
warning('on','Solver61:Limits:Exceeded')
warning('on','Solver61:CoeffChecks:Et')

