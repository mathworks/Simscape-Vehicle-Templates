% Script to generate lookup table data from multi-link suspension
%
% Using kinematic and compliance tests, we can generate the data necessary
% to replicate the kinematic and compliant behavior of a multi-link
% suspension.  The script below shows how to exercise a multi-link
% suspension and process the simulation results to get the data required to
% parameterize a lookup-table based kinematic joint.
%
% Copyright 2025 The MathWorks, Inc

% Open models and load vehicle data
open_system('sm_car')
open_system('testrig_susp_knc')
set_param('testrig_susp_knc/Axle/Config/Mechanism Configuration',...
    'GravityVector','[0 0 -9.80665]*0');

% Preset number
preset_num = '189'; % Double Wishbone

% Load preset
sm_car_load_vehicle_data('none',preset_num);

% --- Eliminate effects LUT suspension cannot capture
% Remove Anti Roll bar, not included in LUT Susp
Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,'None','SuspA1');

% Reduce mass of all parts not included in LUT suspension
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.m.Value = 0.01;
Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.m.Value = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Upright.m.Value       = 0.01;
Vehicle.Chassis.SuspA1.Linkage.TrackRod.m.Value      = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Upright.mAxle.Value   = 0.01;
Vehicle.Chassis.SuspA1.AntiRollBar.m.Value= 0.01;
Vehicle.Chassis.SuspA1.Linkage.Shock.mPiston.Value   = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Shock.mCylinder.Value = 0.01;
Vehicle.Chassis.SuspA1.Steer.Rack.m.Value            = 0.01;

% Turn off damping to make stiffness capture easier
dtemp = Vehicle.Chassis.Damper.Axle1.Damping.d.Value;
Vehicle.Chassis.Damper.Axle1.Damping.d.Value = 0;


%% Run simulation and extract necessary results 
% Load KnC Motion Profiles
Maneuver = MDatabase.KnC.Sedan_Hamba;

sim('testrig_susp_knc')
[TSuspMetricsLink,toeCurve,camCurve,pxCurve,pyCurve,strCurve, fzCurve, vrtCurve] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%% Extract a lookup table representing the kinematic behavior 
% Results are from the jounce-rebound portion of the Kinematics and Compliance test.

opts = struct;
opts.dupMethod    = "mean";     % merge duplicate x by averaging y
opts.gridMethod   = "uniform";  % evenly spaced breakpoints
opts.interpMethod = "pchip";    % shape-preserving cubic
opts.extrapMethod = "none";
opts.smoothY      = 0;

% Number of points for lookup tables
npts = 20;

% -- Generate Lookup Tables
[bp_px, tbl_px, ~] = buildLookupTable(pxCurve.pzTire, pxCurve.px, npts, opts);     % Long
[bp_py, tbl_py, ~] = buildLookupTable(pyCurve.pzTire, pyCurve.py, npts, opts);     % Lat
[bp_qz, tbl_qz, ~] = buildLookupTable(toeCurve.pzTire, toeCurve.qToe, npts, opts); % Toe
[bp_qx, tbl_qx, ~] = buildLookupTable(camCurve.pzTire, camCurve.qCam, npts, opts); % Camber
[bp_fz, tbl_fz, ~] = buildLookupTable(fzCurve.pzTire, fzCurve.fz, npts, opts);     % Spring Force

% Steering
[bp_aToeL, tbl_qToeL, ~] = buildLookupTable(strCurve.aWhl, strCurve.aToeL, npts, opts); 
[bp_aToeR, tbl_qToeR, ~] = buildLookupTable(strCurve.aWhl, strCurve.aToeR, npts, opts);

% Motion ratio, used for damping
[bp_vr, tbl_vr, info] = buildLookupTable(vrtCurve.pzTire, vrtCurve.vrt, npts, opts);

% Plot curves and lookup table points
figure(77)
subplot(221)
plot(pxCurve.px,pxCurve.pzTire,'LineWidth',1,'DisplayName','Test');
hold on
plot(tbl_px,bp_px,'ro','DisplayName','LUT')
hold off
title('Wheel Center pz vs. px')
xlabel('x Long (m)');
ylabel('z Height (m)');
legend('Location','Best')

subplot(222)
plot(pyCurve.py,pxCurve.pzTire,'LineWidth',1,'DisplayName','Test');
hold on
plot(tbl_py,bp_py,'ro','DisplayName','LUT')
hold off
title('Wheel Center pz vs. py')
xlabel('y Lateral (m)');
ylabel('z Height (m)');

subplot(223)
plot(toeCurve.qToe,toeCurve.pzTire,'LineWidth',1,'DisplayName','Test');
hold on
plot(tbl_qz,bp_qz,'ro','DisplayName','LUT')
hold off
title('Wheel Center pz vs. Toe')
xlabel('Toe Angle (deg)');
ylabel('z Height (m)');

