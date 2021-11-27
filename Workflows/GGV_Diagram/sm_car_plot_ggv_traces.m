% Plot time-based results from GGV sweep for inspection 
% Copyright 2021 The MathWorks, Inc.

% Clear results figure if it already exists.
if exist('sm_car_ggv_traces', 'var')
    if isgraphics(sm_car_ggv_traces, 'figure')
        clf( sm_car_ggv_traces, 'reset' )
    end
end
sm_car_ggv_traces = figure('Name', 'sm_car_ggv_traces');

vehbus_tests = [ simOut.logsout_sm_car.get("VehBus").Values];
for iSim = 1:nSims
    body_vx_time  = vehbus_tests(iSim).World.vx.Time;
    body_vx_data  = vehbus_tests(iSim).World.vx.Data;
    body_vy_data  = vehbus_tests(iSim).World.vy.Data;
    plot(body_vx_time,sqrt(body_vx_data.^2+body_vy_data.^2));
    hold on
end
hold off
title(['Speed for GGV Sweep (Vehicle: ' vehicle_name ')'])
text(0.05, 0.05, vehicle_name, 'Units','Normalized','Color',[0.5 0.5 0.5])
xlabel('Time (s)');
ylabel('Speed (m/s)');
