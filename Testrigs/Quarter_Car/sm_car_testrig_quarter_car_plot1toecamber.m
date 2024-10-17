function TSuspMetrics = sm_car_testrig_quarter_car_plot1toecamber(mdl)

% Code to plot simulation results from sm_car_testrig_quarter_car
%% Plot Description:
%
% Plot toe and camber curves during bump test.  Calculate standard
% suspension performance metrics.
%
% Copyright 2018-2024 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('simlog_sm_car_testrig_quarter_car', 'var')
    out = sim(mdl);
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_sm_car_testrig_quarter_car', 'var') || ...
        ~isgraphics(h1_sm_car_testrig_quarter_car, 'figure')
    h1_sm_car_testrig_quarter_car = figure('Name', 'sm_car_testrig_quarter_car');
end
figure(h1_sm_car_testrig_quarter_car)
clf(h1_sm_car_testrig_quarter_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_t             = out.simlog_sm_car_testrig_quarter_car.Actuator.Cartesian_Joint.Pz.p.series.time;
simlog_pzTire        = out.simlog_sm_car_testrig_quarter_car.Actuator.Cartesian_Joint.Pz.p.series.values('m');
simlog_aCamber       = squeeze(out.logsout_sm_car_testrig_quarter_car.get('aCamber').Values.Data);
simlog_aToe          = squeeze(out.logsout_sm_car_testrig_quarter_car.get('aToe').Values.Data);
simlog_aCamberX      = squeeze(out.logsout_sm_car_testrig_quarter_car.get('Whl').Values.aCamberX.Data);
simlog_aToeX         = squeeze(out.logsout_sm_car_testrig_quarter_car.get('Whl').Values.aToeX.Data);

simlog_testPhases    = out.logsout_sm_car_testrig_quarter_car.find('timeTestPhases');
if(~isempty(simlog_testPhases))
    % If testrig performs steer tests, get parameters for post-processing
    timeTestPhases = reshape(simlog_testPhases.Values.Data,2,[])';
    simlog_zWChp         = out.logsout_sm_car_testrig_quarter_car.get('zWChp').Values.Data;
    simlog_zOffsetBumpTest  = out.logsout_sm_car_testrig_quarter_car.get('zOffsetBumpTest').Values.Data;
    simlog_qToeForCaster = out.logsout_sm_car_testrig_quarter_car.get('qToeForCaster').Values.Data;
    % Get indices of simulation results for vertical test phase
    indToeCamb = intersect(find(simlog_t>=timeTestPhases(1,1)),find(simlog_t<=timeTestPhases(1,2)));
else
    % Else, generate toe and camber plots from simulation results
    indToeCamb = 1:length(simlog_t);
end

% Plot results
simlog_handles(1) = subplot(1, 2, 2);
plot(simlog_aCamber(indToeCamb), simlog_pzTire(indToeCamb)-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Camber Curve')
xlabel('Camber (deg)')
try
text(0.05,0.9,get_param([bdroot '/Linkage'],'ActiveVariant'),...
    'Units','Normalized','Color',[1 1 1]*0.5);
catch
end

simlog_handles(2) = subplot(1, 2, 1);
plot(simlog_aToe(indToeCamb), simlog_pzTire(indToeCamb)-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Toe Curve')
xlabel('Toe (deg)')
ylabel('Suspension Travel (m)')

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