%% Compare roll center calculation methods

% Open model
mdlname = 'testrig_susp_knc';
open_system(mdlname);

% Turn off roll center visualization
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','Off');

%% Load sample hps and configure KnC tests
sm_car_load_vehicle_data('none','218');
SuspField = 'MacPherson';
ManeuverForLUT  = sm_car_maneuverdata_knc(0.100,-0.100,0.01,1.0,0.10,500,1200,1200,1200,1200,-0.3);
ManeuverForTest = sm_car_maneuverdata_knc(0.095,-0.095,0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);

% -- Adjust hardpoints so that it is a case that provides the same answer
%    for both geometric and dynamic methods

% Ensure Front and Rear inboard points on each arm are on same longitudinal axis
Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(2) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(2);

Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(2) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(2);
Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(3) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(3);

Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value(1) = Vehicle.Chassis.SuspA1.Linkage.Shock.sBottom.Value(1);

% Ensure no bump steer - track rod parallel to lower arm
Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value(2)    = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(2);
Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value(3)    = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(3);
Vehicle.Chassis.SuspA1.Steer.Rack.sOutboard.Value(2)         = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(2);
Vehicle.Chassis.SuspA1.Steer.Rack.sOutboard.Value(3)         = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(3);
Vehicle.Chassis.SuspA1.Steer.Rack.sMount.Value(3)            = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(3);
Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value(2)   = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value(2);
Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value(3)   = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value(3);


%% Run KnC test for desired lookup table range
Maneuver = ManeuverForLUT;
sim(mdlname)
AxNum = 1;
[TSuspMetrics,~,~,KNCres] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,AxNum,false,true,false);

%% Plot Motions in Test

figure(101);
ah(1) = subplot(121);
plot(KNCres.Bounce.PAR.pyPtchR,KNCres.Bounce.PAR.pzPtchR);
title('Contact Patch Path (RIGHT)')
axis equal
grid on
ah(2) = subplot(122);
plot(KNCres.Bounce.PAR.pyPtch,KNCres.Bounce.PAR.pzPtch);
axis equal
grid on
title('Contact Patch Path (LEFT)')
linkaxes(ah,'y')

%% Assemble Results, Contact Point Motion Method
% Left sweep
% zWL    : Nx1 wheel center height (e.g., wheel center pz)
% cpYZL  : Nx2 [y z] contact patch
% Right sweep
% zWR    : Mx1 wheel center height
% cpYZR  : Mx2 [y z] contact patch

% Time range for vertical wheel position
tJncReb = [11.1 21.5];

% Get indices of simulation results for this range
ind1    = find(KNCres.Bounce.PAR.time>=tJncReb(1),1);
ind2    = find(KNCres.Bounce.PAR.time>=tJncReb(2),1);

% Extract relevant results
zWL_raw  = KNCres.Bounce.PAR.pzWC(ind1:ind2);
zWR_raw  = KNCres.Bounce.PAR.pzWCR(ind1:ind2);
cpYL_raw = KNCres.Bounce.PAR.pyPtch(ind1:ind2);
cpYR_raw = KNCres.Bounce.PAR.pyPtchR(ind1:ind2);
cpZL_raw = KNCres.Bounce.PAR.pzPtch(ind1:ind2);
cpZR_raw = KNCres.Bounce.PAR.pzPtchR(ind1:ind2);

% Get evenly spaced data points over range of wheel heights
zWLmin = min(zWL_raw);
zWLmax = max(zWL_raw);
zWL    = linspace(zWLmin,zWLmax,200)';
zWR    = interp1(zWL_raw,zWR_raw,zWL);
cpYL   = interp1(zWL_raw,cpYL_raw,zWL);
cpYR   = interp1(zWL_raw,cpYR_raw,zWL);
cpZL   = interp1(zWL_raw,cpZL_raw,zWL);
cpZR   = interp1(zWL_raw,cpZR_raw,zWL);

cpYZL = [cpYL cpZL];
cpYZR = [cpYR cpZR];

%% Generate Lookup Table
opts = struct;
opts.Window     = 5;     % robust for measured data
opts.Method     = 'lsq';
opts.SmoothSpan = 5;      % optional (0 to disable)
opts.UnitsScale = 1;   % if y/z in mm -> meters (set 1.0 if already meters)

