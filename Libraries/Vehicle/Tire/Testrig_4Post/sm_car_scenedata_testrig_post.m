function scene_data = sm_car_scenedata_testrig_post
% SM_SUSPENSION_TEMPLATES_PARAMS Parameters used in the model

% Copyright 2019-2023 The MathWorks, Inc.

scene_data.Name = 'Testrig_Post';

%% Colors and densities
scene_data.color = simmechanics.demohelpers.colors;
scene_data.density = simmechanics.demohelpers.densities;

%% Test Platforms
scene_data.cylinder.outerradius     = 12; %cm
scene_data.cylinder.innerradius     = 10; %cm
scene_data.cylinder.flangeradius    = 20; %cm
scene_data.cylinder.flangethickness = 2;  %cm
scene_data.cylinder.height          = 40; %cm
scene_data.cylinder.color           = scene_data.color.dgrey;
scene_data.cylinder.leftlocation    = [-80 -25 0]; %cm
scene_data.cylinder.rightlocation   = [80 -25 0];  %cm

scene_data.piston.innerradius = 8;  %cm
scene_data.piston.height      = 60; %cm
scene_data.piston.color       = [0.6 0.6 0.6];

scene_data.base.length    = 40; %cm
scene_data.base.width     = 40; %cm
scene_data.base.thickness = 3;  %cm
scene_data.base.color     = [0.6 0.6 0.6];

scene_data.controller.k  = 1e4;
scene_data.controller.kd = 100;

scene_data.density = scene_data.density.aluminum; %kg/m^3

