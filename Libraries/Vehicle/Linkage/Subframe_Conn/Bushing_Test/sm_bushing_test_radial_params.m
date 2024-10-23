% Parameters for bushing test model
k_spr  = 2860;
k_tblx = [-3.8, -3.3, -2.8, -1.75, 0, 1.75, 2.8, 3.3, 3.8];
k_tblf = [-4, -3, -2, -1, 0, 1, 2, 3, 4]*3000;

b_dpr  = 2860;
b_tblv = [-4, -3, -2, -1, 0, 1, 2, 3, 4];    % m/s
b_tblf = [-4, -3, -2, -1, 0, 1, 2, 3, 4]*10; % N

k1_maxwell = 3.0139e+03;
b1_maxwell = 1.1471e+04;
k2_maxwell = 655.5098;
k_maxwell_x = [-3 -1.5 1.5 3]; % mm
k_maxwell_f = [-10 -4 4 10]*655.5098; % mm

% Load bushing test data
sm_bushing_test_data
