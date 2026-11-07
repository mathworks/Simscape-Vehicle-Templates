%% Load parameters
offroad_ex01_msd_param

%% Setting up the state space equations for solving the 2 DoF quarter car model:
% State variables:
% x(1) = z_s       (Sprung mass displacement)
% x(2) = z_s_dot   (Sprung mass velocity)
% x(3) = z_us      (Unsprung mass displacement)
% x(4) = z_us_dot  (Unsprung mass velocity)

% Road profile input parameters (Sinusoidal)
road_amplitude = 0.05; % [m] 50 mm bump amplitude
road_freq = 1; % [Hz] Road excitation frequency

% Anonymous function for the ODEs
% x_dot = A*x + B*u, nonlinear format implemented for generalisation
quarter_car_ode = @(t, x) [
    x(2);
    (-k_s*(x(1) - x(3)) - c_s*(x(2) - x(4))) / m_s;
    x(4);
    (k_s*(x(1) - x(3)) + c_s*(x(2) - x(4)) - k_t*(x(3) - road_amplitude*sin(2*pi*road_freq*t))) / m_us
];

%% Simulate and plot sprung mass and unsprung mass displacements:
% Simulation time span
t_span = [0 10]; % [s]

% Initial conditions [0 displacement and 0 velocity]
x0 = [0; 0; 0; 0];

% Solve the system using the standard Runge-Kutta solver
[t, x] = ode45(quarter_car_ode, t_span, x0);

% Extract states for plotting
z_s = x(:, 1);
z_us = x(:, 3);
z_r = road_amplitude*sin(2*pi*road_freq*t); % Generate road profile array over time vector

% Plotting
figure('Name', 'Quarter Car Model Response');
plot(t, z_s, 'b', 'LineWidth', 1.5);
hold on;
plot(t, z_us, 'r', 'LineWidth', 1.5);
plot(t, z_r, 'k--', 'LineWidth', 1);
grid on;
xlabel('Time [s]');
ylabel('Displacement [m]');
title('2 DoF Quarter Car Model - Sinusoidal Road Response');
legend('Sprung Mass (z_s)', 'Unsprung Mass (z_{us})', 'Road Profile (z_r)');