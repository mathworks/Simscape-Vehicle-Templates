% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%
% Copyright 2018-2023 The MathWorks, Inc.

% Check for simulation results if they don't exist
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h4_sm_car', 'var') || ...
        ~isgraphics(h4_sm_car, 'figure')
    h4_sm_car = figure('Name', 'sm_car');
end
figure(h4_sm_car)
clf(h4_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_VehBus = logsout_sm_car.get('VehBus');

logsout_vxVeh = logsout_VehBus.Values.World.vx;
logsout_vyVeh = logsout_VehBus.Values.World.vy;
logsout_sVeh = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2);
logsout_xCar = logsout_VehBus.Values.World.x;
logsout_yCar = logsout_VehBus.Values.World.y;

logsout_nWhlFL = logsout_VehBus.Values.Chassis.WhlFL.n;
logsout_nWhlFR = logsout_VehBus.Values.Chassis.WhlFR.n;
logsout_nWhlRL = logsout_VehBus.Values.Chassis.WhlRL.n;
logsout_nWhlRR = logsout_VehBus.Values.Chassis.WhlRR.n;

simlog_t = simlog_sm_car.Vehicle.Brakes.ABS_4_Channel.Valves.Piston_FL.A.p.series.time;
simlog_pwhlFL  = simlog_sm_car.Vehicle.Brakes.ABS_4_Channel.Valves.Piston_FL.A.p.series.values('Pa');
simlog_pwhlFR  = simlog_sm_car.Vehicle.Brakes.ABS_4_Channel.Valves.Piston_FR.A.p.series.values('Pa');
simlog_pwhlRL  = simlog_sm_car.Vehicle.Brakes.ABS_4_Channel.Valves.Piston_RL.A.p.series.values('Pa');
simlog_pwhlRR  = simlog_sm_car.Vehicle.Brakes.ABS_4_Channel.Valves.Piston_RR.A.p.series.values('Pa');


%% Plot results
plong  = logsout_xCar.Data(:,1);
plong0 = plong(1);
plat   = logsout_yCar.Data(:,1);
plat0  = plat(1);

simlog_handles(1) = subplot(2, 2, [1 3]);
plot(-(plat-plat0), plong-plong0, 'LineWidth', 1)
axis equal
grid on
title('Position')
ylabel('Position (m)')
xlabel('Position (m)')

simlog_handles(2) = subplot(2, 2, 2);
plot(logsout_vVeh.Time, logsout_sVeh*3.6, 'k--', 'LineWidth', 1)
hold on
plot(...
    logsout_nWhlFL.Time, logsout_nWhlFL.Data*3.6*0.4225,...
    logsout_nWhlFR.Time, logsout_nWhlFR.Data*3.6*0.4225,...
    logsout_nWhlRL.Time, logsout_nWhlRL.Data*3.6*0.4225,...
    logsout_nWhlRR.Time, logsout_nWhlRR.Data*3.6*0.4225,...
    'LineWidth', 1)
hold off
grid on
title('Wheel Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')
legend({'Vehicle','FL','FR','RL','RR'},'Location','Best');
grid on

simlog_handles(2) = subplot(2, 2, 4);
plot(simlog_t, simlog_pwhlFL, 'LineWidth', 1);
hold on
plot(simlog_t, simlog_pwhlFR, 'LineWidth', 1);
plot(simlog_t, simlog_pwhlRL, 'LineWidth', 1);
plot(simlog_t, simlog_pwhlRR, 'LineWidth', 1);
hold off

grid on
title('Brake Pressure')
ylabel('Pressure (Pa)')
xlabel('Time (s)')
legend({'FL','FR','RL','RR'},'Location','Best');
grid on


%% Add no fault data to path plot
%{
subplot(2, 2, [1 3]);
hold on
plong_noF  = simlog_pveh_noFault.Values.Data(:,1);
plong0_noF = plong_noF(1);
plat_noF   = simlog_pveh_noFault.Values.Data(:,2);
plat0_noF  = plat_noF(1);

plot(-(plat_noF-plat0_noF), plong_noF-plong0_noF, 'k--','LineWidth', 1)
legend({'Fault','No Fault'},'Location','East')
hold off
tire_sys = find_system(bdroot,'LookUnderMasks','on','FollowLinks','on','Name','Tire FL');
tirevar = char(get_param(tire_sys,'ActiveVariant'));
%text(0.4,0.5,sprintf('Tire %s\nSteps: %d',tirevar,length(simlog_vveh.Values.Time)),'Units','Normalized','Color',[1 1 1]*0.5);
text(0.4,0.2,sprintf('xFinal: %0.2f m\nyFinal: %0.2f m',...
    plong(end)-plong0,-(plat(end)-plat0)),'Units','Normalized','Color',[1 1 1]*0.5);
%}

%% Add faulty sensor data
%{
simlog_handles(2) = subplot(2, 2, 2);
plot(simlog_sveh.Values.Time, simlog_sveh.Values.Data*3.6, 'k--', 'LineWidth', 1)
hold on
plot(simlog_wwhlmeas.Values.RL.v.Time, simlog_wwhlmeas.Values.RL.v.Data, 'LineWidth', 1)
plot(simlog_wwhl.Values.Time, simlog_wwhl.Values(:).Data(:,3)*3.6*0.4225, 'LineWidth', 1)
hold off
grid on
title('Wheel Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')
legend({'Vehicle','RL Sensor','RL'},'Location','Best');
%}

%% Save data
%{
simlog_filename = ['simlog_sm_car_' datestr(now,'yymmdd_HHMM')];
save(simlog_filename,'simlog_t',...
    'simlog_pwhlFL','simlog_pwhlFR','simlog_pwhlRL','simlog_pwhlRR',...
    'simlog_sveh','simlog_vveh','simlog_pveh','simlog_wwhl','simlog_wwhlmeas');
%}