subplot(224)
plot(camCurve.qCam,camCurve.pzTire,'LineWidth',1,'DisplayName','Test');
hold on
plot(tbl_qx,bp_qx,'ro','DisplayName','LUT')
hold off
title('Wheel Center pz vs. Camber')
xlabel('Camber Angle (deg)');
ylabel('z Height (m)');

figure(78)
plot(strCurve.aWhl, strCurve.aToeL,'LineWidth',1,'DisplayName','Test L');
hold on
plot(strCurve.aWhl, strCurve.aToeR,'LineWidth',1,'DisplayName','Test R');
plot(bp_aToeL,tbl_qToeL,'ko','DisplayName','LUT')
plot(bp_aToeR,tbl_qToeR,'kx','DisplayName','LUT')
hold off
title('q Handwheel pz vs. Toe')
xlabel('Toe Angle (deg)');
ylabel('z Height (m)');

figure(79)
subplot(121)
plot(fzCurve.fz, fzCurve.pzTire,'LineWidth',1,'DisplayName','Link');
hold on
plot(tbl_fz,bp_fz,'ro','DisplayName','LUT')
hold off
title('Fz Force vs Height (Spring)')
xlabel('Force (N)');
ylabel('z Height (m)');

%% Run simulation with damping and no spring to verify damping force
Vehicle.Chassis.Damper.Axle1.Damping.d.Value = dtemp;
ktemp = Vehicle.Chassis.Spring.Axle1.K.Value;
Vehicle.Chassis.Spring.Axle1.K.Value = 1e-3;
sim('testrig_susp_knc')
[~,~,~,~,~,~,fzCurveDS,~] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

% Add damping force to plot
figure(79)
subplot(122)
plot(fzCurveDS.fz, fzCurveDS.pzTire,'LineWidth',1,'DisplayName','Link');
title('Fz Force vs Height (Damper)')
xlabel('Force (N)');
ylabel('z Height (m)');

%% Load lookup table data into preset
sm_car_load_vehicle_data('none','239');

Vehicle.Chassis.SuspA1.LUT.Kinematics.aToe.Value  = tbl_qz;
Vehicle.Chassis.SuspA1.LUT.Kinematics.zaToe.Value = bp_qz;

Vehicle.Chassis.SuspA1.LUT.Kinematics.aCamber.Value  = tbl_qx;
Vehicle.Chassis.SuspA1.LUT.Kinematics.zaCamber.Value = bp_qx;

Vehicle.Chassis.SuspA1.LUT.Kinematics.xLong.Value  = tbl_px;
Vehicle.Chassis.SuspA1.LUT.Kinematics.zxLong.Value = bp_px;

Vehicle.Chassis.SuspA1.LUT.Kinematics.xLat.Value  = tbl_py;
Vehicle.Chassis.SuspA1.LUT.Kinematics.zxLat.Value = bp_py;

Vehicle.Chassis.SuspA1.LUT.Kinematics.aCaster.Value  = tbl_py*0;
Vehicle.Chassis.SuspA1.LUT.Kinematics.zaCaster.Value = bp_py;

Vehicle.Chassis.SuspA1.LUT.Spring.f.Value = tbl_fz;
Vehicle.Chassis.SuspA1.LUT.Spring.x.Value = bp_fz;

% Damping coefficient is taken directly from multibody model
Vehicle.Chassis.SuspA1.LUT.Spring.d.Value = 5500;

% Motion ratio, used to determine damping force
Vehicle.Chassis.SuspA1.LUT.Spring.vrt.Value = tbl_vr;
Vehicle.Chassis.SuspA1.LUT.Spring.zvrt.Value = bp_vr;

%% Test LUT suspension against multilink suspension
 
% Test with no spring to get force from damper
Vehicle.Chassis.SuspA1.LUT.Spring.f.Value    = tbl_fz*0;
Vehicle.Chassis.SuspA1.LUT.Spring.x.Value    = bp_fz;
Vehicle.Chassis.SuspA1.LUT.Spring.vrt.Value  = tbl_vr;
Vehicle.Chassis.SuspA1.LUT.Spring.zvrt.Value = bp_vr;
sim('testrig_susp_knc')
[~,~,~,~,~, ~, fzCurveLUD,~] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

% Test with spring and damper
Vehicle.Chassis.SuspA1.LUT.Spring.f.Value    = tbl_fz;
Vehicle.Chassis.SuspA1.LUT.Spring.x.Value    = bp_fz;
Vehicle.Chassis.SuspA1.LUT.Spring.vrt.Value  = tbl_vr;
Vehicle.Chassis.SuspA1.LUT.Spring.zvrt.Value = bp_vr;
sim('testrig_susp_knc')
[TSuspMetrics,toeCurveLUT,camCurveLUT,pxCurveLUT,pyCurveLUT, strCurveLUT, fzCurveLUT,vrtCurveLUT] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);


