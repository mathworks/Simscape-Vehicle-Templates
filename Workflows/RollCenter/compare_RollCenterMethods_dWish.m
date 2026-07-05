%% Open model, simulate
mdlname = 'testrig_susp_knc';
open_system(mdlname);

% Turn off roll center visualization
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','Off');

%% Load sample hps and configure KnC tests
suspCheckInd = 1; % Pick suspension from set below
switch suspCheckInd
    case 1
        sm_car_load_vehicle_data('none','189');
        SuspField = 'DoubleWishbone';
        ManeuverForLUT  = sm_car_maneuverdata_knc(0.15, -0.15, 0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);
        ManeuverForTest = sm_car_maneuverdata_knc(0.145,-0.145,0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);
    case 2
        sm_car_load_vehicle_data('none','000');
        SuspField = 'DoubleWishbone';
        ManeuverForLUT  = sm_car_maneuverdata_knc(0.15, -0.15, 0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);
        ManeuverForTest = sm_car_maneuverdata_knc(0.145,-0.145,0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);
    case 3
        sm_car_load_vehicle_data('none','198');
        SuspField = 'DoubleWishbone_Pullrod';
        ManeuverForLUT  = sm_car_maneuverdata_knc(0.05 ,-0.03 ,0.01,1.25,0.03,500,1200,1200,1200,1200,-0.3);
        ManeuverForTest = sm_car_maneuverdata_knc(0.045,-0.025,0.01,1.25,0.03,500,1200,1200,1200,1200,-0.3);
end

% -- Adjust hardpoints so that it is a case that provides the same answer
%    for both geometric and dynamic methods
% Ensure Front and Rear inboard points in same YZ plane
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value(1) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(1);
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardR.Value(1) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(1);

% Ensure Front and Rear inboard points on each arm are on same longitudinal axis
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value(2) = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardR.Value(2);
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value(3) = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardR.Value(3);

Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(2) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(2);
Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value(3) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value(3);

% Ensure vertical uprights
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sOutboard.Value(1) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value(1);
Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sOutboard.Value(2) = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value(2);

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

% Extract simulation results for inboard Revolute joints
qxUL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_UA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzUL = qxUL*0;
qxLL = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_LA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzLL = qxLL*0;

qxUR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_UA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzUR = qxUR*0;
qxLR = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_R.(SuspField).HP_LA.Rigid_1Rev.Revolute_Ac.Rz.q.series.values;
qzLR = qxLR*0;

qt   = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Linkage.Linkage_L.(SuspField).HP_UA.Rigid_1Rev.Revolute_Ac.Rz.q.series.time;

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
hp.L.UCA_in = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value+tire_WC_Offset;
hp.L.UCA_out= Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sOutboard.Value+tire_WC_Offset;
hp.L.LCA_in = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value+tire_WC_Offset;
hp.L.LCA_out= Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value+tire_WC_Offset;

% Mirror
hp.R.UCA_in = hp.L.UCA_in.*[1 -1 1];
hp.R.UCA_out= hp.L.UCA_out.*[1 -1 1];
hp.R.LCA_in = hp.L.LCA_in.*[1 -1 1];
hp.R.LCA_out= hp.L.LCA_out.*[1 -1 1];

% Get initial values for hp locations
% Used to calculate initial offset angle
hp_UAiL0 = hp.L.UCA_in;
hp_UAoL0 = hp.L.UCA_out;

hp_LAiL0 = hp.L.LCA_in;
hp_LAoL0 = hp.L.LCA_out;

hp_UAiR0 = hp.R.UCA_in;
hp_UAoR0 = hp.R.UCA_out;

hp_LAiR0 = hp.R.LCA_in;
hp_LAoR0 = hp.R.LCA_out;

% These are hps/locations whose locations must be derived based on joint angles
hp_UAoL_t = [];
hp_LAoL_t = [];
hp_UAoR_t = [];
hp_LAoR_t = [];
hp_RC_GM  = [];

% Loop over time vector to obtain result
for i = 1:length(qxUL)
    % Obtain position of outboard hardpoint locations using joint angles
    hp_UAoL_t(:,i) = calcLinkHPAxle(hp_UAiL0',hp_UAoL0',qxUL(i), qzUL(i));
    hp_LAoL_t(:,i) = calcLinkHPAxle(hp_LAiL0',hp_LAoL0',qxLL(i), qzLL(i));
    hp_UAoR_t(:,i) = calcLinkHPAxle(hp_UAiR0',hp_UAoR0',qxUR(i), qzUR(i));
    hp_LAoR_t(:,i) = calcLinkHPAxle(hp_LAiR0',hp_LAoR0',qxLR(i), qzLR(i));

    % Assemble structure of hardpoint locations
    hp.L.UCA_out = hp_UAoL_t(:,i)';
    hp.L.LCA_out = hp_LAoL_t(:,i)';
    hp.R.UCA_out = hp_UAoR_t(:,i)';
    hp.R.LCA_out = hp_LAoR_t(:,i)';
    hp.L.contactPatch = hp_cpL(i,:);
    hp.R.contactPatch = hp_cpR(i,:);
    
    % Calculate roll center location
    rc     = rollCenterFromHardpoints('doubleWishbone', hp);

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