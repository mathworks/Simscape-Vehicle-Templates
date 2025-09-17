function control_param = sm_car_controlparam_damper
%% Damper Control Parameters
% Copyright 2018-2024 The MathWorks, Inc.

control_param.Name = 'Damper';

%% Axle 1
% Common parameters
control_param.Axle1.tFilt    = 1e-3;
control_param.Axle1.iControl = [0.9 1.0 1.1];      % 1

% Lookup table for damping FORCE dependent on speed and control signal
control_param.Axle1.vDamperf  = [-1 -0.5 0 0.5 1];  % m/s
fDamperNom       = [-5700 -2250 0 2250  6000];
control_param.Axle1.fDamper  = [fDamperNom*0.9; fDamperNom*1;fDamperNom*1.1]';

% Lookup table for damping COEFFICIENT dependent on speed and control signal
control_param.Axle1.vDamperd  = [-0.2 -0.1 0 0.1 0.2];  % m/s
dDamperNom       = [6000 5750 5500 5750 6000];
control_param.Axle1.dDamper  = [dDamperNom*0.9; dDamperNom*1;dDamperNom*1.1]';

%% Axle 2
% Common parameters
control_param.Axle2.iControl = [0.9 1.0 1.1];      % 1
control_param.Axle2.tFilt    = 1e-3;

% Lookup table for damping FORCE dependent on speed and control signal
control_param.Axle2.vDamperf  = [-1 -0.5 0 0.5 1];  % m/s
fDamperNom             = [-5700 -2250 0 2250  6000];
control_param.Axle2.fDamper   = [fDamperNom*0.9; fDamperNom*1;fDamperNom*1.1]';

% Lookup table for damping COEFFICIENT dependent on speed and control signal
control_param.Axle2.vDamperd  = [-0.2 -0.1 0 0.1 0.2];  % m/s
dDamperNom       = [6000 5750 5500 5750 6000];
control_param.Axle2.dDamper  = [dDamperNom*0.9; dDamperNom*1;dDamperNom*1.1]';

%% Axle 3
% Common parameters
control_param.Axle3.iControl = [0.9 1.0 1.1];      % 1
control_param.Axle3.tFilt    = 1e-3;

% Lookup table for damping FORCE dependent on speed and control signal
control_param.Axle3.vDamperf  = [-1 -0.5 0 0.5 1];  % m/s
fDamperNom             = [-5700 -2250 0 2250  6000];
control_param.Axle3.fDamper   = [fDamperNom*0.9; fDamperNom*1;fDamperNom*1.1]';

% Lookup table for damping COEFFICIENT dependent on speed and control signal
control_param.Axle3.vDamperd  = [-0.2 -0.1 0 0.1 0.2];  % m/s
dDamperNom       = [6000 5750 5500 5750 6000];
control_param.Axle3.dDamper  = [dDamperNom*0.9; dDamperNom*1;dDamperNom*1.1]';











