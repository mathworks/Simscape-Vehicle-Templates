%% Test roll center calculation and visualization
%  Full vehicle maneuver, Panhard Rod No steer

% Open Model
mdlname = 'sm_car';
open_system(mdlname)

% Load vehicle and set parameters
sm_car_load_vehicle_data(mdlname,'242');
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');

% Select maneuver
sm_car_config_maneuver('sm_car','Slalom');

% Turn off roll center visualization
set_param([mdlname '/World'],'popup_vis_point','Off');

%% Simulate
sim(mdlname)

%% Extract simulation results, vehicle parameters

% Extract angle from Panhard Rod universal joint
qx = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA2.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Rx.q.series.values;
qz = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA2.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Ry.q.series.values;
qt = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA2.Arm2_Panhard_NoSteer.Arm2_Panhard_NoSteer.HP_Pan_Body.Rigid_UJ.Universal_Joint.Ry.q.series.time;

% Extract position of vehicle reference frame
vpx = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Px.p.series.values;
vpy = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Py.p.series.values;
vpz = simlog_sm_car.Vehicle.Vehicle.Body_to_World.Free.Body_World_Joint.Pz.p.series.values;
veh_refp = [vpx vpy vpz];

% Extract orientation of vehicle reference frame
vqS = logsout_sm_car.get('VehBus').Values.World.Q.Data;

% Get key HPs in axle reference frame, design position
hp_PR_Body_A2 = Vehicle.Chassis.SuspA2.AxleTA2PR.PanhardRod.sBody.Value;
hp_PR_Axle_A2 = Vehicle.Chassis.SuspA2.AxleTA2PR.PanhardRod.sAxle.Value;

% Get key HPs in vehicle reference frame (front axle reference frame)
hp_PR_Body_A1 = hp_PR_Body_A2 + Vehicle.Chassis.Body.sAxle2.Value;
hp_PR_Axle_A1 = hp_PR_Axle_A2 + Vehicle.Chassis.Body.sAxle2.Value;

%% Calculate HP locations during maneuver
% Rotate vector (Vehicle Ref -> Panhard Rod Body connection) 
%    with vehicle rotation throughout maneuver
hp_PR_Body_veh_t = zeros(length(qx),3);
for t_i = 1:size(vqS,1)
    hp_PR_Body_veh_t(t_i,:) = quatRotateVec(vqS(t_i,:),hp_PR_Body_A1);
end

% Offset rotated vector (Vehicle Ref -> Panhard Rod Body HP)
%    to vehicle reference global location throughout maneuver
hp_PR_Body_wld_t = veh_refp+hp_PR_Body_veh_t;

% Prepare variables to calculate axle and roll center location
hp_PR_Axle_veh_t = zeros(length(qx),3);
rc_veh_t         = zeros(length(qx),3);
hp.panhardA      = hp_PR_Body_A2;

% Loop over simulation results
for t_i = 1:length(qx)
    % Obtain position of Panhard Rod Axle connection in rear axle coordinate frame
    %   As if vehicle was stationary
    hp_PR_Axle_A2_t  = calcLinkHPAxle(hp_PR_Body_A2',hp_PR_Axle_A2',-qx(t_i), -qz(t_i))';

    % Rotate vector (Vehicle Ref -> Panhard axle HP) with vehicle rotation
    hp_PR_Axle_veh_t(t_i,:) = quatRotateVec(vqS(t_i,:),hp_PR_Axle_A2_t+Vehicle.Chassis.Body.sAxle2.Value);

    % Obtain vehicle roll center using body and axle hps in A2 reference frame
    hp.panhardB = hp_PR_Axle_A2_t;
    rc_A2  = rollCenterFromHardpoints('panhard', hp);

    % Extract roll center position in axle Y-Z plane
    rc_A2_yz_t = [0 rc_A2.RC_YZ];

    % Rotate vector (Vehicle Ref -> roll center) with vehicle rotation
    rc_veh_t(t_i,:) = quatRotateVec(vqS(t_i,:),rc_A2_yz_t+Vehicle.Chassis.Body.sAxle2.Value);
end

% Offset rotated vectors to vehicle ref global location
hp_PR_Axle_wld_t = veh_refp + hp_PR_Axle_veh_t;
hp_rc_wld_t      = veh_refp + rc_veh_t;

%%  Rerun KnC test and animate roll center
set_param([mdlname '/World'],'popup_vis_point','On');
set_param([mdlname '/World'],'time_vector','qt','xyz_matrix','hp_rc_wld_t')

sim(mdlname)

%% Plot Roll Center in Time
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