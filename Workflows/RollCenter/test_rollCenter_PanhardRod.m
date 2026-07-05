%% Test roll center calculation and visualization

% Open Model
mdlname = 'testrig_susp_knc';
open_system(mdlname);

% Turn off roll center visualization
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','Off');

%% Load vehicle and set parameters
sm_car_load_vehicle_data(mdlname,'242');
set_param([mdlname '/Axle'],'AxNum','Rear');
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');

Maneuver = sm_car_maneuverdata_knc(0.15,-0.15,0.01,0.05,0.05,500,1200,1200,1200,1200,-0.3);
Visual = sm_car_param_visual('default');


%% Simulate 
sim(mdlname)

%% Calculate Roll Center Location using Geometric Method
% Extract simulation results for universal joint
qx = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Rx.q.series.values;
qz = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Ry.q.series.values;
qt = simlog_sm_car_testrig_quarter_car.Axle.Suspension.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Ry.q.series.time;

% Get offset due to difference wheel center hp height and tire radius
AxleNum = 2;
sWctrSet = sm_car_get_sWheelCentre(Vehicle);
sWCtr     = sWctrSet(AxleNum,:);

tire_radii = sm_car_get_TireRadius(Vehicle);
tire_radius = tire_radii(AxleNum);
tire_WC_Offset = [0 0 tire_radius-sWCtr(3)];

% Get initial hp locations
hp_PR_Body0 = Vehicle.Chassis.SuspA2.AxleTA2PR.PanhardRod.sBody.Value+tire_WC_Offset;
hp_PR_Axle0 = Vehicle.Chassis.SuspA2.AxleTA2PR.PanhardRod.sAxle.Value+tire_WC_Offset;

% -- Get Chassis side HP locations in time
hp = [];

% These are hps/locations whose positions must be derived based on joint angles
prAxle   = [];
hp_RC_GM = [];

hp.panhardA = hp_PR_Body0;

% Loop over time vector to obtain result
for i = 1:length(qx)
    % Obtain position of Panhard Rod connection to axle
    prAxle(:,i) = calcLinkHPAxle(hp_PR_Body0',hp_PR_Axle0',-qx(i), -qz(i));

    % Assemble structure of hardpoint locations
    hp.panhardB = prAxle(:,i)';

    % Calculate roll center location
    rc     = rollCenterFromHardpoints('panhard', hp);

    % Extract roll center position in Y-Z plane
    hp_RC_GM(i,:) = [0 rc.RC_YZ];
end

%%  Rerun KnC test and animate roll center
set_param([mdlname '/Axle/Visuals'],'time_vector','qt','xyz_matrix','hp_RC_GM')
set_param([mdlname '/Axle/Visuals'],'popup_vis_point','On');

sim(mdlname)