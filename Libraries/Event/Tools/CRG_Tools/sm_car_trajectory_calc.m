function [traj_data] = sm_car_trajectory_calc(road_data,traj_coeff)
% Function to produce driver trajectory.
%
%   Speed profile       Target speed at distance along track
%   Vehicle position    x-y position at distance along track
%   Vehicle yaw         Heading angle at distance along track
%
%   Saved in <root file name>_trajectory_default.mat if no output requested
%   Provided in a structure if an output is requested
%
% Trajectory is centerline as defined by CRG file.
% A custom formula calculates target speed based on track curvature.
%
% Copyright 2019-2025 The MathWorks, Inc.

% Basic settings
road_data = strrep(road_data,' ','_');
[~,f,~] = fileparts(road_data);
cd(fileparts(which([f '_dat.mat'])))

%% Get centerline from CRG generation
load([road_data '_dat']);
x_ctr = dat.rx;
y_ctr = dat.ry;

if(isfield(dat,'rz'))
    z_ctr = dat.rz;
else
    % Data is for flat trajectory
    z_ctr = dat.rx*0;
end

% Calculate distance along trajectory.
% Used for interpolation.
s_ctr = [0 cumsum( sqrt( (diff(x_ctr)).^2 + (diff(y_ctr)).^2 + (diff(z_ctr)).^2))];

% Force end of driver trajectory to line up with start
if(traj_coeff.blend_distance>0)
    blend_distance = traj_coeff.blend_distance;
    blend_inds = find(s_ctr>s_ctr(end)-blend_distance);
    x_min = x_ctr(blend_inds(1));x_max = x_ctr(1);
    y_min = y_ctr(blend_inds(1));y_max = y_ctr(1);
    z_min = z_ctr(blend_inds(1));z_max = z_ctr(1);
    
    pt1 = floor(length(blend_inds)*0.25);
    pt2 = floor(length(blend_inds)*0.75);
    
    x_ctr_int = interp1([1 length(blend_inds)],[x_min x_max],1:length(blend_inds));
    y_ctr_int = interp1(...
        [1                               pt1   pt2   length(blend_inds)],...
        [y_ctr(blend_inds(1)) y_ctr(blend_inds(pt1)) y_max y_max],...
        1:length(blend_inds),'pchip');
    z_ctr_int = interp1(...
        [1                               pt1   pt2   length(blend_inds)],...
        [z_ctr(blend_inds(1)) z_ctr(blend_inds(pt1)) z_max z_max],...
        1:length(blend_inds),'pchip');
    
    x_ctr(blend_inds) = x_ctr_int;
    y_ctr(blend_inds) = y_ctr_int;
    z_ctr(blend_inds) = z_ctr_int;
    
    x_ctr = x_ctr(1:end-1);
    y_ctr = y_ctr(1:end-1);
    z_ctr = z_ctr(1:end-1);
    s_ctr = s_ctr(1:end-1);
    
else
    % Add flat section at start and end with no curvature
    % Start section
    x_diffStart = x_ctr(2)-x_ctr(1);
    y_diffStart = y_ctr(2)-y_ctr(1);
    s_diffStart = sqrt(x_diffStart^2+y_diffStart^2);
    length_flat_section = 20;
    scalefactor = length_flat_section/s_diffStart; 
    x_start = x_ctr(1)-[floor(scalefactor):-1:1]*x_diffStart;
    y_start = y_ctr(1)-[floor(scalefactor):-1:1]*y_diffStart;
    z_start = repmat(z_ctr(1),1,floor(scalefactor));

    % End section
    x_diffEnd = x_ctr(end)-x_ctr(end-1);
    y_diffEnd = y_ctr(end)-y_ctr(end-1);
    s_diffEnd = sqrt(x_diffEnd^2+y_diffEnd^2);
    length_flat_section = 20;
    scalefactor = length_flat_section/s_diffEnd;
    x_end = x_ctr(end)+[1:floor(scalefactor)]*x_diffEnd;
    y_end = y_ctr(end)+[1:floor(scalefactor)]*y_diffEnd;
    z_end = repmat(z_ctr(end),1,floor(scalefactor));
    
    % Append sections
    x_ctr = [x_start x_ctr x_end];
    y_ctr = [y_start y_ctr y_end];
    z_ctr = [z_start z_ctr z_end];

    % Recalculate length
    s_ctr = [0 cumsum( sqrt( (diff(x_ctr)).^2 + (diff(y_ctr)).^2 + (diff(z_ctr)).^2))];
end

x_dr = x_ctr;
y_dr = y_ctr;
z_dr = z_ctr;

%% Plot driver path with track centerline
fig_handle_name =   'h1_driver_centerline';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

plot(x_dr,y_dr,'--d','LineWidth',1);
hold on
plot(x_ctr,y_ctr,'-','LineWidth',1);
hold off
legend({'Trajectory','Centerline'},'Location','Best');
axis equal
title('Driver Path along Test Track');
xlabel('x (m)');
ylabel('y (m)');

%% Prepare trajectory data

% Calculate target yaw angle as angle between points on either side.
% Assumes points are even distance apart.
yaw_interval = 1; % 10
aYaw_ctr = unwrap(atan2(...
    circshift(y_ctr,-yaw_interval)-circshift(y_ctr,+yaw_interval),...
    circshift(x_ctr,-yaw_interval)-circshift(x_ctr,+yaw_interval)));

