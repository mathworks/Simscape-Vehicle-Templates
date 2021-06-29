% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot hydraulic pressures from brake calipers
%
% Copyright 2016-2020 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h6_sm_car', 'var') || ...
        ~isgraphics(h6_sm_car, 'figure')
    h6_sm_car = figure('Name', 'sm_car');
end
figure(h6_sm_car)
clf(h6_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_VehBus = logsout_sm_car.get('VehBus');

logsout_pFL = logsout_VehBus.Values.Brakes.pBrakeL1;
logsout_pFR = logsout_VehBus.Values.Brakes.pBrakeR1;
logsout_pRL = logsout_VehBus.Values.Brakes.pBrakeL2;
logsout_pRR = logsout_VehBus.Values.Brakes.pBrakeR2;

%simlog_pMCL = simlog_sm_car.Brakes.Disc.Actuator.Valves.Valves_FL.Orifice_Apply.A.p.series.values('psi');
%simlog_pMCR = simlog_sm_car.Brakes.Disc.Actuator.Valves.Valves_FR.Orifice_Apply.A.p.series.values('psi');

% Plot results
simlog_handles(1) = subplot(1, 1, 1);
%plot(logsout_pFL,simlog_pMCL,'k--','LineWidth',2);
%hold on
%plot(simlog_t,simlog_pMCFRRL,'r--','LineWidth',2);
plot(...
    logsout_pFL.Time, logsout_pFL.Data, logsout_pFR.Time, logsout_pFR.Data,...
    logsout_pRL.Time, logsout_pRL.Data, logsout_pRR.Time, logsout_pRR.Data,...
    'LineWidth', 1)
hold off
grid on
title('Cylinder Pressure');
ylabel('Pressure (bar)');
xlabel('Time (s)');
legend({'Front Left','Front Right','Rear Left','Rear Right'},'Location','Best');


%{
simlog_handles(2) = subplot(2, 1, 2);
plot(simlog_t, simlog_C1v, 'LineWidth', 1)
grid on
title('Voltage')
ylabel('Voltage (V)')
xlabel('Time (s)')

linkaxes(simlog_handles, 'x')
%}

% Remove temporary variables
clear simlog_t simlog_handles
clear simlog_R1i simlog_C1v temp_colororder

