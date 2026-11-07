%% Double Mass-Spring-Damper, Quarter-Car Model
% 
% The commands below simulate a quarter-car vehicle modeled as a double
% mass-spring-damper. Tests include different road height inputs, including
% step and chirp inputs.  Plots of the simulation results show how the
% suspension performs in soft and stiff configurations.
%
% Copyright 2026 The MathWorks, Inc.

%% Step 1: Open Model
% This can be done from the  project shortcut or MATLAB Command line.
mdl = 'quarter_car_msd_2x';
open_system(mdl)

%% Step 2: Configure model for step test with soft suspension
% This can be done by adjusting the model or from the MATLAB Command line.
% This step selects the step test and configures the suspension to use its
% soft setting.

% Load default parameters
quarter_car_msd_2x_param

% Select soft suspension parameters
k_s = k_s_soft; % [N/m] 
c_s = c_s_soft; % [N/m] 

% Select test sequence
quarter_car_msd_2x_config(mdl,'Step')

%% Step 3: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 4: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot1xspring

% Save results for comparison plot
simlog_Soft_xRoad = simlog_xRoad;
simlog_Soft_xUSM  = simlog_xUSM;
simlog_Soft_xSM   = simlog_xSM;
simlog_Soft_t     = simlog_t;

%% Step 5: Configure model for step test with stiff suspension
% This can be done by adjusting the model or from the MATLAB Command line.
% This step selects the step test and configures the suspension to use its
% stiff setting.

% Select stiff suspension parameters
k_s = k_s_stiff; % [N/m] 
c_s = c_s_stiff; % [N/m] 

% Select test sequence
quarter_car_msd_2x_config(mdl,'Step')

%% Step 6: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 7: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot1xspring

% Save results for comparison plot
simlog_Stiff_xRoad = simlog_xRoad;
simlog_Stiff_xUSM  = simlog_xUSM;
simlog_Stiff_xSM   = simlog_xSM;
simlog_Stiff_t     = simlog_t;

%% Step 8: Plot response to step input for both settings
% This plot shows the response for the suspension system with the soft
% spring and the stiff spring.

figure(999);
plot(simlog_Soft_t, simlog_Soft_xSM, 'DisplayName', 'Soft Setting');
hold on;
plot(simlog_Stiff_t, simlog_Stiff_xSM, 'DisplayName', 'Stiff Setting');
plot(simlog_Soft_t, simlog_Soft_xRoad, 'g', 'DisplayName', 'Road Input');
hold off;
xlabel('Time (s)');
ylabel('Response');
title('Comparison of Soft and Stiff Settings');
legend('Location','Best');
grid on

%% Step 9: Configure model for chirp test with soft suspension
% This step selects the chirp test and configures the suspension to use its
% soft setting.

% Select soft suspension parameters
k_s = k_s_soft; % [N/m] 
c_s = c_s_soft; % [N/m] 

% Select test sequence
quarter_car_msd_2x_config(mdl,'Chirp')

%% Step 10: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 11: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot1xspring

% Save results for comparison plot
simlog_Soft_xRoad_chirp = simlog_xRoad;
simlog_Soft_xUSM_chirp  = simlog_xUSM;
simlog_Soft_xSM_chirp   = simlog_xSM;
simlog_Soft_t_chirp     = simlog_t;

%% Step 12: Configure model for chirp test with stiff suspension
% This step selects the chirp test and configures the suspension to use its
% stiff setting.

% Select stiff suspension parameters
k_s = k_s_stiff; % [N/m]
c_s = c_s_stiff; % [N/m]

%% Step 13: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 14: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot1xspring

% Save results for comparison plot
simlog_Stiff_xUSM_chirp  = simlog_xUSM;
simlog_Stiff_xSM_chirp   = simlog_xSM;
simlog_Stiff_t_chirp     = simlog_t;

%% Step 15: Plot chirp input response for both settings
figure(998);
plot(simlog_Soft_t_chirp, simlog_Soft_xSM_chirp,   'DisplayName', 'Soft Setting');
hold on;
plot(simlog_Stiff_t_chirp, simlog_Stiff_xSM_chirp, 'DisplayName', 'Stiff Setting');
plot(simlog_Soft_t_chirp, simlog_Soft_xRoad_chirp, 'g', 'DisplayName', 'Road Input');
hold off;
xlabel('Time (s)');
ylabel('Response');
title('Comparison of Soft and Stiff Settings');
legend('Location','Best');
grid on

%% Step 16: Configure model for triangle test with soft suspension
% This step selects the triangle test and configures the suspension to use its
% soft setting.

% Select soft suspension parameters
k_s = k_s_soft; % [N/m] Approximate suspension stiffness based on mass and natural frequency
c_s = c_s_soft; % [N/m] Approximate combined stiffness based on suspension and tyre springs

% Select test sequence
quarter_car_msd_2x_config(mdl,'Triangle')

%% Step 17: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 18: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot2xvsfrc

% Save results for comparison plot
simlog_Soft_xSp       = simlog_xSp-simlog_xSp(1);
simlog_Soft_fSM       = simlog_fSM;
simlog_Soft_indStart  = indStart;


%% Step 19: Configure model for triangle test with stiff suspension
% This step selects the triangle test and configures the suspension to use
% its stiff setting.

% Select stiff suspension parameters
k_s = k_s_stiff; % [N/m]
c_s = c_s_stiff; % [N/m]

%% Step 20: Run simulation
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 21: Explore simulation results
% Use the Simscape Results Explorer to plot the following quantities:
quarter_car_msd_2x_plot2xvsfrc

% Save results for comparison plot
simlog_Stiff_xSp       = simlog_xSp-simlog_xSp(1);
simlog_Stiff_fSM       = simlog_fSM;
simlog_Stiff_indStart  = indStart;

%% Step 22: Plot triangle input response for both settings
figure(997);
plot(simlog_Soft_xSp(simlog_Soft_indStart:end),simlog_Soft_fSM(simlog_Soft_indStart:end),'DisplayName','Soft')
hold on;
plot(simlog_Stiff_xSp(simlog_Stiff_indStart:end),simlog_Stiff_fSM(simlog_Stiff_indStart:end),'DisplayName','Stiff')
hold off;
title('Suspension Force vs. Deflection, Comparison')
xlabel('Deflection (m)')
ylabel('Force (N)')
legend('Location','Best');
grid on

