function traj_coeff = setup_optim_traj_vx(trackname)
% Copyright 2013-2020 MathWorks, Inc.
% Get trajectory parameters

switch(trackname)
    case 'CRG_Mallory_Park'
        traj_coeff = CRG_Create_Mallory_Park;
        sm_car_config_maneuver('sm_car','Mallory Park');
        set_param('sm_car','StopTime','360');
        set_param('sm_car/Check','lat_dev_threshold','8');
%        traj_coeff.vmin = 5.00;  % INITIAL
%        traj_coeff.vmax = 6.50;  %26.00 
       traj_coeff.vmin = 0.9508;   % AFTER 40 ITER
       traj_coeff.vmax = 31.2196;
       traj_coeff.diff_exp = 1.4249;
    case 'CRG_Kyalami_f'
        traj_coeff = CRG_Create_Kyalami;
        traj_coeff.vmin = 5.00;  %6.30
        traj_coeff.vmax = 6.00; %28.50 
        % For second iteration
        %traj_coeff.vmin = 13.1815; 
        %traj_coeff.vmax = 23.9529; 
        %traj_coeff.diff_exp = 1.8;
        sm_car_config_maneuver('sm_car','CRG Kyalami F');
        set_param('sm_car/Check','lat_dev_threshold','8');
        set_param('sm_car','StopTime','1000');
    case 'CRG_Kyalami'
        traj_coeff = CRG_Create_Kyalami;
        traj_coeff.vmin = 5.00;  %6.30
        traj_coeff.vmax = 6.00; %28.50 
        sm_car_config_maneuver('sm_car','CRG Kyalami');
        set_param('sm_car/Check','lat_dev_threshold','8');
        set_param('sm_car','StopTime','1300');
    case 'CRG_Nurburgring_N_f'
        traj_coeff = CRG_Create_Nurburgring_N;
        traj_coeff.vmin     =5;%       = 6.6*2;  % Min speed, m/s
        traj_coeff.vmax     =6;%      = 10*2;   % Max speed, m/s
        sm_car_config_maneuver('sm_car','CRG Nurburgring N F');
        set_param('sm_car/Check','lat_dev_threshold','8');
        set_param('sm_car','StopTime','5000');
    case 'CRG_Suzuka_f'
        traj_coeff = CRG_Create_Suzuka;
        traj_coeff.vmin     =5;%       = 8;  % Min speed, m/s
        traj_coeff.vmax     =6;%      = 26;   % Max speed, m/s
        sm_car_config_maneuver('sm_car','CRG Suzuka F');
        set_param('sm_car/Check','lat_dev_threshold','8');
        set_param('sm_car','StopTime','2000');
end

% Enable checks to terminate run if car leaves track or lap is complete
set_param('sm_car/Check','start_check_time_ld','5');
set_param('sm_car/Check','start_check_time_end_lap','5');

% Turn Fast Restart on
set_param(bdroot,'FastRestart','on')

