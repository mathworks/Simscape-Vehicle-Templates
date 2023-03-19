function sm_car_linkage_plot1toecamber(modelname)
% Code to plot simulation results from linkage test harnesses
%% Plot Description:
%
% <enter plot description here if desired>
%
% Copyright 2018-2023 The MathWorks, Inc.

% Generate simulation results if they don't exist

% Generate simulation results if they don't exist
simlog_data = evalin('base',['who(''simlog_' modelname ''')']);
if isempty(simlog_data)
    sim(modelname)
    assignin('base',['simlog_' modelname],eval(['simlog_' modelname]));
    assignin('base',['logsout_' modelname],eval(['logsout_' modelname]));
    simlog_data = eval(['simlog_' modelname]);
    logsout_data = eval(['logsout_' modelname]);
else
    simlog_data = evalin('base',['simlog_' modelname]);
    logsout_data = evalin('base',['logsout_' modelname]);
end

% Reuse figure if it exists, else create new figure
handle_var = evalin('base',['h1_' modelname]);
% = evalin('base',['h1_' modelname]);
if isempty(handle_var) || ...
        ~isgraphics(handle_var, 'figure')
    evalin('base',['h1_' modelname ' = figure(''Name'', ''' modelname ''');']);
end
figure(evalin('base',['h1_' modelname]))
clf(evalin('base',['h1_' modelname]))

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_pzTire = simlog_data.Actuator.Cartesian_Joint.Pz.p.series.values('m');

simlog_aCamber = logsout_data.get('aCamber');
simlog_aToe = logsout_data.get('aToe');

% Plot results
simlog_handles(1) = subplot(1, 2, 1);
plot(simlog_aCamber.Values.Data(:), simlog_pzTire-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Camber Curve')
ylabel('Suspension Travel (m)')
xlabel('Camber (deg)')

mdlWks = get_param(modelname,'ModelWorkspace');
linkage_data = getVariable(mdlWks,'Linkage');
linkage_instance = linkage_data.Instance;

label_str = sprintf('Model: %s\nData: %s',...
    strrep(modelname,'_',' '),...
    strrep(linkage_instance,'_',' '));

text(0.05,0.9,label_str,...
    'Units','Normalized','Color',[1 1 1]*0.5);
%text(0.05,0.9,strrep([modelname ', ' linkage_class],'_',' '),...
%    'Units','Normalized','Color',[1 1 1]*0.5);

simlog_handles(2) = subplot(1, 2, 2);
plot(simlog_aToe.Values.Data(:), simlog_pzTire-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Toe Curve')
xlabel('Toe (deg)')

% Remove temporary variables
%clear simlog_handles temp_colororder
%clear simlog_aToe simlog_aCamber simlog_pzTire 

