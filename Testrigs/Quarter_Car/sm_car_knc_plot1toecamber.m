function [TSuspMetrics, toeCurve, camCurve] = sm_car_knc_plot1toecamber(logsout,showplot,calcMetrics,debugPlots)
%sm_car_knc_plot1toecamber  Obtain toe curve, camber curve, and suspension metrics
%   [TSuspMetrics, toeCurve, camCurve] = sm_car_knc_plot1toecamber(logsout,showplot,calcMetrics,debugPlots)
%   This function extracts specific measurements from suspension
%   simulations for suspension metric calculations and plots. 
%       logsout      Results from suspension simulation
%       showplot     true to plot toe and camber curves
%       calcMetrics  true to calculate suspension metrics
%       debugPlots   true to create plots detailing suspension metric calculations
%
%   Outputs:
%       TSuspMetrics Table of suspension metrics from KnC test
%       toeCurve     Data for plotting toe curve
%       camCurve     Data for plotting camber curve
%
% Copyright 2018-2024 The MathWorks, Inc.

% Get simulation results
logsout_VehBus = logsout.get('VehBus');
logsout_RdBus  = logsout.get('RdBus');

simlog_t             = logsout_VehBus.Values.Chassis.WhlL1.xyz.Time;
simlog_pxTire        = logsout_VehBus.Values.Chassis.WhlL1.xyz.Data(:,1);
simlog_pyTire        = logsout_VehBus.Values.Chassis.WhlL1.xyz.Data(:,2);
simlog_pzTire        = logsout_VehBus.Values.Chassis.WhlL1.xyz.Data(:,3);
simlog_aCamber       = squeeze(logsout_VehBus.Values.Chassis.SuspA1.WhlL.aCamber.Data);
simlog_aToe          = squeeze(logsout_VehBus.Values.Chassis.SuspA1.WhlL.aToe.Data);
simlog_aToeR         = squeeze(logsout_VehBus.Values.Chassis.SuspA1.WhlR.aToe.Data);
simlog_aCamberX      = squeeze(logsout_VehBus.Values.Chassis.SuspA1.WhlL.aCamberX.Data);
simlog_aToeX         = squeeze(logsout_VehBus.Values.Chassis.SuspA1.WhlL.aToeX.Data);
simlog_rigFz         = squeeze(logsout_VehBus.Values.Chassis.WhlL1.Testrig.Fz.Data);
%simlog_rigFz        = squeeze(logsout_VehBus.Values.Chassis.WhlL1.Fz.Data);
simlog_fBumpstop     = squeeze(logsout_VehBus.Values.Chassis.Damper.L1.FBumpstop.Data);
simlog_xRack         = squeeze(logsout_VehBus.Values.Chassis.SuspA1.Steer.xRack.Data);
simlog_FRack         = squeeze(logsout_VehBus.Values.Chassis.SuspA1.Steer.FRack.Data);
simlog_aWheel        = squeeze(logsout_VehBus.Values.Chassis.SuspA1.Steer.aWheel.Data);
simlog_trqTz         = squeeze(logsout_RdBus.Values.L1.fcp.tz.Data);
simlog_fLat          = squeeze(logsout_RdBus.Values.L1.fcp.fy.Data);
simlog_fLong         = squeeze(logsout_RdBus.Values.L1.fcp.fx.Data);
simlog_yCPtch        = squeeze(logsout_VehBus.Values.Chassis.WhlL1.Testrig.py.Data);

if(isfield(logsout_VehBus.Values.Chassis.SuspA1.LinkageL,'Shock'))
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.SuspA1.LinkageL.Shock.x.Data);
else
    % For decoupled suspension
    simlog_xSpring       = squeeze(logsout_VehBus.Values.Chassis.Spring.L1.xSpring.Data);
end

% Omit initial transient from bushings
simlog_tStart        = find(simlog_t>2,1);

Maneuver = evalin('base','Maneuver');
simlog_testPhases       = Maneuver.tRange;
simlog_zWChp            = 0;%Maneuver.zWChp.Value;
simlog_zOffsetBumpTest  = Maneuver.zOffsetBumpTest.Value;
simlog_qToeForCaster    = Maneuver.qToeForCaster.Value;

if(calcMetrics)
    % If testrig performs steer tests, get parameters for post-processing
    timeTestPhases = simlog_testPhases;
    Vehicle = evalin('base','Vehicle');
    [veh_track,veh_wheelbase, veh_mass] = sm_car_get_vehicle_params(Vehicle);
    tireK = sm_car_get_tire_params(Vehicle);
    simlog_zWChp = Vehicle.Chassis.SuspA1.Linkage.Upright.sWheelCentre.Value(3);
    % Get indices of simulation results for vertical test phase
    indToeCamb = intersect(find(simlog_t>=Maneuver.tRange.Jounce(1)),find(simlog_t<=Maneuver.tRange.Rebound(2)));
else
    % Else, generate toe and camber plots from simulation results
    indToeCamb = simlog_tStart:length(simlog_t);
end

indTravelBump    = find(simlog_fBumpstop>0.1);
indTravelRebound = find(simlog_fBumpstop<-0.1);
indExclude = union(indTravelBump,indTravelRebound);

indToeCambPlot = setdiff(indToeCamb,indExclude);

toeCurve.qToe   = simlog_aToe(indToeCambPlot);
toeCurve.pzTire = simlog_pzTire(indToeCambPlot)-simlog_pzTire(1);
camCurve.qCam   = simlog_aCamber(indToeCambPlot);
camCurve.pzTire = simlog_pzTire(indToeCambPlot)-simlog_pzTire(1);

% Calculate suspension metrics
if(calcMetrics)
    TSuspMetrics = sm_car_knc_calc_susp_metrics(...
        simlog_aToe, ...
        simlog_aCamber, ...
        simlog_aToeX,...
        simlog_aCamberX,...
        simlog_aToeR,...
        simlog_pxTire, ...
        simlog_pyTire, ...
        simlog_pzTire, ...
        timeTestPhases, ...
        simlog_qToeForCaster,...
        simlog_zOffsetBumpTest,...
        simlog_t,...
        simlog_zWChp,...
        simlog_rigFz,...
        simlog_fBumpstop,...
        simlog_xSpring,...
        simlog_xRack,...
        simlog_FRack,...
        simlog_aWheel,...
        simlog_trqTz,...
        simlog_fLat,...
        simlog_fLong,...
        simlog_yCPtch,...
        veh_track,...
        veh_wheelbase,...
        veh_mass,...
        tireK,...
        debugPlots);
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



