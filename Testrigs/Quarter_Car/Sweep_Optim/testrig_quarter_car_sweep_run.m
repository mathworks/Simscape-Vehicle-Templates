function [simInput, simOut, TSuspMetricsSet] = testrig_quarter_car_sweep_run(mdl,Vehicle,par_list,Maneuver)

% Ensure model is open
open_system(mdl)
sm_car_config_variants(mdl);

% Limit stop time - do not need entire KnC test
stopTimeBzn = Maneuver.tRange.Bumpzn(2);

% Add short name to par_list
par_list = sm_car_param_short_name(par_list);

%% Assemble combination of tests
numVals  = zeros(1,length(par_list));
for par_i = 1:length(par_list)
    numVals(par_i) = length(par_list(par_i).valueSet);
end

valCombs = generateCombinations(numVals);
numTests = size(valCombs,1);

%% Create Simulation Input Object
% Create empty set of inputs
clear simInput
simInput(1:numTests) = Simulink.SimulationInput(mdl);

% Loop to create simInput object (rows of valCombs)
testNum = 0;
for vc_i = 1:numTests
    testNum = testNum+1;
    % Loop over hps (columns of valCombs)
    UserString_SimInput = [];
    for par_i = 1:length(par_list)
        path2Val   = par_list(par_i).path2Val;

        % valCombs used to create combinations of each hp value
        axis_value = par_list(par_i).valueSet(valCombs(vc_i,par_i));

        % Set value within Vehicle data structure
        eval([path2Val ' = ' num2str(axis_value) ';']);
        UserString_SimInput = [UserString_SimInput ';' par_list(par_i).path2Val];
    end
    simInput(testNum) = setVariable(simInput(testNum),'Vehicle',Vehicle);
    simInput(testNum) = setModelParameter(simInput(testNum),'StopTime',num2str(stopTimeBzn));
    simInput(testNum).UserString = UserString_SimInput(2:end);
end

%% Run simulations
clear simOut
simOut = sim(simInput,'ShowSimulationManager','off',...
    'ShowProgress','on','UseFastRestart','on');

%% Reuse figure if it exists, else create new figure
fig_handle_name =   'h1_sm_car_testrig_quarter_car_sweep';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Loop over outputs
for r_i = 1:numTests
    
    % Get toe, camber curves
    [TSuspMetrics, toeCurve, camCurve] = sm_car_knc_plot1toecamber(simOut(r_i).logsout_sm_car_testrig_quarter_car,false,true,false);

    for f_i = 1:size(TSuspMetrics,1)
        fName = strrep(TSuspMetrics.Names(f_i),' ', '_');
        fName = strrep(fName,'(', '_');
        fName = strrep(fName,')', '');
        fName = strrep(fName,'/', '_');
        fNameUnits = [char(fName) 'Units'];
        TSuspMetricsSet(r_i).(fName) = TSuspMetrics.Values(f_i);
        TSuspMetricsSet(r_i).(fNameUnits) = TSuspMetrics.Units(f_i);
        Vehicle = simInput(r_i).getVariable('Vehicle');
        parStr = simInput(r_i).UserString;
        parStrSet = strsplit(parStr,';');
        for p_i = 1:size(parStrSet,2)
            axis_val = eval(parStrSet{p_i});
            parAbb   = ['par_' sm_car_parStr2Abb(parStrSet{p_i})];
            TSuspMetricsSet(r_i).(parAbb) = axis_val;
        end

    end

    legName = ['Test ' pad(num2str(r_i),length(num2str(numTests)),'left',' ')];
    %disp([legName ': ' num2str(abs(TSuspMetrics.Values(5)))]);

    % Plot Camber
    simlog_handles(1) = subplot(1, 2, 2);
    plot(camCurve.qCam, camCurve.pzTire, 'LineWidth', 1)
    grid on
    title('Camber Curve')
    xlabel('Camber (deg)')
    hold on

    % Plot Toe
    simlog_handles(2) = subplot(1, 2, 1);
    plot(toeCurve.qToe, toeCurve.pzTire, 'LineWidth', 1,'DisplayName',legName)
    grid on
    title('Toe Curve')
    xlabel('Toe (deg)')
    ylabel('Suspension Travel (m)')
    hold on
end
hold(simlog_handles,'off')

legend(simlog_handles(2),'Location','best')

