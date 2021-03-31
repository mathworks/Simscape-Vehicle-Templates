%% Minimize Lap Time Considering Regeneration Using Optimization, Nurburgring Nordschleife (No Elevation Change)
% 
% This example shows how to minimize lap times using optimization
% algorithms using the Nurburgring Nordschleife.  This optimization
% assumes no elevation to shorten the optimization process.  The cost
% function considers the loss in battery state of charge to factor in
% vehicle range to the optimization.
% 
% Copyright 2020-2021 The MathWorks, Inc.

%%
% <html><h2>Results of Optimization</h2></html>
Overview_Dir = pwd;
cd(Overview_Dir)
close all
clear OptRes_*
clear opt_iter

mdl = 'sm_car';
open_system(mdl);
set_param(mdl,'FastRestart','off');

sm_car_load_vehicle_data(mdl,'179'); % (MFeval, flat roads, basic)
%sm_car_load_vehicle_data(mdl,'180'); % (MF-Swift)
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

% Important to so that max regen takes place
Vehicle.Powertrain.Power.Battery.SOCInit.Value = 0.5;

sm_car_optim_traj_vx(mdl,'CRG_Nurburgring_N_f',25);
sm_car_optim_traj_vx_regen_plot(OptRes_CRG_Nurburgring_N_f)

cd(Overview_Dir)
close(3)
close(4)
close(5)
close(6)
close(7)
close(8)
close(9)

%%
%clear all
close all
%bdclose all