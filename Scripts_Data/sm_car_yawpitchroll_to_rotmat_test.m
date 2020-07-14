Init.Chassis.aChassis.Value = [pi/3 pi/3 pi/3];
Init.Chassis.vChassis.Value = [2 0 0];

initial_aveh = [Init.Chassis.aChassis.Value(3) Init.Chassis.aChassis.Value(2) Init.Chassis.aChassis.Value(1)];
rotmat_ypr = sm_car_yawpitchroll_to_rotmat(Init.Chassis.aChassis.Value(3),Init.Chassis.aChassis.Value(2),Init.Chassis.aChassis.Value(1));
initial_vveh = rotmat_ypr*(Init.Chassis.vChassis.Value)';
