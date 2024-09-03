function sm_car_plot7power(logsout_data)
% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results from electric powertrains
%
% Copyright 2016-2024 The MathWorks, Inc.

% Get simulation results
logsout_VehBus  = logsout_data.get('VehBus');
logsout_t       = logsout_VehBus.Values.Chassis.Body.CG.vx.Time;
logsout_sVeh    = logsout_VehBus.Values.Chassis.Body.CG.vx.Data;

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
    set(gca,'Position',[0.1300    0.7119    0.7750    0.2121]);
    ylabel('Speed (km/hr)');
    title('Vehicle Speed','FontSize',12);

    simlog_handles(2) = subplot(212);
    plot(logsout_t,logsout_iBatt,'LineWidth',1);
    hold on
    if(exist('logsout_iFC','var'))
        plot(logsout_t,logsout_iFC,'--','Color',temp_colororder(2,:),'LineWidth',1);
    end
    ylim = get(gca,'YLim');
    range_y = ylim(2)-ylim(1);
    max_SOC = max(logsout_battSOC);
    min_SOC = min(logsout_battSOC);
    range_SOC = max_SOC-min_SOC;
    SOC_scaled = (logsout_battSOC-min_SOC)*(range_y/range_SOC)+ylim(1);
    set(gca,'YLim',ylim);
    plot(logsout_t,SOC_scaled,'Color',temp_colororder(5,:),'LineWidth',1);
    hold off
    set(gca,'Position',[0.1300    0.1100    0.7750    0.4900]);
    title('Power Supply','FontSize',12);

    SOClegendstr = [newline 'Battery SOC' sprintf('\n(range %0.1f',min_SOC) '% - ' sprintf('%0.1f',max_SOC) '%)'];
    if(exist('logsout_iFC','var'))
        legendstr = {'Battery Current','Fuel Cell Current',SOClegendstr};
    else
        legendstr = {'Battery Current',SOClegendstr};
    end
    legend(legendstr,'Location','NorthEast');
    linkaxes(simlog_handles,'x')

    xlabel('Time (sec)');
    ylabel('Current (A) / SOC');
else
    warning('No battery current data found');
end