opts.Plot.Enable    = false;
opts.Plot.Side      = "both";     % optional
opts.Plot.RCOverlay = true;       % <-- enables the new plot
[tire_radius, ~] = sm_car_get_TireRadius(Vehicle);
indPlot = find(zWL>=tire_radius,1);
opts.Plot.QueryZWL  = zWL(indPlot);    % pick a wheel height you want
opts.Plot.QueryZWR  = zWR(indPlot);    % pick a wheel height you want

% For debugging
%fprintf('zWL: unique=%d, span=%g\n', numel(unique(zWL)), max(zWL)-min(zWL));
%fprintf('zWR: unique=%d, span=%g\n', numel(unique(zWR)), max(zWR)-min(zWR));
%fprintf('cpL span: y=%g, z=%g\n', max(cpYZL(:,1))-min(cpYZL(:,1)), max(cpYZL(:,2))-min(cpYZL(:,2)));
%fprintf('cpR span: y=%g, z=%g\n', max(cpYZR(:,1))-min(cpYZR(:,1)), max(cpYZR(:,2))-min(cpYZR(:,2)));

% Generate Roll Center lookup table for left and right wheel center heights
lut = buildRollCenterLUTzWLzWR(zWL, cpYZL, zWR, cpYZR, opts);

%% Test LUT
% Evaluate RC for any combination of wheel center heights:
%zWLq = linspace(min(zWL), max(zWL), 20);
%zWRq = linspace(min(zWR), max(zWR), 20);
%[ZWLq, ZWRq] = meshgrid(zWLq, zWRq);

%RC = lut.eval(ZWLq, ZWRq);       % size 20x20x2
%Yrc = RC(:,:,1);
%Zrc = RC(:,:,2);

%% Rerun with smaller range
Maneuver = ManeuverForTest;
sim(mdlname)
[TSuspMetrics,~,~,KNCres] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,1,false,true,false);

%% Obtain Roll Center using Inst Ctr Method for previous KnC test
simlog_pzTire  = logsout_sm_car_testrig_quarter_car.get('VehBus').Values.Chassis.WhlL1.xyz.Data(:,3);
simlog_pzTireR = logsout_sm_car_testrig_quarter_car.get('VehBus').Values.Chassis.WhlR1.xyz.Data(:,3);
simlog_time    = logsout_sm_car_testrig_quarter_car.get('VehBus').Values.Chassis.WhlL1.xyz.Time;

RC = lut.eval(simlog_pzTire, simlog_pzTireR);
Yrc = RC(:,:,1);
Zrc = RC(:,:,2);
hp_RC_IC = [zeros(size(Yrc)) Yrc Zrc];

%% Calculate Roll Center Location using Geometric Method
% Extract simulation results for lower arm inboard Revolute joints
qxLL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_LA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzLL = qxLL*0;

qxLR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_LA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzLR = qxLR*0;
qt   = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_LA.Rigid_1Rev.Revolute_Ac.Rz.q.series.time;

% Extract simulation results for shock upper Gimbal joint
qxSUL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Rx.q.series.values;
qySUL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Ry.q.series.values;
qzSUL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Rz.q.series.values;
qxSUR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Rx.q.series.values;
qySUR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Ry.q.series.values;
qzSUR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_Shock_Top.Rigid_Gimbal.Gimbal_HP_Spring.Rz.q.series.values;

qSUL = [-qxSUL qySUL qzSUL];
qSUR = [-qxSUR qySUR qzSUR];

% Extract simulation results for shock prismatic joint
pzShkL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).Shock.Prismatic_Spring.Pz.p.series.values;
pzShkR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).Shock.Prismatic_Spring.Pz.p.series.values;

% Get contact patch locations in time
cpL = logsout_sm_car_testrig_quarter_car.get('VehBus').Values.Chassis.WhlL1.Testrig.cp;
cpR = logsout_sm_car_testrig_quarter_car.get('VehBus').Values.Chassis.WhlR1.Testrig.cp;
hp_cpL = [cpL.px.Data cpL.py.Data cpL.pz.Data];
hp_cpR = [cpR.px.Data cpR.py.Data cpR.pz.Data];

% -- Get Chassis side HP locations in time
hp = [];

% Get offset due to difference wheel center hp height and tire radius
sWctrSet = sm_car_get_sWheelCentre(Vehicle);
sWCtr     = sWctrSet(1,:);

tire_radii = sm_car_get_TireRadius(Vehicle);
tire_radius = tire_radii(1);
tire_WC_Offset = [0 0 tire_radius-sWCtr(3)];

