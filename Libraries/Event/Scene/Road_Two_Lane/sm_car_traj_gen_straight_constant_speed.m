function traj = sm_car_traj_gen_straight_constant_speed(varargin)
%sm_car_traj_gen_straight_constant_speed Construct Maneuver for straightline test
%   traj = sm_car_traj_gen_straight_constant_speed
% Optional arguments
%
%      tgtSpd      Speed during lane change (m/s)
%      tgtDist     Distance when target speed is reached (m)
%                    NaN means use time for target speed
%      tgtTime     Time when target speed is reached (sec)
%                    NaN means use distance for target speed
%                  Only distance or time target is observed
%      latOffset   Offset for straightline trajectory (m)
%      showPlot    true to plot trajectory
%
% Copyright 2018-2024 The MathWorks, Inc.

% Vehicle initial speed
initSpeed = 1;

% Default values if no arguments supplied
if(nargin == 0)
    tgtSpd      = 12;    % (m/s)
    tgtDist     = NaN;   % (m), NaN means use time for target speed
    tgtTime     =  8;    % (sec), NaN means use distance for target speed
    latOffset   =  0;    % (m)
    showPlot    = false;
else
    tgtSpd    = varargin{1};
    tgtTime   = varargin{2};
    tgtDist   = varargin{3};
    latOffset = varargin{4};
    showPlot  = varargin{5};
end

if(isnan(tgtDist))
    % Calculate required acceleration (in meters per second squared)
    accel = tgtSpd / tgtTime;

    % Calculate the distance traveled using the formula:
    % distance = 0.5 * acceleration * time^2
    tgtDist = 0.5 * accel * tgtTime^2;
end

% Assemble waypoints
x_waypoints =  [0 tgtDist tgtDist*10];
y_waypoints =  [0 0 0]+latOffset;
vx_waypoints = [initSpeed tgtSpd tgtSpd];

% Construct sample points
numpts = 100;
x_new  = [x_waypoints(1):(x_waypoints(end)-x_waypoints(1))/numpts:(x_waypoints(end)-(x_waypoints(end)-x_waypoints(1))/numpts) x_waypoints(end)];

% Interpolate to get lateral distance and speed
y_new  = interp1(x_waypoints, y_waypoints,  x_new, 'pchip');
vx_new = interp1(x_waypoints, vx_waypoints, x_new, 'pchip');

% Plot waypoints and interpolated trajectory
if(showPlot)
    fig_handle_name = 'h1_sm_car_straight_constant_speed';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    plot(-y_waypoints,x_waypoints,'bo');
    hold on
    plot(-y_new,x_new,'r-x')
    hold off
    xlabel('Lateral Distance (m)')
    ylabel('Longitudinal Distance (m)');
    title('Straight Constant Speed Trajectory');
    legend({'Waypoints','Interpolated'},'Location','Best');
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

% If save to file is desired
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


