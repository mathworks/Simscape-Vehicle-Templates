function CarMetrics = sm_car_perf_metrics_strfrc(logsout,simlog,Vehicle,tTrans)
%sm_car_perf_metrics  Obtain performance metrics from full vehicle test
%   [CarMetrics] = sm_car_perf_metrics(logsout,simlog,Vehicle)
%   This function extracts specific measurements from suspension
%   simulations for suspension metric calculations and plots. 
%       logsout      Simulink results from suspension simulation
%       simlog       Simscape results from suspension simulation
%       Vehicle      Vehicle parameter structure
%
%   Outputs:
%       CarMetrics  Table of metrics from the test
%
% Copyright 2018-2026 The MathWorks, Inc.

% Get simulation results
fRack = sm_car_sim_res_get(logsout,simlog,Vehicle,'fRack');
time = sm_car_sim_res_get(logsout,simlog,Vehicle,'time');

endTransInd = find(time.data>tTrans,1);

% Calculate suspension metrics
maxfRack = max(fRack.data(endTransInd:end));

Values = [...
    maxfRack];
Names  = [...
    "Max Rack Force"];
Units = [...
    "N"];
Description = [...
    "Max Rack Actuation Force"];

CarMetrics = table(Names,Values,Units,Description);
