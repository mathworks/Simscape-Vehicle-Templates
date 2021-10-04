function traj_coeff = setup_optim_traj_vx(mdl,trackname)
% Copyright 2013-2020 MathWorks, Inc.
% Get trajectory parameters

switch(trackname)
    case 'CRG_Mallory_Park'
        traj_coeff = CRG_Create_Mallory_Park;
        sm_car_config_maneuver(mdl,'Mallory Park');
        traj_coeff.vmin = 5.00;  % INITIAL
        traj_coeff.vmax = 7.0;  %26.00 
        set_param(mdl,'StopTime','360');
        set_param([mdl '/Check'],'lat_dev_threshold','8');
    case 'CRG_Kyalami_f'
        traj_coeff = CRG_Create_Kyalami;
        traj_coeff.vmin = 5.00;  %6.30
        traj_coeff.vmax = 6.00; %28.50 
        sm_car_config_maneuver(mdl,'CRG Kyalami F');
        set_param([mdl '/Check'],'lat_dev_threshold','8');
        set_param('sm_car','StopTime','1000');
    case 'CRG_Kyalami'
        traj_coeff = CRG_Create_Kyalami;
        traj_coeff.vmin = 5.00;  %6.30
        traj_coeff.vmax = 6.00; %28.50 
        sm_car_config_maneuver(mdl,'CRG Kyalami');
        set_param([mdl '/Check'],'lat_dev_threshold','8');
        set_param(mdl,'StopTime','1300');
    case 'CRG_Nurburgring_N_f'
        traj_coeff = CRG_Create_Nurburgring_N;
        traj_coeff.vmin     =5;%       = 6.6*2;  % Min speed, m/s
        traj_coeff.vmax     =6;%      = 10*2;   % Max speed, m/s
        sm_car_config_maneuver(mdl,'CRG Nurburgring N F');
        set_param([mdl '/Check'],'lat_dev_threshold','8');
        set_param(mdl,'StopTime','5000');
    case 'CRG_Suzuka_f'
        traj_coeff = CRG_Create_Suzuka;
        traj_coeff.vmin     =5;%       = 8;  % Min speed, m/s
        traj_coeff.vmax     =6;%      = 26;   % Max speed, m/s
        sm_car_config_maneuver(mdl,'CRG Suzuka F');
        set_param([mdl '/Check'],'lat_dev_threshold','8');
        set_param(mdl,'StopTime','2000');
end

% Enable checks to terminate run if car leaves track or lap is complete
set_param([mdl '/Check'],'start_check_time_ld','5');
set_param([mdl '/Check'],'start_check_time_end_lap','5');
        
% Set higher initial speed to avoid spinning the tires
% as vehicle starts the lap first time
Init = evalin('base','Init');
Init.Axle1.nWheel.Value(1:2) = Init.Axle1.nWheel.Value(1:2)*2;
Init.Axle2.nWheel.Value(1:2) = Init.Axle2.nWheel.Value(1:2)*2;
Init.Chassis.vChassis.Value = Init.Chassis.vChassis.Value*2;
assignin('base','Init',Init');

% Turn Fast Restart on
set_param(mdl,'FastRestart','on')

