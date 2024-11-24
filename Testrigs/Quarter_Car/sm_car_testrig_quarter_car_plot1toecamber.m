function [TSuspMetrics, toeCurve, camCurve] = sm_car_testrig_quarter_car_plot1toecamber(out,showplot)
% Code to plot simulation results from sm_car_testrig_quarter_car
%% Plot Description:
%
% Plot toe and camber curves during bump test.  Calculate standard
% suspension performance metrics.
%
% Copyright 2018-2024 The MathWorks, Inc.

% Get simulation results
simlog_t             = out.simlog_sm_car_testrig_quarter_car.Actuator.Cartesian_Joint.Pz.p.series.time;
simlog_pzTire        = out.simlog_sm_car_testrig_quarter_car.Actuator.Cartesian_Joint.Pz.p.series.values('m');
simlog_aCamber       = squeeze(out.logsout_sm_car_testrig_quarter_car.get('aCamber').Values.Data);
simlog_aToe          = squeeze(out.logsout_sm_car_testrig_quarter_car.get('aToe').Values.Data);
simlog_aCamberX      = squeeze(out.logsout_sm_car_testrig_quarter_car.get('Whl').Values.aCamberX.Data);
simlog_aToeX         = squeeze(out.logsout_sm_car_testrig_quarter_car.get('Whl').Values.aToeX.Data);

simlog_testPhases    = out.logsout_sm_car_testrig_quarter_car.find('timeTestPhases');

% Omit initial transient from bushings
simlog_tStart        = find(simlog_t>0.2,1);

if(~isempty(simlog_testPhases))
    % If testrig performs steer tests, get parameters for post-processing
    timeTestPhases = reshape(simlog_testPhases.Values.Data,2,[])';
    timeTestPhases(1) = 0.2;
    simlog_zWChp         = out.logsout_sm_car_testrig_quarter_car.get('zWChp').Values.Data;
    simlog_zOffsetBumpTest  = out.logsout_sm_car_testrig_quarter_car.get('zOffsetBumpTest').Values.Data;
    simlog_qToeForCaster = out.logsout_sm_car_testrig_quarter_car.get('qToeForCaster').Values.Data;
    % Get indices of simulation results for vertical test phase
    indToeCamb = intersect(find(simlog_t>=timeTestPhases(1,1)),find(simlog_t<=timeTestPhases(1,2)));
else
    % Else, generate toe and camber plots from simulation results
    indToeCamb = simlog_tStart:length(simlog_t);
end

toeCurve.qToe   = simlog_aToe(indToeCamb);
toeCurve.pzTire = simlog_pzTire(indToeCamb)-simlog_pzTire(1);
camCurve.qCam   = simlog_aCamber(indToeCamb);
camCurve.pzTire = simlog_pzTire(indToeCamb)-simlog_pzTire(1);

% Calculate suspension metrics
if(~isempty(simlog_testPhases))
    TSuspMetrics = sm_car_calc_susp_metrics(...
        simlog_aToe, ...
        simlog_aCamber, ...
        simlog_aToeX,...
        simlog_aCamberX,...
        simlog_pzTire, ...
        timeTestPhases, ...
        simlog_qToeForCaster,...
        simlog_zOffsetBumpTest,...
        simlog_t,...
        simlog_zWChp...
        );
else
    TSuspMetrics = [];
end

if(showplot)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h1_sm_car_testrig_quarter_car';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    %temp_colororder = get(gca,'defaultAxesColorOrder');

    % Plot results
    simlog_handles(1) = subplot(1, 2, 2);
    plot(camCurve.qCam, camCurve.pzTire, 'LineWidth', 1)
    grid on
    title('Camber Curve')
    xlabel('Camber (deg)')
    try
        varName = char(out.simlog_sm_car_testrig_quarter_car.Linkage.childIds);
        text(0.05,0.9,varName,'Units','Normalized','Color',[1 1 1]*0.5);
    catch
    end

    simlog_handles(2) = subplot(1, 2, 1);
    plot(toeCurve.qToe, toeCurve.pzTire, 'LineWidth', 1)
    grid on
    title('Toe Curve')
    xlabel('Toe (deg)')
    ylabel('Suspension Travel (m)')

    linkaxes(simlog_handles,'y')
end



