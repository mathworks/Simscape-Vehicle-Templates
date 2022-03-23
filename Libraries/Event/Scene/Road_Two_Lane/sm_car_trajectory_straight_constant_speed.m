function sm_car_trajectory_straight_constant_speed(varargin) 
% Function to construct straightline constant speed maneuver
%
% Optional arguments
%
% v_lc        Speed during lane change (m/s)
% x_testv     Distance when target speed is reached (m)
%
% Copyright 2018-2022 The MathWorks, Inc.

% Move to this folder as a new .mat file will be created
cd(fileparts(which(mfilename)))

% Default values if no arguments supplied
v_lc        = 12;    % Speed during lane change (m/s)
x_testv     = 50;    % Distance when target speed is reached (m)
% Parameters for trajectory
maneuver_lateral_offset    = -3.35; % m

if(nargin>=1)
    v_lc = varargin{1};
end
if(nargin>=2)
    x_testv = varargin{2};
end
if(nargin>=3)
    maneuver_lateral_offset = varargin{3};
end

% Longitudinal gate locations (m)
gate0       = 0;     % Start 
gate7       = 290;   % End

% Assemble waypoints
x_waypoints =  [gate0 x_testv gate7];
y_waypoints =  [0 0 0]+maneuver_lateral_offset;
vx_waypoints = [1 v_lc v_lc];

% Construct sample points
numpts = 100;
x_new  = [gate0:(gate7-gate0)/numpts:(gate7-(gate7-gate0)/numpts) gate7];

% Interpolate to get lateral distance and speed
y_new  = interp1(x_waypoints, y_waypoints,  x_new, 'pchip');
vx_new = interp1(x_waypoints, vx_waypoints, x_new, 'pchip');

% Plot waypoints and interpolated trajectory
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

% Calculate distance traveled
xTrajectory_new = [0 cumsum(sqrt((diff(x_new)).^2+diff(y_new).^2))];

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

% Calculate target yaw angle (rad)
yaw_interval = 2; % 10
aYaw_new = atan2(...
    y_new(yaw_interval+1:end)-y_new(1:end-yaw_interval),...
    x_new(yaw_interval+1:end)-x_new(1:end-yaw_interval));

aYaw_new = [repmat(aYaw_new(1),1,yaw_interval) aYaw_new];

subplot(212)
plot(xTrajectory_new,aYaw_new,'-o')
xlabel('Distance Traveled (m)');
ylabel('Target Yaw Angle (rad)');
title('Target Yaw Angle Along Trajectory');

% Assign parameters for trajectory definition
x.Value = x_new;
x.Units = 'm';
x.Comments = '';

y.Value = y_new;
y.Units = 'm';
y.Comments = '';

xTrajectory.Value = xTrajectory_new;
xTrajectory.Units = 'm';
xTrajectory.Comments = 'Distance traveled';

vx.Value = vx_new;
vx.Units = 'm/s';
vx.Comments = 'Vehicle speed along direction of travel';

aYaw.Value = aYaw_new;
aYaw.Units = 'rad';
aYaw.Comments = 'Yaw Angle, non-wrapping';


spdstr = num2str(round(v_lc));
dststr = num2str(round(x_testv));

filename = ['Straight_Constant_Speed_trajectory_' spdstr '_' dststr];
save(filename,'x','y','vx','aYaw','xTrajectory'); 