% Add results from LUT KnC test to previous plots
figure(77)
subplot(221)
hold on
plot(pxCurveLUT.px,pxCurveLUT.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off
legend('Location','Best')

subplot(222)
hold on
plot(pyCurveLUT.py,pxCurveLUT.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off

subplot(223)
hold on
plot(toeCurveLUT.qToe,toeCurveLUT.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off

subplot(224)
hold on
plot(camCurveLUT.qCam,camCurveLUT.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off

figure(79)
subplot(121)
hold on
plot(fzCurveLUT.fz, fzCurveLUT.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off

subplot(122)
hold on
plot(fzCurveLUD.fz, fzCurveLUD.pzTire,'k--','LineWidth',1,'DisplayName','LUT');
hold off

%% Test on Fishhook Maneuver
%sm_car_load_vehicle_data('none','239');

% Use Simple suspension on rear and 1D Drivetrain
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1D2_1D_1D_HA');

% Set internal masses to very low values
Vehicle.Chassis.SuspA1.LUT.Axle.mAxle.Value = 0.01;
Vehicle.Chassis.SuspA1.LUT.UnsprungMass.m.Value = 0.01;

% Select test for comparison
sm_car_config_maneuver('sm_car','Fishhook');
%sm_car_config_maneuver('sm_car','Low Speed Steer');
%sm_car_config_maneuver('sm_car','None');

% Select solver with tightest convergence
set_param('sm_car','SolverName','daessc')

% Simulate
sim('sm_car')

% Extract results
sim_px_LUT  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pxVeh');
sim_py_LUT  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pyVeh');
sim_pz_LUT  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pzVeh');
sim_t_LUT   = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_fz_LUT  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'fzWhl');
sim_rll_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aRoll');
sim_pit_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aPitch');
sim_toe_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'toeWhl');
sim_wpz_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pzWhl');
sim_xSp_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'xShock');
sim_vveh_LUT = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'vVeh');

% Load multi-link suspension
sm_car_load_vehicle_data('none',preset_num);

% Use Simple suspension on rear, 1D Drivetrain
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'Simple15DOF_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_D1D2_1D_1D_HA');

% Remove Anti Roll bar, not included in LUT Susp
Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,'None','SuspA1');

% Reduce mass of all parts not included in LUT suspension
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.m.Value = 0.01;
Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.m.Value = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Upright.m.Value       = 0.01;
Vehicle.Chassis.SuspA1.Linkage.TrackRod.m.Value      = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Upright.mAxle.Value   = 0.01;
Vehicle.Chassis.SuspA1.AntiRollBar.m.Value= 0.01;
Vehicle.Chassis.SuspA1.Linkage.Shock.mPiston.Value   = 0.01;
Vehicle.Chassis.SuspA1.Linkage.Shock.mCylinder.Value = 0.01;
Vehicle.Chassis.SuspA1.Steer.Rack.m.Value            = 0.01;

% Run simulation
sim('sm_car')

% Extract results
sim_px_Link  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pxVeh');
sim_py_Link  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pyVeh');
sim_pz_Link  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pzVeh');
sim_t_Link   = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_fz_Link  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'fzWhl');
sim_rll_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aRoll');
sim_pit_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aPitch');
sim_toe_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'toeWhl');
sim_wpz_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pzWhl');
sim_xSp_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'xShock');
sim_vveh_Link = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'vVeh');

% -- Create Comparison Plots

% Plot vehicle position
figure(178); set(gcf,'Name','h1_vehicle_pxy')
subplot(221)
plot(sim_px_LUT.data,sim_py_LUT.data,'LineWidth',1,'DisplayName','LUT')
hold on
plot(sim_px_Link.data,sim_py_Link.data,'--','LineWidth',1,'DisplayName','Link')
hold off
grid on
legend('Location','Best')
axis equal
title('Vehicle Position')
xlabel('X (m)')
ylabel('Y (m)')
mxX = max([sim_px_LUT.data;sim_px_Link.data])*1.1;
set(gca,'XLim',[100 mxX]);

subplot(222)
plot(sim_t_LUT.data,sim_vveh_LUT.data,'LineWidth',1,'DisplayName','LUT')
hold on
plot(sim_t_Link.data,sim_vveh_Link.data,'--','LineWidth',1,'DisplayName','Link')
hold off
xlabel('Time (s)')
ylabel('Vehicle Spd (m/s)')
title ('Vehicle Speed')
grid on

