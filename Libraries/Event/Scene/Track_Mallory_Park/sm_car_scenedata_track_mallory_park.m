function scene_data = sm_car_scenedata_track_mallory_park
%% Floor and Grid parameters
% Copyright 2018-2022 The MathWorks, Inc.

scene_data.Name = 'Mallory_Park';
scene_data.Track.w   = 10;          % m
scene_data.Track.h   = 0.1;         % m
scene_data.Track.clr = [1 1 1]*0.8; % [R G B]
scene_data.Track.opc = 1;           % (0-1)
scene_data.Track.x   = 0;           % m
scene_data.Track.y   = 0;           % m
scene_data.Track.z   = 0;           % m
scene_data.Track.yaw = 0;           % rad

% Load data
ctrdata=load('Mallory_Park_ctrline');
fieldname = fieldnames(ctrdata);
scene_data.Track.ctrline = ctrdata.(fieldname{1}); % [x y z] (m) 

