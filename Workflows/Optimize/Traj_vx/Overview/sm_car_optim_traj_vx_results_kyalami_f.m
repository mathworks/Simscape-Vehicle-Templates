%% Minimize Lap Time Using Optimization, Kyalami (No Elevation Change)
% 
% This example shows how to minimize lap times using optimization
% algorithms using the Kyalami Grand Prix Circuit. This optimization
% assumes no elevation to shorten the optimization process.
% 
% Copyright 2020 The MathWorks, Inc.

%% 
% <html><h2>Results of Optimization</h2></html>
Overview_Dir = pwd;
cd(Overview_Dir)
close all
clear OptRes_*
clear opt_iter

open_system('sm_car');
set_param(bdroot,'FastRestart','off');
sm_car_load_vehicle_data('sm_car','164'); % (Flat roads, basic)
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

sm_car_optim_traj_vx('CRG_Kyalami_f',25);
sm_car_optim_vx_plot(OptRes_CRG_Kyalami_f)

cd(Overview_Dir)
close(3)
close(4)
close(5)
close(6)
close(7)

%%
%clear all
close all
%bdclose all