%% Custom formula to determine target speed based on curvature.
% 1. Curvature is angle between current point and next point
% 2. Moving average used to reduce noise (function smooth())
% 3. Speed scaled to maximum speed at minimum curvature,
%    min speed at maximum curvature.
% 4. Exponential on curvature to reduce speed more at higher curvature
% 5. Additional smoothing applied at max speeds using min()

% Get curvature for entire circuit - assumes full circle
if(traj_coeff.blend_distance>0)
    yaw4curvature = [aYaw_ctr (aYaw_ctr(end)-aYaw_ctr(1))];
else
    yaw4curvature = [aYaw_ctr(2) aYaw_ctr(2:end-1) aYaw_ctr(end-1) aYaw_ctr(end-1)];
end

d_e = traj_coeff.diff_exp;  % Curvature exponent
d_s = traj_coeff.diff_smooth;   % Diff smoothing number of points
c_s = traj_coeff.curv_smooth;   % Curvature smoothing number of points

% Get shape for target speed trajectory
%curv4spd_raw   = abs(smooth(diff(yaw4curvature).^d_e,d_s)); %ORIG
curv4spd_raw   = abs(smooth(diff(yaw4curvature),d_s));       %No exp
curv4spd_unit  = curv4spd_raw/max(curv4spd_raw);
%curv4spd       = smooth(curv4spd_unit,c_s);                 %ORIG
curv4spd       = smooth(curv4spd_unit,c_s).^d_e;             %Exponent here
tgt_spd_shape  = ones(size(curv4spd))-curv4spd;

% Use smoothing to generate limit for max speed
lim_s = traj_coeff.lim_smooth;
lim_spd_shape  = smooth(tgt_spd_shape,lim_s);

% Limit max speed
tgt_spd_shape_lim = min([tgt_spd_shape lim_spd_shape],[],2);

% Smooth limited shape curve
tgta_s = traj_coeff.target_shape_smooth;  % Number of points for smoothing
tgt_spd_smootha = smooth(tgt_spd_shape_lim,tgta_s);

% Scale curve to maximum and minimum speeds
s_mx = traj_coeff.vmax;  % Max speed, m/s
s_mn = traj_coeff.vmin;   % Min speed, m/s
tgt_spd_smooth_0 = tgt_spd_smootha-min(tgt_spd_smootha);
tgt_spd_smooth_1 = tgt_spd_smooth_0/max(tgt_spd_smooth_0);
tgt_spd_smooth   = tgt_spd_smooth_1*(s_mx-s_mn)+s_mn;

%% Plot driver path with track centerline
fig_handle_name =   'h1_driver_vx_calc';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

ax_h(1) = subplot(311);
plot(s_ctr,aYaw_ctr,'LineWidth',1);
title('Road Heading');
xlabel('Distance Traveled (m)');

ax_h(2) = subplot(312);
plot(s_ctr,abs(diff(yaw4curvature)),'LineWidth',1);
hold on
plot(s_ctr,abs(curv4spd),'--','LineWidth',1);
hold off
title('Road Curvature');
legend({'Raw','Smoothed'},'Location','Best');
xlabel('Distance Traveled (m)');

ax_h(3) = subplot(313);
plot(s_ctr,tgt_spd_shape*s_mx);
hold on
plot(s_ctr,tgt_spd_shape_lim*s_mx,'--');
plot(s_ctr,tgt_spd_smooth,'LineWidth',1);
hold off
title('Target Speed');
legend({'Shape','Limited','Target'},'Location','Best');
set(gca,'YLim',[0 1.1*s_mx]);
xlabel('Distance Traveled (m)');

linkaxes(ax_h,'x');

%% Assign parameters for trajectory definition
% Use only a subset of points for trajectory
decim_traj = traj_coeff.decimation;  % Decimation for interpolation
inds_for_traj = 1:decim_traj:length(s_ctr);

x.Value = x_dr(inds_for_traj);
x.Units = 'm';
x.Comments = '';

y.Value = y_dr(inds_for_traj);
y.Units = 'm';
y.Comments = '';

z.Value = z_dr(inds_for_traj);
z.Units = 'm';
z.Comments = '';

xTrajectory.Value = s_ctr(inds_for_traj);
xTrajectory.Units = 'm';
xTrajectory.Comments = 'Distance traveled';

vx.Value = tgt_spd_smooth(inds_for_traj);
vx.Units = 'm/s';
vx.Comments = 'Vehicle speed along direction of travel';

aYaw.Value    = aYaw_ctr(inds_for_traj);
aYaw.Units    = 'rad';
aYaw.Comments = 'Yaw Angle, non-wrapping';

% Save necessary data for driver model
if(nargout == 0)
    save([road_data '_trajectory_default'],...
        'x','y','z','vx','aYaw','xTrajectory');
else
    traj_data.x = x;
    traj_data.y = y;
    traj_data.z = z;
    traj_data.vx = vx;
    traj_data.aYaw = aYaw;
    traj_data.xTrajectory = xTrajectory;
end

%% Plot Trajectory
fig_handle_name = 'h2_driver_v_yaw';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

simlog_handles(1) = subplot(2,1,1);
plot(xTrajectory.Value,vx.Value)
%set(gca,'YLim',[0 1.1*max(vx.Value)])
xlabel('Distance Traveled (m)');
ylabel('Target Speed (m/s)');
title('Target Speed Along Trajectory');

simlog_handles(2) = subplot(2,1,2);
plot(xTrajectory.Value,aYaw.Value,'-o')
xlabel('Distance Traveled (m)');
ylabel('Target Yaw Angle (rad)');
title('Target Yaw Angle Along Trajectory');

linkaxes(simlog_handles,'x');

