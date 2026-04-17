%% Open model, simulate
mdlname = 'testrig_susp_knc';
open_system(mdlname);

% Turn off roll center visualization
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','Off');

%% Load sample hps and configure KnC tests
vehInd = '189';
sm_car_load_vehicle_data('none',vehInd);
SuspField = 'DoubleWishbone';
ManeuverForLUT  = sm_car_maneuverdata_knc(0.15, -0.15, 0.01,0.05,0.03,500,1200,1200,1200,1200,-0.3);

%% Run KnC test for desired lookup table range - FRONT AXLE
Maneuver = ManeuverForLUT;
set_param([mdlname '/Axle'],'AxNum','Front'); AxNum=1;
sim(mdlname)
[TSuspMetrics,~,~,KNCresF] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,AxNum,false,true,false);

%% Assemble Results, Contact Point Motion Method - FRONT AXLE
% Left sweep
% zWL    : Nx1 wheel center height (e.g., wheel center pz)
% cpYZL  : Nx2 [y z] contact patch
% Right sweep
% zWR    : Mx1 wheel center height
% cpYZR  : Mx2 [y z] contact patch

% Time range for vertical wheel position
tJncReb = [11.1 21.5];

% Get indices of simulation results for this range
ind1    = find(KNCresF.Bounce.PAR.time>=tJncReb(1),1);
ind2    = find(KNCresF.Bounce.PAR.time>=tJncReb(2),1);

% Extract relevant results
zWL_raw  = KNCresF.Bounce.PAR.pzWC(ind1:ind2);
zWR_raw  = KNCresF.Bounce.PAR.pzWCR(ind1:ind2);
cpYL_raw = KNCresF.Bounce.PAR.pyPtch(ind1:ind2);
cpYR_raw = KNCresF.Bounce.PAR.pyPtchR(ind1:ind2);
cpZL_raw = KNCresF.Bounce.PAR.pzPtch(ind1:ind2);
cpZR_raw = KNCresF.Bounce.PAR.pzPtchR(ind1:ind2);

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

%% Generate Lookup Table - FRONT AXLE
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
lutA1 = buildRollCenterLUTzWLzWR(zWL, cpYZL, zWR, cpYZR, opts);

%% Load sample hps and configure KnC tests
set_param([mdlname '/Axle'],'AxNum','Rear'); AxNum=2;
ManeuverForLUT  = sm_car_maneuverdata_knc(0.100,-0.100,0.01,1.0,0.10,500,1200,1200,1200,1200,-0.3);
sim(mdlname)
[TSuspMetrics,~,~,KNCresR] = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,AxNum,false,true,false);

%% Assemble Results, Contact Point Motion Method - REAR AXLE
% Left sweep
% zWL    : Nx1 wheel center height (e.g., wheel center pz)
% cpYZL  : Nx2 [y z] contact patch
% Right sweep
% zWR    : Mx1 wheel center height
% cpYZR  : Mx2 [y z] contact patch

% Time range for vertical wheel position
tJncReb = [11.1 21.5];

% Get indices of simulation results for this range
ind1    = find(KNCresR.Bounce.PAR.time>=tJncReb(1),1);
ind2    = find(KNCresR.Bounce.PAR.time>=tJncReb(2),1);

% Extract relevant results
zWL_raw  = KNCresR.Bounce.PAR.pzWC(ind1:ind2);
zWR_raw  = KNCresR.Bounce.PAR.pzWCR(ind1:ind2);
cpYL_raw = KNCresR.Bounce.PAR.pyPtch(ind1:ind2);
cpYR_raw = KNCresR.Bounce.PAR.pyPtchR(ind1:ind2);
cpZL_raw = KNCresR.Bounce.PAR.pzPtch(ind1:ind2);
cpZR_raw = KNCresR.Bounce.PAR.pzPtchR(ind1:ind2);

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

%% Generate Lookup Table - REAR AXLE
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
lutA2 = buildRollCenterLUTzWLzWR(zWL, cpYZL, zWR, cpYZR, opts);

%% Run full vehicle test
% Open Model
vehMdlname = 'sm_car';
open_system(vehMdlname)

% Load vehicle and set parameters
sm_car_load_vehicle_data(vehMdlname,vehInd);
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');

% Select maneuver
sm_car_config_maneuver('sm_car','Slalom');

% Turn off roll center visualization
set_param([vehMdlname '/World'],'popup_vis_point','Off');

% Simulate event
sim(vehMdlname)

%% Extract simulation results, vehicle parameters
simlog_pwcTireFL = logsout_sm_car.get('VehBus').Values.Chassis.WhlL1.xyz.Data;
simlog_pwcTireFR = logsout_sm_car.get('VehBus').Values.Chassis.WhlR1.xyz.Data;

simlog_pwcTireRL = logsout_sm_car.get('VehBus').Values.Chassis.WhlL2.xyz.Data;
simlog_pwcTireRR = logsout_sm_car.get('VehBus').Values.Chassis.WhlR2.xyz.Data;

simlog_time      = logsout_sm_car.get('VehBus').Values.Chassis.WhlL1.xyz.Time;

% Extract orientation of vehicle reference frame
simlog_vqS = logsout_sm_car.get('VehBus').Values.World.Q.Data;

% Extract position of front axle reference frame
vpx = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Px.p.series.values;
vpy = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Py.p.series.values;
vpz = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Pz.p.series.values;
simlog_refA1 = [vpx vpy vpz];

