%% Full Vehicle with Multibody Suspension
%
% This example uses the Simscape Vehicle Templates to model and simulate
% vehicles using Simscape products.  This includes one-axle, two-axle,
% multi-axle and trailers.  It includes a highly configurable vehicle model
% that is integrated with controllers and other content from other
% MathWorks products. A modular library of components gives users a great
% starting point for creating custom vehicle models
%
% Copyright 2018-2022 The MathWorks, Inc.


%% Model
open_system('sm_car')
load Vehicle_160
Vehicle = Vehicle_160;
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');
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
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF','force')

%% Suspension, Front Axle, Linkage Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage','force')

%% Suspension, Front Axle, Linkage L Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage%20L','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage L','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage L','force')

%% Suspension, Double Wishbone Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage%20L/DoubleWishbone','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage L/DoubleWishbone','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Linkage L/DoubleWishbone','force')

%% Steer Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer','force')

%% Steer Rack Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer/Rack','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer/Rack','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/SuspF/Linkage/Steer/Rack','force')


%% Brakes Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Brakes','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes','force')

%% Brakes, Pedal Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/Pedal','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Brakes/Pedal','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/Pedal','force')

%% Brakes, ABS 4 Channel Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/ABS%204%20Channel','force'); Open Subsystem>

%load Vehicle_130
%Vehicle = Vehicle_130;
%sm_car_config_vehicle('sm_car')

set_param('sm_car/Vehicle/Vehicle/Brakes/ABS 4 Channel','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/ABS 4 Channel','force')

%% Brakes, ABS 4 Channel Valves Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Brakes/ABS%204%20Channel/Valves','force'); Open Subsystem>

set_param('sm_car/Vehicle/Vehicle/Brakes/ABS 4 Channel/Valves','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Brakes/ABS 4 Channel/Valves','force')


%% Tire FL Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Chassis/Tire%FL/MFEval','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Chassis/Tire FL/MFEval','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Chassis/Tire FL/MFEval','force')

%% Powertrain Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')

%% Driveline, Two Powered Shafts Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Driveline/IndepFRDiffFDiffR','force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Driveline/IndepFRDiffFDiffR','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Driveline/IndepFRDiffFDiffR','force')


%% Power, Electric Two Motors Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor,'force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor','force')

%% Power, Cooling System Two Motors Subsystem
%
% <matlab:open_system('sm_car');open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor/Thermal/Active%201%20Loop,'force'); Open Subsystem>

%set_param('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor/Thermal/Active 1 Loop','LinkStatus','none')
open_system('sm_car/Vehicle/Vehicle/Powertrain/Power/Electric2Motor/Thermal/Active 1 Loop','force')


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