% Chassis HPs in World coordinates (offset tire radius-wheel center height)
hp.L.LCA_in      = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value+tire_WC_Offset;
hp.L.LCA_out     = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value+tire_WC_Offset;
hp.L.strutTop    = Vehicle.Chassis.SuspA1.Linkage.Shock.sTop.Value             +tire_WC_Offset;
hp.L.strutBottom = Vehicle.Chassis.SuspA1.Linkage.Shock.sBottom.Value          +tire_WC_Offset;

% Mirror
hp.R.LCA_in      = hp.L.LCA_in.*[1 -1 1];
hp.R.LCA_out     = hp.L.LCA_out.*[1 -1 1];
hp.R.strutTop    = hp.L.strutTop.*[1 -1 1];
hp.R.strutBottom = hp.L.strutBottom.*[1 -1 1];

% Get initial values for hp locations
% Used to calculate initial offset angle
hp_LAiL0 = hp.L.LCA_in;
hp_LAoL0 = hp.L.LCA_out;
hp_SttL0 = hp.L.strutTop;
hp_StbL0 = hp.L.strutBottom;

hp_LAiR0 = hp.R.LCA_in;
hp_LAoR0 = hp.R.LCA_out;
hp_SttR0 = hp.R.strutTop;
hp_StbR0 = hp.R.strutBottom;

% These are hps/locations whose positions must be derived based on joint angles
hp_LAoL_t = [];
hp_StbL_t = [];
hp_LAoR_t = [];
hp_StbR_t = [];
hp_RC_GM  = [];

% Orientation of upper strut joint must be obtained (left and right)
vec = [0 0 1];
uvec_bt = (hp_SttL0-hp_StbL0)/norm(hp_SttL0-hp_StbL0);
rotaxisL = cross(vec,uvec_bt);
rotangleL = acos(dot(vec,uvec_bt));

vec = [0 0 1];
uvec_bt = (hp_SttR0-hp_StbR0)/norm(hp_SttR0-hp_StbR0);
rotaxisR = cross(vec,uvec_bt);
rotangleR = acos(dot(vec,uvec_bt));

% Loop over time vector to obtain result
for i = 1:length(qt)
    % Obtain position of non-chassis hardpoint locations using joint angles
    hp_LAoL_t(:,i) = calcLinkHPAxle(hp_LAiL0',hp_LAoL0',qxLL(i), qzLL(i));
    hp_LAoR_t(:,i) = calcLinkHPAxle(hp_LAiR0',hp_LAoR0',qxLR(i), qzLR(i));
    hp_StbL_t(:,i) = rodTipFromGimbalAndPrismatic( ...
        hp_SttL0, hp_StbL0, qSUL(i,:)*pi/180, pzShkL(i)-pzShkL(1), rotaxisL, rotangleL*0,"AngleUnit","rad");
    hp_StbR_t(:,i) = rodTipFromGimbalAndPrismatic( ...
        hp_SttR0, hp_StbR0, qSUR(i,:)*pi/180, pzShkR(i)-pzShkR(1), rotaxisR, rotangleR*0,"AngleUnit","rad");

    % Assemble structure of hardpoint locations
    hp.L.LCA_out      = hp_LAoL_t(:,i)';
    hp.R.LCA_out      = hp_LAoR_t(:,i)';
    hp.L.strutBottom  = hp_StbL_t(:,i)';
    hp.R.strutBottom  = hp_StbR_t(:,i)';
    hp.L.contactPatch = hp_cpL(i,:);
    hp.R.contactPatch = hp_cpR(i,:);
    
    % Calculate roll center location
    rc     = rollCenterFromHardpoints('macpherson', hp);

    % Extract roll center position in Y-Z plane
    hp_RC_GM(i,:) = [0 rc.RC_YZ];
end

%% Plot Comparison in Time
figure(888)
ahRC(1) = subplot(211);
plot(qt,hp_RC_GM(:,3),'DisplayName','Geometric Method')
hold on
plot(qt,hp_RC_IC(:,3),'--','DisplayName','CP Motion Method')
hold off
xlabel('Time (s)')
ylabel('Roll Center Height (m)')
title('Compare Roll Center Calculation Methods')

legend('Location','Best')

ahRC(2) = subplot(212);
plot(qt,simlog_pzTire,'k','DisplayName','Height WCL')
linkaxes(ahRC,'x')

%%  Rerun KnC test and animate roll center
set_param([mdlname '/Axle/Visuals'],'time_vector','qt','xyz_matrix','hp_RC_IC')
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','On');

sim(mdlname)