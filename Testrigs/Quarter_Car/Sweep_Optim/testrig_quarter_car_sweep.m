function [simInput, simOut, TSuspMetricsSet] = testrig_quarter_car_sweep(mdl,Vehicle,hp_list,Maneuver)

% Ensure model is open
open_system(mdl)
sm_car_config_variants(mdl);

stopTimeBzn = Maneuver.tRange.Bumpzn(2);

%% Assemble combination of tests
numVals  = zeros(1,length(hp_list));
for hp_i = 1:length(hp_list)
    numVals(hp_i) = length(hp_list(hp_i).valueSet);
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
    testNum = testNum +1;
    % Loop over hps (columns of valCombs)
    UserString_SimInput = [];
    for hp_i = 1:length(hp_list)
        part_name  = hp_list(hp_i).part;
        hp_name    = hp_list(hp_i).point;
        index_val  = hp_list(hp_i).index;

        % valCombs used to create combinations of each hp value
        axis_value = hp_list(hp_i).valueSet(valCombs(vc_i,hp_i));
        Vehicle.Chassis.SuspA1.Linkage.(part_name).(hp_name).Value(index_val) ...
            = axis_value;
        paramNameString = [part_name '.' hp_name '(' num2str(index_val) ')'];
        UserString_SimInput = [UserString_SimInput ';' ...
            'Vehicle.Chassis.SuspA1.Linkage.' part_name '.' hp_name '.Value(' num2str(index_val) ')'];
%        parAbb = parStr2Abb(paramNameString);
%        simInput(testNum) = setVariable(simInput(testNum),parAbb,axis_value);
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
            parAbb   = ['par_' parStr2Abb(parStrSet{p_i})];
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

function parAbb = parStr2Abb(parStr0)


parStr1 = strrep(parStr0,'Vehicle.Chassis.SuspA1.Linkage.','');
parStr2 = strrep(parStr1,'Value(','');
parStr3 = strrep(parStr2,')','');
parStr4 = strrep(parStr3,'UpperWishbone.','UW');
parStr5 = strrep(parStr4,'LowerWishbone.','LW');
parStr6 = strrep(parStr5,'InboardF.','F');
parStr7 = strrep(parStr6,'InboardR.','R');
parStr8 = strrep(parStr7,'LowerArm','LA');
parStr9 = strrep(parStr8,'UpperArm','UA');
parStr10 = strrep(parStr9,'.s','');
parStr11 = strrep(parStr10,'board.','');
parStr12 = strrep(parStr11,'(','');
parStr13 = strrep(parStr12,')','');

parAbb = parStr13;
