function [traj, cones] = sm_car_traj_gen_slalom(varargin)
%sm_car_traj_gen_straight_constant_speed   Construct Maneuver for slalom test
%   traj = sm_car_traj_gen_slalom
% Optional arguments
%
%      tgtSpd      Speed during lane change (m/s)
%      tgtDist     Distance when target speed is reached (m)
%                    NaN means use time for target speed
%      tgtTime     Time when target speed is reached (sec)
%                    NaN means use distance for target speed
%                  Only distance or time target is observed
%      xSlalom     Offset from tgtDist to start test
%      latOffset   Lateral offset of path center
%      numCones    Number of cones
%      yPathMx     Max deviation of path from center line
%
% Copyright 2018-2024 The MathWorks, Inc.

% Vehicle initial speed
initSpeed = 1;

% Default values if no arguments supplied
if(nargin == 0)
    tgtSpd   =  40;  % km/h
    tgtTime  =  8;  % sec
    tgtDist  =  NaN;  % m
    xSlalom  =  10;  % m    
    latOffset = 0;  % m
    numCones =  8;  % deg
    xCones   =  18;  % m
    yPathMx  =  4;  % sec
    qInit    =  1;  % 1,-1
    curveType =  'sine';  % 'sine','triangle'
    showPlot =  true;
else
    tgtSpd   =  varargin{1};  % km/h
    tgtTime  =  varargin{2};  % sec
    tgtDist  =  varargin{3};  % m
    xSlalom  =  varargin{4};  % m    
    latOffset = varargin{5};  % m
    numCones =  varargin{6};  % deg
    xCones   =  varargin{7};  % m
    yPathMx  =  varargin{8};  % sec
    qInit    =  varargin{9};  % 1,-1
    curveType  =  varargin{10};  % 'sine','triangle'
    showPlot =  varargin{11};
end

if(isnan(tgtDist))
    % Calculate required acceleration (in meters per second squared)
    accel = tgtSpd / tgtTime;

    % Calculate the distance traveled using the formula:
    % distance = 0.5 * acceleration * time^2
    tgtDist = 0.5 * accel * tgtTime^2;
end

switch curveType
    case 'sine'
        npts = 30;
        samplePts = linspace(0,pi-(pi/npts),npts);
        curvexPts = samplePts/pi*xCones;
        curveyPts = sin(samplePts)*yPathMx;
    case 'triangle'
        npts = 20;
        samplePts = linspace(0,1-(1/npts),npts)*xCones;
        curvexPts = samplePts;
        curveyPts = yPathMx-yPathMx * (2 * abs(mod(samplePts/xCones, 1) - 0.5));
end


% Assemble waypoints
x_waypoints =  [-10 0 tgtDist];
y_waypoints =  [0 0 0]+latOffset;

%x_waypoints = [];
%y_waypoints = [];

for i = 1:numCones
    if (mod(i,2) == 1)
        lr = 1;
    else
        lr = -1;
    end

    x_waypoints = [x_waypoints curvexPts+xCones*(i-1)+tgtDist+xSlalom];
    y_waypoints = [y_waypoints curveyPts*lr*qInit];
end

extend_pts = x_waypoints(end)+[5:5:50];
x_waypoints = [x_waypoints extend_pts];
y_waypoints = [y_waypoints ones(size(extend_pts))*latOffset];

vx_waypoints    = [ones(size(y_waypoints))*tgtSpd];
vx_waypoints(1:2) = [1 1]; 

% Save cone locations to "Cones" for use in plotting and Scene
cones.xLatOffset.Value = latOffset;
cones.xCone1.Value     = tgtDist+xSlalom+xCones/2;
cones.xSpacing.Value   = xCones;
cones.nCones.Value     = numCones;

% Construct sample points and interpolate if needed
if (false)
    % Interpolate
    numpts = 200;
    x_new  = [x_waypoints(1):(x_waypoints(end)-x_waypoints(1))/numpts:(x_waypoints(end)-(x_waypoints(end)-x_waypoints(1))/numpts) x_waypoints(end)];
    % Interpolate to get lateral distance and speed
    y_new  = interp1(x_waypoints, y_waypoints,  x_new, 'pchip');
    vx_new = interp1(x_waypoints, vx_waypoints, x_new, 'pchip');
else
    x_new = x_waypoints;
    y_new = y_waypoints;
    vx_new = vx_waypoints;
end

% Plot waypoints and interpolated trajectory
if(showPlot)
    fig_handle_name = 'h1_sm_car_slalom';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    xConeSet = [0:(numCones-1)]*xCones+tgtDist+xSlalom+xCones/2;
    assignin("base","xConeSet",xConeSet)
    plot(-y_waypoints,x_waypoints,'s','DisplayName','Waypoints');
    hold on
    plot(-y_new,x_new,'r-x','DisplayName','Interpolated')
    plot(xConeSet*0,xConeSet,'s',...
        'MarkerFaceColor',[0.9725 0.6940 0.1250],...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerSize',6,'DisplayName','Cones')
    hold off
    xlabel('Lateral Distance (m)')
    ylabel('Longitudinal Distance (m)');
    title('Slalom');
    legend('Location','Best');
    axis equal
end

% Calculate distance traveled
xTrajectory_new = [0 cumsum(sqrt((diff(x_new)).^2+diff(y_new).^2))];

if(showPlot)
    fig_handle_name = 'h2_sm_car_straight_constant_speed';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    subplot(211)
    plot(xTrajectory_new,vx_new)
    xlabel('Distance Traveled (m)');
    ylabel('Target Speed (m/s)');
    title('Target Speed Along Trajectory');
end

% Calculate target yaw angle (rad)
yaw_interval = 2; % 10
aYaw_new = atan2(...
    y_new(yaw_interval+1:end)-y_new(1:end-yaw_interval),...
    x_new(yaw_interval+1:end)-x_new(1:end-yaw_interval));

aYaw_new = [repmat(aYaw_new(1),1,yaw_interval) aYaw_new];

if(showPlot)
    subplot(212)
    plot(xTrajectory_new,aYaw_new,'-o')
    xlabel('Distance Traveled (m)');
    ylabel('Target Yaw Angle (rad)');
    title('Target Yaw Angle Along Trajectory');
end

% Assign parameters for trajectory definition
x.Value = x_new;
x.Units = 'm';
x.Comments = '';

y.Value = y_new;
y.Units = 'm';
y.Comments = '';

z.Value = y_new*0;
z.Units = 'm';
z.Comments = '';

xTrajectory.Value = xTrajectory_new;
xTrajectory.Units = 'm';
xTrajectory.Comments = 'Distance traveled';

vx.Value = vx_new;
vx.Units = 'm/s';
vx.Comments = 'Vehicle speed along direction of travel';

aYaw.Value = aYaw_new;
aYaw.Units = 'rad';
aYaw.Comments = 'Yaw Angle, non-wrapping';

% If save to file is needed
%spdstr = num2str(round(tgtSpd));
%dststr = num2str(round(tgtDist));
%filename = ['Straight_Constant_Speed_trajectory_' spdstr '_' dststr]
%save(filename,'x','y','z','vx','aYaw','xTrajectory');

traj.x    = x;
traj.y    = y;
traj.z    = z;
traj.vx   = vx;
traj.aYaw = aYaw;
traj.xTrajectory = xTrajectory;


