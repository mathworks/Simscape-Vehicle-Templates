function sm_car_plot11_compare_tire_force_torque(A_name, logsout_A, B_name, logsout_B, vartype, varname, vehTrl, varargin)
%sm_car_plot11_compare_tire_force_torque  Plot tire forces and torques from two simulation runs
%  sm_car_plot11_compare_tire_force_torque(A_name, logsout_A, B_name, logsout_B, vartype, varname)
%  You must provide:
%    nameA       String with name of first configuration, used in plot legend
%    logsout_A   Variable with logsout_sm_car data
%    nameB       String with name of second configuration
%    logsout_B   Variable with logsout_sm_car data
%    vartype     'wheel' to plot all quantities for one vehicle wheel
%                'var' to plot one quantity for all vehicle wheels
%    varname     Name of quantity ('Fx','Fy',...)
%                  or name of wheel ('WhlL1','WhlR2', ...)
%    vehTrl      'vehicle' or 'trailer'
%    varargin    Optional parameter to add a label to figure
%
% Copyright 2018-2021 The MathWorks, Inc.

if(nargin>7)
    label_string = varargin(1);
else
    label_string = 'no string';
end

% Reuse figure if it exists, else create new figure
fig_handle_name =   'h11_sm_car';
Init_type = evalin('base','Init.Type');

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Extract simulation results from two runs
if(strcmpi(vehTrl,'vehicle'))
    log_fieldname = 'VehBus';
elseif(strcmpi(vehTrl,'trailer'))
    log_fieldname = 'TrlBus'; % Trailer data
else
    disp(['Argument ' char(vehTrl) ' should be ''Vehicle'' or ''Trailer''.'])
    disp('Plotting results for vehicle')
    log_fieldname = 'VehBus';
end

logsout_VehBus_A = logsout_A.get(log_fieldname);
logsout_VehBus_B = logsout_B.get(log_fieldname);

% Find fields with wheel data in them
chassis_log_fieldnames = fieldnames(logsout_VehBus_A.Values.Chassis);
whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
whlnames = sort(chassis_log_fieldnames(whl_inds));

% Plot results
if(strcmpi(vartype,'wheel'))
    % Plot all quantities for one wheel
    ah(1) = subplot(3,2,1);
    logsout_Fx_A = logsout_VehBus_A.Values.Chassis.(varname).Fx;
    logsout_Fx_B = logsout_VehBus_B.Values.Chassis.(varname).Fx;
    plot(logsout_Fx_A.Time, squeeze(logsout_Fx_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_Fx_B.Time, squeeze(logsout_Fx_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('Fx (N)');

    ah(2) = subplot(3,2,3);
    logsout_Fy_A = logsout_VehBus_A.Values.Chassis.(varname).Fy;
    logsout_Fy_B = logsout_VehBus_B.Values.Chassis.(varname).Fy;
    plot(logsout_Fy_A.Time, squeeze(logsout_Fy_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_Fy_B.Time, squeeze(logsout_Fy_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('Fy (N)');

    ah(3) = subplot(3,2,5);
    logsout_Fz_A = logsout_VehBus_A.Values.Chassis.(varname).Fz;
    logsout_Fz_B = logsout_VehBus_B.Values.Chassis.(varname).Fz;
    plot(logsout_Fz_A.Time, squeeze(logsout_Fz_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_Fz_B.Time, squeeze(logsout_Fz_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('Fz (N)');
    xlabel('Time (s)')

    ah(4) = subplot(3,2,2);
    logsout_Mx_A = logsout_VehBus_A.Values.Chassis.(varname).Mx;
    logsout_Mx_B = logsout_VehBus_B.Values.Chassis.(varname).Mx;
    plot(logsout_Mx_A.Time, squeeze(logsout_Mx_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_Mx_B.Time, squeeze(logsout_Mx_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('Mx (N*m)');

    ah(5) = subplot(3,2,4);
    logsout_My_A = logsout_VehBus_A.Values.Chassis.(varname).My;
    logsout_My_B = logsout_VehBus_B.Values.Chassis.(varname).My;
    plot(logsout_My_A.Time, squeeze(logsout_My_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_My_B.Time, squeeze(logsout_My_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('My (N*m)');

    ah(6) = subplot(3,2,6);
    logsout_Mz_A = logsout_VehBus_A.Values.Chassis.(varname).Mz;
    logsout_Mz_B = logsout_VehBus_B.Values.Chassis.(varname).Mz;
    plot(logsout_Mz_A.Time, squeeze(logsout_Mz_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
    hold on
    plot(logsout_Mz_B.Time, squeeze(logsout_Mz_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
    hold off
    title('Mz (N*m)');
    xlabel('Time (s)')

else
    % Plot all wheels for a specific quantity
    ymin = inf; ymax = -inf;

    % Put left side wheels on left, right side wheels on right
    % Indexing works for 4, 6, or other numbers of wheels
    subplot_inds = [1:2:length(whl_inds)-1 2:2:length(whl_inds)];

    for whl_i = 1:length(whl_inds)
        ah(whl_i) = subplot(length(whl_inds)/2,2,subplot_inds(whl_i));
        logsout_q_A = logsout_VehBus_A.Values.Chassis.(whlnames{whl_i}).(varname);
        logsout_q_B = logsout_VehBus_B.Values.Chassis.(whlnames{whl_i}).(varname);
        plot(logsout_q_A.Time, squeeze(logsout_q_A.Data),'LineWidth', 1,'LineStyle','-','DisplayName',A_name)
        hold on
        plot(logsout_q_B.Time, squeeze(logsout_q_B.Data),'LineWidth', 1,'LineStyle','--','DisplayName',B_name)
        title([whlnames{whl_i} ' ' varname]);
        ymin = min(ymin,ah(whl_i).YLim(1));
        ymax = max(ymax,ah(whl_i).YLim(2));
    end

    % Make all vertical ranges match
    for i = 1:length(ah)
        set(ah(i),'YLim',[ymin ymax])
    end
end

% Settings for all axes
hold off
set(ah,'Box','on')
for i = 1:length(ah)
    grid(ah(i),'on')
end

% Put legend on last subplot
legend('Location','Best');
linkaxes(ah,'x')

% Add optional label to figure, associate with first subplot
subplot(ah(1))
if(length(ah)==4)
    norm_yoffset = 1.175;
else
    norm_yoffset = 1.3;
end
if(~strcmp(label_string,'no string'))
    text(0,norm_yoffset,label_string,...
        'Color',[1 1 1]*0.5,'Units','Normalized')
end
