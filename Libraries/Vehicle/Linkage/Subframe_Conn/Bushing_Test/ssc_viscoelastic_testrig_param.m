% Spring
k_spr0 = 1000;     % N/mm
k_spr  = 2860;
k_tblx = [-3.8, -3.3, -2.8, -1.75, 0, 1.75, 2.8, 3.3, 3.8];
k_tblf = [-4, -3, -2, -1, 0, 1, 2, 3, 4]*3000;

% Damper
b_dpr0 = 1000;     % N/(mm/s)
b_dpr  = 2860;
b_tblv = [-4, -3, -2, -1, 0, 1, 2, 3, 4];    % m/s
b_tblf = [-4, -3, -2, -1, 0, 1, 2, 3, 4]*10; % N


% Damper Nonlinear
b_dprNL0 = 30;     % N/(mm/s)
b_dprNL  = 30;

% Spring Damper
k_sprdpr0 = 1000;  % N
b_sprdpr0 = 100;   % N/(mm/s)
k_sprdpr = 2860;  % N
b_sprdpr = 100;   % N/(mm/s)


% Maxwell SLS Linear
k1_maxSLS0 = 1.9992e+03;
b1_maxSLS0 = 1.0000e+03;
k2_maxSLS0 = 6.8000e+02;
k1_maxSLS = 3.6173e+03;
b1_maxSLS = 1.1535e+04;
k2_maxSLS = 2.1247e+03;

% Maxwell SLS Nonlinear k
k1_maxSLSnlk0 = 1.9992e+03;
b1_maxSLSnlk0 = 1.0000e+03;
k2_maxSLSnlk0 = 6.8000e+02;

k1_maxSLSnlk = 3.8261e+03;
b1_maxSLSnlk = 1.1072e+04;
k2_maxSLSnlk = 673.3864;

% Maxwell SLS Nonlinear kb
k1_maxSLSnlkb = 3.8261e+03;
k2_maxSLSnlkb = 6.8000e+02;
b1_maxSLSnlkb = 1.1072e+04;
b1_maxSLSnlkb_fva = 50;     % Force vector breakpoint
b1_maxSLSnlkb_fvb = 4;      % Force vector breakpoint factor
b1_maxSLSnlkb_vv0 = 0.25;   % Velocity vector breakpoint factor

% Maxwell SLS Damped
k1_maxSLS_b = 3.8261e+03;
b1_maxSLS_b = 1.1072e+04;
k2_maxSLS_b = 673.3864;
b2_maxSLS_b = 10;

% Maxwell SLS Nonlinear k Damped
k1_maxSLSnlk_b = 3.8261e+03;
b1_maxSLSnlk_b = 1.1072e+04;
k2_maxSLSnlk_b = 673.3864;
b2_maxSLSnlk_b = 10;


% Post static optim
% Maxwell SLS, Nonlinear, R18b smoothed interpolation
k1_maxwell = 3.0139e+03;
b1_maxwell = 1.1471e+04;
k2_maxwell = 655.5098;
k_maxwell_x = [-3 -1.5 1.5 3]; % mm
k_maxwell_f = [-10 -4 4 10]*655.5098; % mm

% Wiechert test
k_wiechert  = 2856*0.5;    % N/mm
k1_wiechert = 2856*0.1;    % N/mm
b1_wiechert = 1e7*0.5*0.2/1000; % N/(mm/s)
k2_wiechert = 2856*0.1;        % factor
b2_wiechert = 1e7*0.5*0.2/1000; % N/(mm/s)


x0_spr1    = 0;  % mm, static test

% Result from freq tuning
%k1_maxwell = 0.8821*1.0e+03;    % N/mm
%b1_maxwell = 0.0033*1.0e+03;    % N/(mm/s)
%k2_maxwell = 1.7397*1.0e+03;    % factor
