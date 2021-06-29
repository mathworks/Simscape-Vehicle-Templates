% Script to test anti-lock braking algorithm

% Copyright 2019-2021 The MathWorks, Inc

% Test Torque Vectoring 
open_system('sm_car');

out_abs_test = sm_car_test_abs_function('hamba');
simlog_sm_car = out_abs_test.get('simlog_sm_car');
logsout_sm_car = out_abs_test.get('logsout_sm_car');

% Plot Results
sm_car_plot6press1plot
sm_car_plot9pressws


