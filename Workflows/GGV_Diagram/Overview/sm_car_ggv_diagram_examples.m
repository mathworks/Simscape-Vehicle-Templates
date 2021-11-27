%% GGV Diagram Generation from Virtual Tests
% 
% The commands below run a series of simulations on a full vehicle model to
% generate a GGV diagram.  For each test, 
% 
% * The vehicle is resting on a flat surface with the brakes applied
% * The vehicle is constrained so that it cannot yaw
% * A downforce and drag force are applied consistent with a given vehicle
% speed
% * The x- and y- components of the gravity vector are gradually increased
% until the vehicle starts to slide across the ground
% 
% Sets of points are collected around the friction circle in the xy-plane
% and at different vehicle speeds.  Plotting these points on a surface
% creates the GGV diagram.  This diagram is normally produced for
% quasi-steady state behavior.  These tests can be run sequentially or in
% parallel.
%
% Copyright 2018-2021 The MathWorks, Inc.

%% Open model

%% Generate GGV Diagram for Sedan
if verLessThan('matlab', '9.11')
    load Vehicle_139
    Vehicle = Vehicle_139;
else
    load Vehicle_189
    Vehicle = Vehicle_189;
end
[simOut, simInput, filename_ggv1] = sm_car_sweep_ggv_pts('sm_car',Vehicle,16,linspace(0,40,6),false);

%% Generate GGV Diagram for Formula Student Vehicle
if verLessThan('matlab', '9.11')
    load Vehicle_183
    Vehicle = Vehicle_183;
else
    load Vehicle_198
    Vehicle = Vehicle_198;
end
[simOut, simInput, filename_ggv2] = sm_car_sweep_ggv_pts('sm_car',Vehicle,16,linspace(0,40,6),false);

%% Compare GGV Diagrams on the same plot
load(filename_ggv1);
GGV_data1 = GGV_data;
load(filename_ggv2);
GGV_data2 = GGV_data;

clr_order = [...
        0         0.4470    0.7410;
        0.8500    0.3250    0.0980];
fig_h = sm_car_plot_ggv_surf(GGV_data1,false,clr_order(1,:));
fig_h = sm_car_plot_ggv_surf(GGV_data2,true,clr_order(2,:));
legend({'Sedan','FSAE'},'Location','Best')
