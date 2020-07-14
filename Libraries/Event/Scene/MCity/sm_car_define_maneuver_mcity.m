%% Select Waypoints for 3D Simulation
%
% Execute this script section by section to create new maneuver
% using a UI to select waypoints in the MCity scene

% Copyright 2020 The MathWorks, Inc.

% Interactively Select Waypoints

% Warn if release earlier than R2020a
if(verLessThan('matlab','9.8'))
    errordlg('Defining waypoints for the MCity scene via a UI requires MATLAB release R2020a and higher.')
else
    sceneName = 'VirtualMCity';
    [sceneImage, sceneRef] = helperGetSceneImage(sceneName);
    clear wayPoints refPoses
    hFig = helperSelectSceneWaypoints(sceneImage, sceneRef);
end

%% Transform the sequence of poses to a continuous path.
numPoses = size(refPoses{1}, 1);
refDirections  = ones(numPoses,1);   % Forward-only motion
numSmoothPoses = 20 * numPoses;      % Increase this to increase the number of returned poses
[smoothRefPoses,~,cumLengths] = smoothPathSpline(refPoses{1}, refDirections, numSmoothPoses);

% Display smooth trajectory on overhead map
hold on
plot(smoothRefPoses(:,1),smoothRefPoses(:,2),'r.')

% Configure model to accept closed loop maneuver
sm_car_config_maneuver('sm_car','MCity');  % Sample closed-loop maneuver

% Load maneuver into MATLAB variable
% Set target path (x, y, z coordinates)
Maneuver.Type               =  'MCity';
Maneuver.Trajectory.x.Value = smoothRefPoses(:,1)';
Maneuver.Trajectory.y.Value = smoothRefPoses(:,2)';
Maneuver.Trajectory.z.Value = zeros(size(smoothRefPoses(:,2)))';

% Set target heading angle
Maneuver.Trajectory.aYaw.Value = unwrap(smoothRefPoses(:,3)*pi/180)';
Maneuver.Trajectory.xTrajectory.Value = cumLengths';

% Set target speed (derive based on rate of change of heading angle)
max_speed = 10;
min_speed = 5;
temp_vx = ...
    smooth(...
    max_speed-(max_speed-min_speed)*abs(diff(smoothRefPoses(:,3)))...
    /max(abs(diff(smoothRefPoses(:,3)))),...
    5);

% Ramp target speed at start and end of maneuver
ind_10m    = find(cumLengths>10,1);
ind_end10m = find(cumLengths(end)-cumLengths<10,1);
temp_vx(1:1:ind_10m)=linspace(1,temp_vx(ind_10m),ind_10m);
temp_vx(ind_end10m:1:length(temp_vx))=linspace(temp_vx(ind_end10m),1,length(temp_vx)-ind_end10m+1);

% Assign target speed
Maneuver.Trajectory.vx.Value = [temp_vx; temp_vx(end)]';

% Set vehicle initial position and speed
Init.Chassis.sChassis.Value = [Maneuver.Trajectory.x.Value(1) Maneuver.Trajectory.y.Value(1) Maneuver.Trajectory.z.Value(1)];
Init.Chassis.aChassis.Value = [0 0 Maneuver.Trajectory.aYaw.Value(1)];
Scene.Plane_Grid.Plane.x = 0;

% Configure Unreal visualization
% Animation can be enabled from UI
set_param('sm_car/Visualization/Unreal/Animation On/Unreal Animation/Simulation 3D Scene Configuration','SceneDesc','Virtual MCity');
