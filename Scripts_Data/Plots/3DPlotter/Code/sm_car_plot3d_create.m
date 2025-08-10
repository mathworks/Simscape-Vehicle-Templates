function sm_car_plot3d_create(logsout,vehType,sceneNameInput,boxWidth,plot3DView,...
    plotVehicle,plotPatch,plotTireForces,tSamp,timeStart,timeStop,fig_h,saveGIF)
% sm_car_plot3d_create   Create 3D plot of simulation results
%    This function creates a plot of simulation results with 3D
%    visualization to provide context for the results. Inputs to this
%    function select which elements to plot and which time frame to show.
%    The plot can be created in a separate figure window or an App.
%
%    logsout         Simulation data in Workspace (variable with data) 
%                     OR name of .mat file (string)
%    vehType         3D visual element of vehicle shown in plot
%    sceneNameInput  Name of scene to show in plot (road, surface)
%                     OR defer to settings in workspace
%    boxWidth        Length of area to be shown on plot x and y axes (m)
%    plot3DView      Plot results in 3D
%    plotVehicle     Add vehicle visual to plot
%    plotPatch       Add to plot patch showing path on ground traced by vehicle body
%    tSamp           Sample time (number) for interpolated results
%                    'none' for no interpolation
%    timeStart       Start time for results to be plotted
%    timeStop        Stop time for results to be plotted
%    fig_h           Handle of figure for results plot
%    saveGIF         true to save animation of results to a GIF
%
% Copyright 2025 The MathWorks, Inc.


%% Vehicle visualization
% -- Defaults for car visualization
load('VehVisDataSedan.mat');  % Load 3D-Vehicle Data
wheelRadius = vehiclePatchData.Wheel.radius;   % in m

switch vehType
    case 'Sedan'
        % Default
    case 'FSAE'
        load('VehVisDataFSAE.mat');  % Load 3D-Vehicle Data
        wheelRadius = vehiclePatchData.Wheel.radius;
    case 'SUV Landy'
        load('VehVisDataSUVLandy.mat');  % Load 3D-Vehicle Data
        wheelRadius = vehiclePatchData.Wheel.radius;
    case 'None'
        plotVehicle = false;
    otherwise
        warning(['Vehicle Type ' vehType ' not recognized, no vehicle plotted'])
        plotVehicle = false;
end

%% Load all scene data
Scene     = evalin('base','Scene');
MDatabase = evalin('base','MDatabase');
Scene3DPlot = sm_car_plot3d_get_scene(Scene,MDatabase);
CurbSectionLength = 0.25;       % Road marking lengths, also level that road is interpolated between datapoints

%% Load simulation results
if(ischar(logsout))
    if(endsWith(logsout,'.mat'))
        % String ending with .mat means data from file
        % Includes selection for scene data
        load(logsout);
    end
else
    % Load simulation results from workspace
    [simTime, tireFx, tireFy, tireFz, wheelAngles, wheelCamber, ...
        posVeh, psiVeh, velVeh, tirePx, tirePy, tirePz] = ...
        sm_car_plot3d_get_data(logsout);

    % User Maneuver from workspace to select scene data
    Maneuver = evalin('base','Maneuver');
    sceneName = sm_car_plot3d_manv_to_scene(Maneuver);
end
psiVeh = unwrap(psiVeh,pi);

% Input to function can override selection for scene data
if(any(~strcmp(sceneNameInput,{'(from workspace/file)'})))
    sceneName = sceneNameInput;
end

% Select scene data
scene = Scene3DPlot.(sceneName);

%% If GIF to be saved, have user select file location
if(saveGIF)
    [gifName, gifFolder] = uiputfile('*.gif', 'Save animation to GIF');
    gifFullPath = strcat(gifFolder,gifName);
end

%% Data interpolation
if(ischar(tSamp))
    if(strcmp(tSamp,'none'))
        % Do not interpolate data - show exact simulation results
        discRes = false;
    end
else
    % Interpolate data - suitable for animation
    discRes = true;
end

