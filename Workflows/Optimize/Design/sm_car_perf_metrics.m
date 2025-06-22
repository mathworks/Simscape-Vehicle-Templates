function [CarMetrics,time,simRes] = sm_car_perf_metrics(logsout,simlog,Vehicle,showplot,calcMetrics,debugPlots)
%sm_car_perf_metrics  Obtain performance metrics from full vehicle test
%   [CarMetrics] = sm_car_perf_metrics(logsout,showplot,calcMetrics,debugPlots)
%   This function extracts specific measurements from suspension
%   simulations for suspension metric calculations and plots. 
%       logsout      Results from suspension simulation
%       showplot     true to plot toe and camber curves
%       calcMetrics  true to calculate suspension metrics
%       debugPlots   true to create plots detailing suspension metric calculations
%
%   Outputs:
%       CarMetrics  Table of suspension metrics from KnC test
%       time        Time data
%       simRes      Results data
%
% Copyright 2018-2024 The MathWorks, Inc.

% Get simulation results
logsout_VehBus = logsout.get('VehBus');
logsout_RdBus  = logsout.get('RdBus');

time         = sm_car_sim_res_get(logsout,simlog,Vehicle,'time');
simRes.aRoll = sm_car_sim_res_get(logsout,simlog,Vehicle,'aRoll');

if(isfield(logsout_VehBus.Values.Chassis.SuspA1,'SpringL')) % For Twist Beam
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.SuspA1.SpringL.x.Data);
elseif(isfield(logsout_VehBus.Values.Chassis.SuspA1,'ShockL'))  % For Live Axle
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.SuspA1.ShockL.x.Data);
elseif(isfield(logsout_VehBus.Values.Chassis.SuspA1.LinkageL,'Shock')) % For Linkage
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.SuspA1.LinkageL.Shock.x.Data);
else
    % For decoupled suspension
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.Spring.L1.xSpring.Data);
end


% Calculate suspension metrics
maxRoll = max(abs(simRes.aRoll.data))*180/pi;

Values = [...
    maxRoll];
Names  = [...
    "Max Roll Angle"];
Units = [...
    "deg"];
Description = [...
    "Body Roll Angle"];

CarMetrics = table(Names,Values,Units,Description);





