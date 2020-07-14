%% Create mfeval inputs

% Number of points
nPoints = 200;

% Pure lateral test case
Fz      = ones(nPoints,1).*3000;            % vertical load         (N)
kappa	= ones(nPoints,1).*0;               % longitudinal slip 	(-) (-1 = locked wheel)
alpha	= linspace(-0.3,0.3, nPoints)';     % side slip angle    	(radians)
gamma	= ones(nPoints,1).*0;               % inclination angle 	(radians)
phit 	= ones(nPoints,1).*0;               % turnslip            	(1/m)
Vx   	= ones(nPoints,1).*16;              % forward velocity   	(m/s)

% Create a string with the name of the TIR file
TIRfile = 'MagicFormula61_Paramerters.TIR';

% Select a Use Mode
useMode = 111;

% Wrap all inputs in one matrix
inputs = [Fz kappa alpha gamma phit Vx];

%% Call mfeval solver

% Store the output from mfeval in a 2D Matrix
output = mfeval(TIRfile, inputs, useMode);

%% Plot results

% Extract variables from output MFeval. For more info type "help mfeval"
Fy = output(:,2);
Mz = output(:,6);
Mx = output(:,4);
SA = rad2deg(output(:,8)); % Convert to degrees
t = output(:,16);

figure
subplot(2,2,1)
plot(SA, Fy)
grid on
title('Fy-SA')
xlabel('Slip Angle (deg)')
ylabel('Lateral Force (N)')

subplot(2,2,2)
plot(SA, Mz)
grid on
title('Mz-SA')
xlabel('Slip Angle (deg)')
ylabel('Self aligning moment (Nm)')

subplot(2,2,3)
plot(SA, t)
grid on
title('t-SA')
xlabel('Slip Angle (deg)')
ylabel('pneumatic trail (m)')

subplot(2,2,4)
plot(SA, Mx)
grid on
title('Mx-SA')
xlabel('Slip Angle (deg)')
ylabel('Overturning moment (Nm)')