if(discRes)
    % Discrete time vector
    ts = tSamp; % Sample time
    simTimeDisc = 0:ts:simTime(end);

    % Interpolate data
    tireFx      = interp1(simTime, tireFx, simTimeDisc);      % As nx4 vector (for each wheel)
    tireFy      = interp1(simTime, tireFy, simTimeDisc);      % As nx4 vector (for each wheel)
    tireFz      = interp1(simTime, tireFz, simTimeDisc);      % As nx4 vector (for each wheel)
    wheelAngles = interp1(simTime, wheelAngles, simTimeDisc); % As nx4 vector (for each wheel)
    wheelCamber = interp1(simTime, wheelCamber, simTimeDisc); % As nx4 vector (for each wheel)

    tirePx      = interp1(simTime, tirePx, simTimeDisc);      % As nx4 vector (for each wheel)
    tirePy      = interp1(simTime, tirePy, simTimeDisc);      % As nx4 vector (for each wheel)
    tirePz      = interp1(simTime, tirePz, simTimeDisc);      % As nx4 vector (for each wheel)

    % Position, speed and orientation of the vehicle
    posVeh      = interp1(simTime, posVeh, simTimeDisc);  % As nx3 vector [X, Y, Z]
    psiVeh      = interp1(simTime, psiVeh, simTimeDisc);  % As nx1 vector
    velVeh      = interp1(simTime, velVeh, simTimeDisc);  % As nx3 vector [X, Y, Z]

    % Check start and stop time
    if(isempty(timeStart) && isempty(timeStop))
        timeStart = 1;
        timeStop  = simTime(end);
    elseif(isempty(timeStop))
        timeStop  = simTime(end);
    elseif(isempty(timeStart))
        timeStart = timeStop-ts;
    end
    startIndex = max(floor(timeStart*(1/ts)),0)+1;
    stopIndex  = min(floor(timeStop*(1/ts)),simTimeDisc(end)*(1/ts))+1;
    startIndex = max(min(startIndex,stopIndex-1),1);

    % Assemble set of indices for plotting
    plotInds   = int32(startIndex:stopIndex);
else
    % Do not interpolate
    simTimeDisc = simTime';

    % Check start and stop time
    startIndex = find(simTime>=timeStart,1,'first');
    if(isempty(startIndex))
        startIndex = 1;
    end
    stopIndex = find(simTime<=timeStop,1,'last');
    if(isempty(stopIndex))
        stopIndex = length(simTime);
    end
    startIndex = max(min(startIndex,stopIndex-1),1);

    % Assemble set of indices for plotting
    plotInds    = startIndex:stopIndex;
end

%% Plot the road
% Determine the total Length of the road
numWaypoints = size(scene.centerline, 1);
cumulativeLengths = zeros(numWaypoints, 1);
% --- Calculate Distances Between Consecutive Points ---
segmentVectors = diff(scene.centerline, 1, 1);
% Calculate the Euclidean norm (length) of each segment vector
segmentLengths = sqrt(sum(segmentVectors.^2, 2));
% --- Calculate Cumulative Lengths ---
for i = 2:numWaypoints
    cumulativeLengths(i) = cumulativeLengths(i-1) + segmentLengths(i-1);
end
% Interpolate the road for smoother road edges
scene.centerline_f      = interp1(cumulativeLengths, scene.centerline, (cumulativeLengths(1):CurbSectionLength:cumulativeLengths(end)),'spline');
% Plot the resampled road
[~, ~, figH, axHandle] = sm_car_plot3d_plot_road(scene.centerline_f, scene.width,fig_h);
daspect(axHandle,[1 1 1]);

% Set font size and axis labels
xlabel(axHandle,'X (m)'); 
ylabel(axHandle,'Y (m)');
set(axHandle,'NextPlot','add','Box','on','XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on');

%% Plot the vehicle:
% Save handles for reuse when updating the plot
handles          = struct;
handles.figH     = figH;
handles.axHandle = axHandle;

% Loop over selected indices
for i = plotInds
    tireForces = [tireFx(i,:); tireFy(i,:); tireFz(i,:)];

    % Create or update handles on plot
    handles = sm_car_plot3d_plot_data(handles,vehiclePatchData, posVeh(i,:),psiVeh(i,:),velVeh(i,:),...
        tirePx(i,:), tirePy(i,:), tirePz(i,:), wheelAngles(i,:), wheelCamber(i,:),tireForces,...
        simTimeDisc(i),boxWidth/2, wheelRadius,...
        plotTireForces,plot3DView,plotVehicle,plotPatch);

    % Save a GIF if requested
    if  i==(plotInds(1)) && saveGIF ==1 % Save first frame for the GIF
        [imind, cm] = rgb2ind(frame2im(getframe(handles.figH)),256);
        imwrite(imind, cm, gifFullPath,'gif', 'Loopcount', inf, 'DelayTime', 15/numel(simTimeDisc));
    elseif i>(plotInds(1)) && saveGIF ==1  % Save frame of the GIF
        [imind, cm] = rgb2ind(frame2im(getframe(handles.figH)),256);
        imwrite(imind, cm, gifFullPath, 'gif', 'WriteMode', 'append', 'DelayTime',15/numel(simTimeDisc));
    else
        % pause(0.001);
        drawnow limitrate
    end
end
