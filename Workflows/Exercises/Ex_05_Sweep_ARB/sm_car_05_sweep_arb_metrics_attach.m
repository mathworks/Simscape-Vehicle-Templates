function [results] = sm_car_05_sweep_arb_metrics_attach(simOut)
% Function to post-process simulation data and store results within results
% object

% extract logs
simlog = simOut.logsout_sm_car;
% get the metrics and attach to the results
[results.metrics] = sm_car_05_sweep_arb_metrics_calc(simlog);
% logs will be lost unless explicitly added back to the results
results.logsout = simlog;