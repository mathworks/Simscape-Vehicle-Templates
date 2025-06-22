function CarMetricsSet = sm_car_sweep_plot_runs(simInput,simOut,metricName)

%% Reuse figure if it exists, else create new figure
fig_handle_name =   'h1_sm_car_sweep';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Loop over outputs
numTests = length(simOut);
for r_i = 1:numTests

    % Get Performance Metrics
    Vehicle = simInput(r_i).getVariable('Vehicle');
    [CarMetrics] = sm_car_perf_metrics(simOut(r_i).logsout_sm_car,false,true,false);
    metricVal  = sm_car_sim_res_get(simOut(r_i).logsout_sm_car,simOut(r_i).simlog_sm_car,Vehicle,metricName);
    time   = sm_car_sim_res_get(simOut(r_i).logsout_sm_car,simOut(r_i).simlog_sm_car,Vehicle,'time');

    % Loop over list of metrics
    for f_i = 1:size(CarMetrics,1)

        % Convert name to suitable structure field name
        fName = strrep(CarMetrics.Names(f_i),' ', '_');
        fName = strrep(fName,'(', '_');
        fName = strrep(fName,')', '');
        fName = strrep(fName,'/', '_');
        fNameUnits = [char(fName) 'Units'];

        % Add data to structure
        CarMetricsSet(r_i).(fName) = CarMetrics.Values(f_i);
        CarMetricsSet(r_i).(fNameUnits) = CarMetrics.Units(f_i);
        parStr = simInput(r_i).UserString;
        parStrSet = strsplit(parStr,';');
        for p_i = 1:size(parStrSet,2)
            axis_val = eval(parStrSet{p_i});
            parAbb   = ['par_' sm_car_parStr2Abb(parStrSet{p_i})];
            CarMetricsSet(r_i).(parAbb) = axis_val;
        end

    end

    % Construct legend entry string
    legName = ['Test ' pad(num2str(r_i),length(num2str(numTests)),'left',' ')];

    % Debugging
    %disp([legName ': ' num2str(CarMetricsSet(r_i).(fName))]);

    % Plot Selected Result
    plot(time.data, metricVal.data, 'LineWidth', 1,'DisplayName',legName)
    grid on
    title(metricVal.name)
    ylabel([metricVal.name ' (' metricVal.units ')'])
    xlabel('Time (sec)')
    hold on
end

legend('Location','best')


