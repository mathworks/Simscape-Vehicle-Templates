function sm_car_plot8regen(logsout_data)
% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results from electric powertrains
%
% Copyright 2016-2021 The MathWorks, Inc.

% Get simulation results
logsout_VehBus  = logsout_data.get('VehBus');
logsout_t       = logsout_VehBus.Values.Chassis.Body.CG.vx.Time;
logsout_sVeh    = logsout_VehBus.Values.Chassis.Body.CG.vx.Data;

gearRatio = evalin('base','Control.Electric_A1_A2_default.Brakes.Ndiff_front');
logsout_MBrakeL1    = logsout_VehBus.Values.Brakes.MBrakeL1.Data;
logsout_MBrakeR1    = logsout_VehBus.Values.Brakes.MBrakeR1.Data;
logsout_MBrakeL2    = logsout_VehBus.Values.Brakes.MBrakeL2.Data;
logsout_MBrakeR2    = logsout_VehBus.Values.Brakes.MBrakeR2.Data;

BrkTrq = logsout_MBrakeL1+logsout_MBrakeR1+logsout_MBrakeL2+logsout_MBrakeR2;

if(isfield(logsout_VehBus.Values.Power,'MotorA1') && ...
        isfield(logsout_VehBus.Values.Power,'MotorA2'))
    logsout_MotA1    = logsout_VehBus.Values.Power.MotorA1.trq.Data*gearRatio;
    logsout_MotA2    = logsout_VehBus.Values.Power.MotorA1.trq.Data*gearRatio;
    MotTrq = logsout_MotA1+logsout_MotA2;
    trqDispName = 'Total Motor Torque';
else
    MotTrq = zeros(size(logsout_MBrakeL1));
    trqDispName = 'No Electric Motor Torque Results Found';
end

logsout_aPitch    = logsout_VehBus.Values.World.aPitch.Data;


existCurrentData = 0;
if(isfield(logsout_VehBus.Values.Power,'Battery'))
    logsout_battSOC = logsout_VehBus.Values.Power.Battery.SOC.Data;
    logsout_iBatt   = logsout_VehBus.Values.Power.Battery.i.Data;
    existCurrentData = 1;
end
if(isfield(logsout_VehBus.Values.Power,'FuelCell'))
    logsout_iFC      = logsout_VehBus.Values.Power.FuelCell.i.Data;
end

if(existCurrentData)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h7_sm_car';
    
    Init_type = evalin('base','Init.Type');
    
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    
    temp_colororder = get(gca,'defaultAxesColorOrder');
    
    simlog_handles(1) = subplot(211);
    plot(logsout_t,logsout_sVeh,'LineWidth',1);
    %plot(logsout_t,logsout_aPitch,'LineWidth',1,'Color',temp_colororder(6,:));
    set(gca,'Position',[0.1300    0.7119    0.7750    0.2121]);
    
    title('Vehicle Speed','FontSize',12);
    ylabel('Speed (km/hr)');
    
    %ylabel('Pitch (rad)');
    %title('Vehicle Pitch Angle','FontSize',12);
    
    simlog_handles(2) = subplot(212);
    plot(logsout_t,MotTrq,'LineWidth',1,'DisplayName',trqDispName);
    hold on
    plot(logsout_t,BrkTrq,'LineWidth',1,'DisplayName','Total Brake Torque');
    hold off
    set(gca,'Position',[0.1300    0.1100    0.7750    0.4900]);
    title('Motor and Brake Torque','FontSize',12);
    legend('Location','Best')
    
    
    
    linkaxes(simlog_handles,'x')
    
    xlabel('Time (sec)');
    ylabel('Torque (N*m)');
else
    error('No battery current data found');
end


