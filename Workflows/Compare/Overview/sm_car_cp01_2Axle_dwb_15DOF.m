%% Compare Tire Forces for Double Wishbone and Abstract Suspensions
% 
% The commands below run the two simulations and compare the resulting tire
% forces. The code below can be modified to perform other comparisons.
%
% Copyright 2018-2021 The MathWorks, Inc.

%% Run Comparison
sm_car_run_two_sims('sm_car','Double Lane Change','DoubleWish','139','none','15DOF','164','none');

%% Compare Normal Force
sm_car_plot11_compare_tire_force_torque('DoubleWish', log_A_DoubleWish, '15DOF', log_B_15DOF, 'var','Fz', 'vehicle','Double Lane Change')

%% Compare Lateral Force
sm_car_plot11_compare_tire_force_torque('DoubleWish', log_A_DoubleWish, '15DOF', log_B_15DOF, 'var','Fy', 'vehicle','Double Lane Change')

%% Compare Forces and Torques for Left Front Wheel
sm_car_plot11_compare_tire_force_torque('DoubleWish', log_A_DoubleWish, '15DOF', log_B_15DOF, 'wheel', 'WhlL1', 'vehicle','Double Lane Change')

%%
close all



