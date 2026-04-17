%% Test Power + Driveline Combinations
%
% This simple script tests a number of powertrain configurations. The
% wide-open throttle and braking test shows which axles are powered as
% those wheel speeds will be faster.
%
% Copyright 2018-2026 The MathWorks, Inc.

%%
load_system('sm_car')

sm_car_load_vehicle_data('sm_car_Axle3','191');
set_param('sm_car/Controller','popup_control','Default');
sm_car_config_maneuver('sm_car','WOT Braking');

% Check if we are publishing
isBeingPublished = any(strcmp('publish', {dbstack().name}));

%% A1 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_A1_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L1 R1 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A2 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D2_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L2 R2 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S2_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A1 A2 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_A1_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1D2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A1 L2 R2 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_A1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1S2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed


%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L1 R1 L2 R2 Ideal
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A1 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L1 R1 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_L1_R1_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A2 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D2_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L2 R2 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S2_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% A1 L2 R2 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_A1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1S2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% L1 R1 L2 R2 Electric
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
sim('sm_car')
sm_car_plot2whlspeed

%%
% Only close and reopen model if publishing example doc
resetModel(isBeingPublished)

%% None
Vehicle = sm_car_vehcfg_setPower(Vehicle,'None');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
open_system('sm_car/Vehicle/Vehicle/Powertrain','force')
set_param('sm_car','SimulationCommand','update')

%%
bdclose all
close all

function resetModel(isBeingPublished)
% In some releases, to capture a screenshot when publishing of the
% powertrain subsystems (power and driveline) we need to close the entire
% model and reload it. If we are not publishing, closing/reloading is not
% necessary.  Only close the model and reopen if publishing.
if(isBeingPublished)
    bdclose('sm_car')
    load_system('sm_car')
    sm_car_load_vehicle_data('sm_car_Axle3','191');
    set_param('sm_car/Controller','popup_control','Default');
    sm_car_config_maneuver('sm_car','WOT Braking');
end

end
