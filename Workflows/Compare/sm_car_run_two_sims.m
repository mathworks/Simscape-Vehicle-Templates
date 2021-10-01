function sm_car_run_two_sims(mdl, eventName, nameA, vehPresetA, trlPresetA, nameB, vehPresetB, trlPresetB)
%sm_car_run_two_sims  Run two simulations and plot tire forces and torques
%  sm_car_run_two_sims(mdl, eventName, nameA, vehPresetA, trlPresetA, nameB, vehPresetB, trlPresetB)
%  You must specify:
%    mdl         Model name
%    eventName   Name of event you wish to run ('WOT Braking', 'Double Lane Change', ...)
%                See sm_car_config_maneuver for list
%    nameA       String with name of first configuration, used in plot legend
%    vehPresetA  String with name of vehicle preset for test ('139', 'Axle3_006', ...)
%                For use with sm_car_load_vehicle()
%    trlPresetA  String with name of trailer preset for test ('none', '001', ...)
%                For use with sm_car_load_trailer()
%    nameB       String with name of second configuration
%    vehPresetB  String with name of vehicle preset for test
%    trlPresetB  String with name of trailer preset for test
%                For use with sm_car_load_trailer()
%
% Copyright 2021 The MathWorks, Inc.

% Load and run configuration 1
open_system(mdl)
sm_car_load_vehicle_data(mdl,vehPresetA);
sm_car_load_trailer_data(mdl,trlPresetA);
sm_car_config_maneuver(mdl,eventName);
sm_car_config_vehicle(mdl);
sim(mdl)

% Extract relevant data
logsout_A = logsout_sm_car;
assignin('base',matlab.lang.makeValidName(['log_A_' nameA]),logsout_A);

% Load and run configuration 2
sm_car_load_vehicle_data(mdl,vehPresetB);
sm_car_load_trailer_data(mdl,trlPresetB);
sm_car_config_maneuver(mdl,eventName);
sm_car_config_vehicle(mdl);
sim(mdl)

% Extract relevant data
logsout_B = logsout_sm_car;
assignin('base',matlab.lang.makeValidName(['log_B_' nameB]),logsout_B);


