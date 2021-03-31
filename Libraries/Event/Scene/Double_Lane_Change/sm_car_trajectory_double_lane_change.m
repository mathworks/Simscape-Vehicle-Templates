function sm_car_trajectory_double_lane_change
% Function to construct double-lane change maneuver
% Copyright 2018-2021 The MathWorks, Inc.

cd(fileparts(which(mfilename)))
% Parameters for trajectory
maneuver_lateral_offset    = -3.35; % m
cone_set_lat_separation    = 4.2;   % m

% Longitudinal gate locations (m)
gate0       = 0;     % Start 

gate1       = 175;   % Entry 1st set of cones
gate2       = 187;   % Exit  1st set of cones

gate3       = 198;   % Entry 2nd set of cones
gate4       = 213;   % Exit  2nd set of cones

gate5       = 224;   % Entry 3rd set of cones
gate6       = 240;   % Entry 3rd set of cones

gate7       = 500;   % End

v_lc        = 12;     % Speed during lane change (m/s)
x_testv     = 50;    % Distance when target speed is reached (m)

% Assemble waypoints, foundation for interpolation
x_waypoints =  [gate0 x_testv   gate1:1:gate2              gate3:1:gate4              gate5:1:gate6             ];
y_waypoints =  [0     0         zeros(1,gate2-gate1+1)     ones(1,gate4-gate3+1)      zeros(1,gate6-gate5+1)    ]*cone_set_lat_separation+maneuver_lateral_offset;
vx_waypoints = [1     v_lc      v_lc*ones(1,gate2-gate1+1) v_lc*ones(1,gate4-gate3+1) v_lc*ones(1,gate6-gate5+1)];

% Construct query points for interpolation
x_new  = [...
    gate0:(gate1-gate0)/30: (gate1-(gate1-gate0)/30) ...
    gate1:(gate2-gate1)/10: (gate2-(gate2-gate1)/10) ...
    gate2:(gate3-gate2)/20: (gate3-(gate3-gate2)/20) ...
    gate3:(gate4-gate3)/10: (gate4-(gate4-gate3)/10) ...
    gate4:(gate5-gate4)/20: (gate5-(gate5-gate4)/20) ...
    gate5:(gate6-gate5)/15: (gate6-(gate6-gate5)/15) ...
    gate6:(gate7-gate6)/10: (gate7)];

% Interpolate to get lateral distance and speed
y_new  = interp1(x_waypoints, y_waypoints,  x_new, 'pchip');
vx_new = interp1(x_waypoints, vx_waypoints, x_new, 'pchip');

% Plot waypoints and interpolated trajectory
fig_handle_name = 'h1_sm_car_double_lane_change';

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
title('Double-Lane Change Trajectory');
legend({'Waypoints','Interpolated'},'Location','Best');
axis equal

% Calculate distance traveled
xTrajectory_new = [0 cumsum(sqrt((diff(x_new)).^2+diff(y_new).^2))];

fig_handle_name = 'h2_sm_car_double_lane_change';

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

%aYaw_new = atan2(...
%    y_new(yaw_interval+1:end)-y_new(1:end-yaw_interval),...
%    x_new(yaw_interval+1:end)-x_new(1:end-yaw_interval));


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

z.Value = zeros(size(x_new));
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

save Double_Lane_Change_trajectory_default x y z vx aYaw xTrajectory 

