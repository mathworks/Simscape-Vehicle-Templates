% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%
% Copyright 2018-2024 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h2_sm_car', 'var') || ...
        ~isgraphics(h2_sm_car, 'figure')
    h2_sm_car = figure('Name', 'sm_car');
end
figure(h2_sm_car)
clf(h2_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
hasResults = false;
if(hasChild(simlog_sm_car.Vehicle.Vehicle.Chassis.Spring,'Interconnected'))
    if(hasChild(simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle1,'AsymmetricAirOilPiston'))
        SprFL = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle1.AsymmetricAirOilPiston.Spring_L;
        SprFR = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle1.AsymmetricAirOilPiston.Spring_R;
        SprRL = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle2.AirOilPiston.Spring_L;
        SprRR = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle2.AirOilPiston.Spring_R;
        StrutFL = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle1.AsymmetricAirOilPiston.Spring_L;
        StrutFR = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle1.AsymmetricAirOilPiston.Spring_R;
        StrutRL = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle2.AirOilPiston.Spring_L;
        StrutRR = simlog_sm_car.Vehicle.Vehicle.Chassis.Spring.Interconnected.Springs_Axle2.AirOilPiston.Spring_R;
        hasResults = true;
    end
end
if(hasResults)
    spFL_GasStiffp  = SprFL.Chamber_Gas_Spring_Stiff.p_I.series;
    spFL_GasSoftp   = SprFL.Chamber_Gas_Spring_Soft.p_I.series;
    spFL_OilStiffp  = SprFL.Chamber_Oil_Stiff.p_I.series;
    spFL_OilSoftp   = SprFL.Chamber_Oil_Soft.p_I.series;
    stFL_p          = StrutFL.Chamber_Strut.p_I.series;

    spFR_GasStiffp  = SprFR.Chamber_Gas_Spring_Stiff.p_I.series;
    spFR_GasSoftp   = SprFR.Chamber_Gas_Spring_Soft.p_I.series;
    spFR_OilStiffp  = SprFR.Chamber_Oil_Stiff.p_I.series;
    spFR_OilSoftp   = SprFR.Chamber_Oil_Soft.p_I.series;
    stFR_p          = StrutFR.Chamber_Strut.p_I.series;

    spRL_GasStiffp  = SprRL.Chamber_Gas_Spring_Stiff.p_I.series;
    spRL_GasSoftp   = SprRL.Chamber_Gas_Spring_Soft.p_I.series;
    spRL_OilStiffp  = SprRL.Chamber_Oil_Stiff.p_I.series;
    spRL_OilSoftp   = SprRL.Chamber_Oil_Soft.p_I.series;
    stRL_p          = StrutRL.Chamber_Strut.p_I.series;

    spRR_GasStiffp  = SprRR.Chamber_Gas_Spring_Stiff.p_I.series;
    spRR_GasSoftp   = SprRR.Chamber_Gas_Spring_Soft.p_I.series;
    spRR_OilStiffp  = SprRR.Chamber_Oil_Stiff.p_I.series;
    spRR_OilSoftp   = SprRR.Chamber_Oil_Soft.p_I.series;
    stRR_p          = StrutRR.Chamber_Strut.p_I.series;

    ah(1) = subplot(2,1,1);
    plot(spFL_GasStiffp.time,spFL_GasStiffp.values,'LineWidth',1,'DisplayName','L Gas Stiff');
    hold on
    plot(spFR_GasStiffp.time,spFR_GasStiffp.values,'LineWidth',1,'DisplayName','R Gas Stiff');
    plot(spFL_GasSoftp.time,spFL_GasSoftp.values,'--','LineWidth',1,'DisplayName','L Gas Soft');
    plot(spFR_GasSoftp.time,spFR_GasSoftp.values,'--','LineWidth',1,'DisplayName','R Gas Soft');
    plot(stFL_p.time,stFL_p.values,'-.','LineWidth',1,'DisplayName','L Strut');
    plot(stFR_p.time,stFR_p.values,'-.','LineWidth',1,'DisplayName','R Strut');
    hold off
    ylabel('Pressure (MPa)')
    title('Pressures, Front Axle')
    legend('Location','Best')

    ah(2) = subplot(2,1,2);
    plot(spRL_GasStiffp.time,spRL_GasStiffp.values,'LineWidth',1,'DisplayName','L Gas Stiff');
    hold on
    plot(spRR_GasStiffp.time,spRR_GasStiffp.values,'LineWidth',1,'DisplayName','R Gas Stiff');
    plot(spRL_GasSoftp.time,spRL_GasSoftp.values,'--','LineWidth',1,'DisplayName','L Gas Soft');
    plot(spRR_GasSoftp.time,spRR_GasSoftp.values,'--','LineWidth',1,'DisplayName','R Gas Soft');
    plot(stRL_p.time,stRL_p.values,'-.','LineWidth',1,'DisplayName','L Strut');
    plot(stRR_p.time,stRR_p.values,'-.','LineWidth',1,'DisplayName','R Strut');
    hold off
    ylabel('Pressure (MPa)')
    xlabel('Time (sec)')
    title('Pressures, Rear Axle')
    legend('Location','Best')

    grid(ah,'on')
    linkaxes(ah)

    delvars = setdiff(who('logsout_*'),'logsout_sm_car');
    clear(delvars{:},'delvars');

    clear temp_colororder
end