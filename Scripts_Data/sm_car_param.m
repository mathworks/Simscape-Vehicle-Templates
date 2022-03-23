% Copyright 2018-2022 The MathWorks, Inc.

%% Colors
smcar_param.blue        = [0.2 0.4 0.6];
smcar_param.bluepure    = [0.2 0.4 0.6];
smcar_param.black       = [0.0 0.0 0.0];
smcar_param.yellow      = [1.0 1.0 0.0];
smcar_param.green       = [0.2 1.0 0.0];
smcar_param.red         = [1.0 0.0 0.2];
smcar_param.orange      = [1.0 0.8 0.4];
smcar_param.orangedark  = [1.0 0.7 0.0];
smcar_param.purple      = [0.6 0.6 1.0];
smcar_param.yellowpale  = [0.93 0.93 0.56];
smcar_param.gray        = [0.5 0.5 0.5];
smcar_param.white       = [1.0 1.0 1.0];

% Shock Visualization
smcar_param.shock.cap = 0.025;
smcar_param.shock.piston = 0.025;
smcar_param.shock.radius = 0.05;
smcar_param.shock.dead_length = 0.01;
smcar_param.shock.bumpstop_len = 0.05;

% Car Body Visualization
smcar_param.body.hp = [0 0 0.4225-0.1];

smcar_param.hp.clr = smcar_param.red;
smcar_param.hp.opc = 1;
smcar_param.hp.rad = 0.025;

smcar_param.part.opc = 1;
smcar_param.rim.opc  = 0.5;

load xy_data_membrane
smcar_param.emblem.data = xy_data_membrane;
clear xy_data_membrane
