function sm_car_trajectory_skidpad
% Function to construct skidpad maneuver
% Copyright 2018-2024 The MathWorks, Inc.

cd(fileparts(which(mfilename)))

% Parameters for trajectory
x_traj_start = -50; % m
x_start      = -25;
track_r      = (15.25+3)/2; %m
x_finish     =  50; % m


v_lc        = 6;     % Speed during circle (m/s)
x_testv     = 20;    % Distance when target speed is reached (m)

% Assemble waypoints
circle_x =  sind([0:15:(360-15)])*track_r;
circle_y =  cosd([0:15:(360-15)])*track_r-track_r;

x_waypoints =  [x_traj_start x_start x_start+x_testv repmat(circle_x,1,4)                      0    1    2    3:1:(x_finish-1)    x_finish];
y_waypoints =  [0            0       0              -repmat(circle_y,1,2) repmat(circle_y,1,2) 0    0    0    zeros(1,47)         0];
vx_waypoints = [1            1       v_lc            v_lc*ones(1,size(circle_x,2)*4)           v_lc v_lc v_lc linspace(v_lc,1,47)           1];

% Construct sample points
x_new  = x_waypoints;
y_new  = y_waypoints;
vx_new = vx_waypoints;

% Interpolate to get lateral distance and speed
%y_new  = interp1(x_waypoints, y_waypoints,  x_new, 'pchip');
%vx_new = interp1(x_waypoints, vx_waypoints, x_new, 'pchip');

% Plot waypoints and interpolated trajectory
fig_handle_name = 'h1_sm_car_skidpad';

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

fig_handle_name = 'h2_sm_car_skidpad';

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


aYaw_wrap = [repmat(aYaw_new(1),1,yaw_interval) aYaw_new];

% Wrap aYaw_new
sigwrap = 0;
aYaw_new(1) = aYaw_wrap(1);
for i = 2:length(aYaw_wrap)
    diff_aY = aYaw_wrap(i)-aYaw_wrap(i-1);
    if(diff_aY>pi)
        sigwrap = sigwrap-1;
    elseif(diff_aY<-pi)
        sigwrap = sigwrap+1;
    end
    aYaw_new(i) = aYaw_wrap(i)+2*pi*sigwrap;
    %disp([' aY+: ' num2str(aYaw_wrap(i)) ' aY0: ' num2str(aYaw_wrap(i-1)) ' sigwrap:' num2str(sigwrap)])
end


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

save Skidpad_trajectory_default x y vx aYaw xTrajectory 