% Offset to rear axle reference frame - vehicle coordinates
refA1_toRefA2 = Vehicle.Chassis.Body.sAxle2.Value;

% Offset to rear axle reference frame - global coordinates in time
refA1_toRefA2_t = [];
for t_i = 1:size(simlog_vqS,1)
    refA1_toRefA2_t(t_i,:) = quatRotateVec(simlog_vqS(t_i,:),refA1_toRefA2);
end

% Obtain position of rear axle reference frame in global coordinates
simlog_refA2 = simlog_refA1+refA1_toRefA2_t;

%% Calculate Roll Center Location for Front Axle Using Lookup Table
vehRef_wCFL = simlog_pwcTireFL -simlog_refA1;
vehRef_wCFR = simlog_pwcTireFR -simlog_refA1;

vehRef_wCFL_veh = [];
vehRef_wCFR_veh = [];
% Rotate vector to align with vehicle coordinates
for t_i = 1:size(simlog_vqS,1)
    vqS_inv = [ simlog_vqS(t_i,1), -simlog_vqS(t_i,2), -simlog_vqS(t_i,3), -simlog_vqS(t_i,4) ];   % conjugate = inverse
    vehRef_wCFL_veh(t_i,:) = quatRotateVec(vqS_inv,vehRef_wCFL(t_i,:));
    vehRef_wCFR_veh(t_i,:) = quatRotateVec(vqS_inv,vehRef_wCFR(t_i,:));
end

% Use vertical component to obtain RC position in axle coordinate system 
RC = lutA1.eval(vehRef_wCFL_veh(:,3), vehRef_wCFR_veh(:,3));
Yrc = RC(:,:,1);
Zrc = RC(:,:,2);
hp_RCF_IC = [zeros(size(Yrc)) Yrc Zrc];

% Rotate and translate to global coordinates
vehRef_RCF_veh = [];
for t_i = 1:size(simlog_vqS,1)
    vehRef_RCF_veh(t_i,:) = quatRotateVec(simlog_vqS(t_i,:),hp_RCF_IC(t_i,:));
end

wld_RCA1 = vehRef_RCF_veh+simlog_refA1;

%% Calculate Roll Center Location for Rear Axle Using Lookup Table
vehRef_wCRL = simlog_pwcTireRL -simlog_refA2;
vehRef_wCRR = simlog_pwcTireRR -simlog_refA2;

vehRef_wCRL_veh = [];
vehRef_wCRR_veh = [];
% Rotate vector to align with vehicle coordinates
for t_i = 1:size(simlog_vqS,1)
    vqS_inv = [ simlog_vqS(t_i,1), -simlog_vqS(t_i,2), -simlog_vqS(t_i,3), -simlog_vqS(t_i,4) ];   % conjugate = inverse
    vehRef_wCRL_veh(t_i,:) = quatRotateVec(vqS_inv,vehRef_wCRL(t_i,:));
    vehRef_wCRR_veh(t_i,:) = quatRotateVec(vqS_inv,vehRef_wCRR(t_i,:));
end

% Use vertical component to obtain RC position in axle coordinate system 
RC = lutA2.eval(vehRef_wCRL_veh(:,3), vehRef_wCRR_veh(:,3));
Yrc = RC(:,:,1);
Zrc = RC(:,:,2);
hp_RCR_IC = [zeros(size(Yrc)) Yrc Zrc];

% Rotate and translate to global coordinates
vehRef_RCR_veh = [];
for t_i = 1:size(simlog_vqS,1)
    vehRef_RCR_veh(t_i,:) = quatRotateVec(simlog_vqS(t_i,:),hp_RCR_IC(t_i,:));
end

wld_RCA2 = vehRef_RCR_veh+simlog_refA2;

%%  Rerun KnC test and animate roll center
set_param([vehMdlname '/World'],'popup_vis_point','On');
set_param([vehMdlname '/World'],'time_vector','simlog_time','xyz_matrix','wld_RCA1')

sim(vehMdlname)

%% Plot roll center positions
figure(99)
ahRC(1)=subplot(211);
plot(simlog_time,vehRef_RCF_veh(:,2),'DisplayName','Front')
hold on
plot(simlog_time,vehRef_RCR_veh(:,2),'DisplayName','Rear')
hold off
ylabel('Distance (m)')
title('Roll Center Distance from Vehicle XZ Plane')
grid on
legend('Location','Best')

ahRC(2)=subplot(212);
plot(simlog_time,vehRef_RCF_veh(:,3),'DisplayName','Front')
hold on
plot(simlog_time,vehRef_RCR_veh(:,3),'DisplayName','Rear')
hold off
ylabel('Distance (m)')
xlabel('Time (s)')
title('Roll Center Height')
legend('Location','Best')
grid on

linkaxes(ahRC,'x')

figure(98)
plot(vehRef_RCF_veh(:,2),vehRef_RCF_veh(:,3),'DisplayName','Front')
hold on
plot(vehRef_RCR_veh(:,2),vehRef_RCR_veh(:,3),'DisplayName','Rear')
hold off
xlabel('Distance from Vehicle Center (m)')
ylabel('Height (m)')
title('Roll Center Location in Vehicle YZ Plane')
grid on
xLim = get(gca,'XLim');
set(gca,'XLim',[-1 1]*max(abs(xLim)))
legend('Location','Best')
