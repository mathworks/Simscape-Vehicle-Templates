%% Minimize Lap Time Using Optimization, Overview
% 
% This example shows how to minimize lap times using optimization
% algorithms.  This optimization adjusts three parameters that scale the
% target vehicle speed which depends on the curvature of the road.
% 
% Copyright 2020-2022 The MathWorks, Inc.

%% Simulation Model

open_system('sm_car');
set_param(find_system('sm_car','FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Results
%
% <matlab:web('sm_car_optim_traj_vx_results_mallory_park.html'); Mallory Park (No Elevation Change)>
%
% <matlab:web('sm_car_optim_traj_vx_results_kyalami_f.html'); Kyalami Grand Prix (No Elevation Change)>
%
% <matlab:web('sm_car_optim_traj_vx_results_nurburgring_f.html'); Nurburgring Nordschleife (No Elevation Change)>
%
% <matlab:web('sm_car_optim_traj_vx_results_suzuka_f.html'); Suzuka Circuit (No Elevation Change)>
