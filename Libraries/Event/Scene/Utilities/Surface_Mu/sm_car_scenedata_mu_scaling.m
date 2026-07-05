function scene_data = sm_car_scenedata_mu_scaling
%% Floor and Grid parameters
% Copyright 2018-2024 The MathWorks, Inc.

scene_data.Name = 'Mu_Scaling';
scene_data.x = [  0  59.9  60 90    90.1 200];
scene_data.y = [-60 -30.1 -30 -0.01  0    60];
scene_data.scale = [  ...
    1   1     1      1     1     1;
    1   1     1      1     1     1;
    1   1     0.4    0.4   1     1;
    1   1     0.4    0.4   1     1;
    1   1     1      1     1     1;
    1   1     1      1     1     1];

scene_data.constant = 1;