subplot(223)
plot(sim_t_Link.data,sim_toe_Link.data(:,1)*180/pi,'LineWidth',1,'DisplayName','Link')
hold on
plot(sim_t_LUT.data,sim_toe_LUT.data(:,1)*180/pi,'--','LineWidth',1,'DisplayName','LUT')
hold off
title('Toe Angle')
grid on
xlabel('Time (s)')
ylabel('Toe Angle (deg)')

subplot(224)
sim_resX = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_resY = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aSteer');
plot(sim_resX.data,sim_resY.data)
xlabel('Time (s)')
ylabel('Steer Whl Angle (rad)')
title ('Steer Whl Angle')
grid on



% Plot Tire Vertical Force
figure(179); set(gcf,'Name','h1_whl_fz')
ah(1) = subplot(121);
plot(sim_t_LUT.data,sim_fz_LUT.data')
text(0.2,0.09,sprintf('%3.3f',sum(sim_fz_LUT.data(end,:))),'Units','normalized')
title('Fz, LUT')
grid on

ah(2) = subplot(122);
plot(sim_t_Link.data,sim_fz_Link.data)
text(0.2,0.09,sprintf('%3.3f',sum(sim_fz_Link.data(end,:))),'Units','normalized')
title('Fz, Link')
grid on

linkaxes(ah,'y')

% Plot Chassis Roll Angle
figure(180); set(gcf,'Name','h1_vehicle_roll')
plot(sim_t_LUT.data,sim_rll_LUT.data,'LineWidth',1,'DisplayName','LUT')
hold on
plot(sim_t_Link.data,sim_rll_Link.data,'LineWidth',1,'DisplayName','Link')
hold off
title('Roll Angle')
legend('Location','Best')
grid on


% Plot Chassis Pitch Angle
figure(181); set(gcf,'Name','h1_vehicle_pitch')
plot(sim_t_LUT.data,sim_pit_LUT.data*180/pi,'LineWidth',1,'DisplayName','LUT')
hold on
plot(sim_t_Link.data,sim_pit_Link.data*180/pi,'LineWidth',1,'DisplayName','Link')
hold off
title('Pitch Angle')
legend('Location','Best')
grid on
xlabel('Time (s)')
ylabel('Pitch Angle (deg)')


% Plot Front Left Toe Angle
figure(182); set(gcf,'Name','h1_whl_toe')
ah2(2) = subplot(122);
plot(sim_t_Link.data,sim_toe_Link.data(:,1:2)*180/pi,'LineWidth',1)
title('Toe Angle, Link')
grid on
xlabel('Time (s)')
ylabel('Toe Angle (deg)')
ah2(1) = subplot(121);
plot(sim_t_LUT.data,sim_toe_LUT.data(:,1:2)*180/pi,'LineWidth',1)
title('Toe Angle, LUT')
xlabel('Time (s)')
ylabel('Toe Angle (deg)')
grid on
linkaxes(ah2,'xy')

% Plot vehicle position z
figure(183); set(gcf,'Name','h1_vehicle_pz')
plot(sim_t_LUT.data,sim_pz_LUT.data,'LineWidth',1,'DisplayName','LUT')
hold on
plot(sim_t_Link.data,sim_pz_Link.data,'LineWidth',1,'DisplayName','Link')
hold off
grid on
xlabel('Time (s)')
ylabel('Position in z (m)')
title('Vehicle Height')
legend('Location','Best')

% Plot wheel vertical position
figure(184); set(gcf,'Name','h1_wheel_pz')
ah3(1) = subplot(121);
plot(sim_t_LUT.data,sim_wpz_LUT.data,'LineWidth',1,'DisplayName','LUT')
title('Whl Ctr z, LUT')
xlabel('Time (s)')
ylabel('Position in z (m)')
grid on
ah3(2) = subplot(122);
plot(sim_t_Link.data,sim_wpz_Link.data,'LineWidth',1,'DisplayName','Link')
grid on
title('Whl Ctr z, Link')
xlabel('Time (s)')
ylabel('Position in z (m)')
linkaxes(ah3,'xy')


% Plot Spring Extension
figure(185); set(gcf,'Name','h1_xSpring')
ah4(2) = subplot(122);
plot(sim_t_Link.data,(sim_xSp_Link.data-sim_xSp_Link.data(1,:))./[-0.7653 -0.7653 1 1],'LineWidth',1,'DisplayName','Link')
grid on
title('xSpring, Link')
xlabel('Time (s)')
ylabel('Extension (m)')
ah4(1) = subplot(121);
plot(sim_t_LUT.data,sim_xSp_LUT.data-sim_xSp_LUT.data(1,:),'LineWidth',1,'DisplayName','LUT')
grid on
title('xSpring, LUT')
xlabel('Time (s)')
ylabel('Extension (m)')
linkaxes(ah4,'xy')

