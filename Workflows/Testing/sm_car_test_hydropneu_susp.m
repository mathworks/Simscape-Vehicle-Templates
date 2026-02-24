% Script to test hydropneumatic suspension in SUV 
% Manuever is low speed steering.

% Test four wheel steering
modelName = 'sm_car';
open_system(modelName);

% Load Vehicle data structure 
sm_car_load_vehicle_data(modelName,'241');
Vehicle.Powertrain.Driveline = VDatabase.Driveline.Axle2_L1_R1_L2_R2_default;
Vehicle.Powertrain.Power     = VDatabase.Power.Ideal_L1_R1_L2_R2_default;

% Disable rear steering
Control.Default.Steer.Gain.nRearAct.Value = 0;
% Enable bushings at connection lower control arm to axle
Vehicle.Chassis.SuspA1.AxleTA2PR.Arm_to_Axle.class.Value = 'Kinematic';
Vehicle.Chassis.SuspA2.AxleTA3.Arm_to_Axle.class.Value = 'Kinematic';

% Make chassis transparent
Vehicle.Chassis.Body.BodyGeometry.Opacity.Value = 0.3;

% Select Maneuver
sm_car_config_maneuver('sm_car','Low Speed Steer');

% Enable controller for hydropneumatic suspension
set_param([modelName '/Controller/Default'],'popup_spring_control_A1','Hydropneumatic');
set_param([modelName '/Controller/Default'],'popup_spring_control_A2','Hydropneumatic');

% Set gas spring to soft
set_param([modelName '/Controller/Default'],'popup_gas_spring_A1','Soft');
set_param([modelName '/Controller/Default'],'popup_gas_spring_A2','Soft');

% Run test
sim(modelName)

% Save vehicle roll angle
sim_soft_t     = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_soft_aRoll = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aRoll');

% Set gas spring to soft
set_param([modelName '/Controller/Default'],'popup_gas_spring_A1','Stiff');
set_param([modelName '/Controller/Default'],'popup_gas_spring_A2','Stiff');

% Run test
sim(modelName)

% Save vehicle roll angle
sim_stiff_t     = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_stiff_aRoll = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aRoll');

figure(109)
plot(sim_soft_t.data,sim_soft_aRoll.data,'LineWidth',1,'DisplayName','Soft')
hold on
plot(sim_stiff_t.data,sim_stiff_aRoll.data,'LineWidth',1,'DisplayName','Stiff')
hold off
legend('Location','Best');
xlabel('Time (s)')
ylabel(['Vehicle Roll (' sim_stiff_aRoll.units ')']);
grid on

title('Comparison Hydropneumatic Spring Setting')

% If required, save image
saveas(gcf,[mfilename '.png'])