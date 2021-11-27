function fig_h = sm_car_plot_ggv_surf(GGV_data, varargin)
%sm_car_plot_ggv_surf   Plot GGV diagram
%   fig_h = sm_car_plot_ggv_surf(GGV_data, <hold_fig>, <surf_clr>)
%
%   This function plots a GGV diagram using a set of data from a parameter
%   sweep.  The data you must provide includes structure GGV_data with the
%   following fields:
% 
%       lat_acc_pts_g        Maximum lateral acceleration for each test (g)
%       lng_acc_pts_g        Maximum longitudinal acceleration for each test (g)
%       veh_spd_pts_mps      Vehicle speed for each test (m/s)
%       veh_spd_vec          Vehicle speeds for sweep, used for drag and downforce calculation (m/s)
%       acc_theta_vec        Gravity vector angle in xy-plane for sweep (rad)
%       vehicle_config       String with vehicle configuration
%
%  You can optionally specify these arguments
%       hold_fig             true to retain figure on plot, false for new plot
%       surf_clr             Color for the surface as an RGB triplet

% Copyright 2021 The MathWorks, Inc.

%% Plot GGV with Surface
% Clear results figure if it already exists.

hold_fig = false;
surf_clr = 'parula';
if (nargin >= 2)
    hold_fig = varargin{1};
end
if (nargin >= 3)
    surf_clr = varargin{2};
end

% Figure name
figString = 'h1_sm_car_ggv_surf';

% Only create a figure if no figure exists
figExist = 0;
fig_hExist = evalin('base',['exist(''' figString ''')']);
if (fig_hExist)
    figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
end
if ~figExist
    fig_h = figure('Name',figString);
    assignin('base',figString,fig_h);
else
    fig_h = evalin('base',figString);
end
figure(fig_h)

if(~hold_fig)
    clf(fig_h)
end

% Check that all fields are present
fields = {...
    'lat_acc_pts_g','lng_acc_pts_g','veh_spd_pts_mps',...
    'veh_spd_vec','acc_theta_vec','vehicle_config'};
for i = 1:length(fields)
    if(~isfield(GGV_data,fields{i}))
        error(['Field ' fields{i} ' missing from GGV_data']);
    end
end

% Extract fields to variables
lat_acc_pts_g   = GGV_data.lat_acc_pts_g;
lng_acc_pts_g   = GGV_data.lng_acc_pts_g;
veh_spd_pts_mps = GGV_data.veh_spd_pts_mps;
veh_spd_vec     = GGV_data.veh_spd_vec;
acc_theta_vec   = GGV_data.acc_theta_vec;
vehicle_config  = GGV_data.vehicle_config;
vehicle_strs = strsplit(vehicle_config,'_');
vehicle_name_cfg = vehicle_strs{1};

% Swap model names for vehicle type names
switch vehicle_name_cfg
    case 'Hamba', vehicle_name = 'Sedan';
    case 'Achilles', vehicle_name = 'FSAE';
    otherwise, vehicle_name = vehicle_name_cfg;
end

% Reshape points for use with surface
lat_acc_pts_g_surf = reshape(lat_acc_pts_g,length(acc_theta_vec),length(veh_spd_vec));
lng_acc_pts_g_surf = reshape(lng_acc_pts_g,length(acc_theta_vec),length(veh_spd_vec));
veh_spd_pts_mps_surf = reshape(veh_spd_pts_mps,length(acc_theta_vec),length(veh_spd_vec));

% Ensure surface wraps around
lat_acc_pts_g_surf = [lat_acc_pts_g_surf;lat_acc_pts_g_surf(1,:)];
lng_acc_pts_g_surf = [lng_acc_pts_g_surf;lng_acc_pts_g_surf(1,:)];
veh_spd_pts_mps_surf = [veh_spd_pts_mps_surf;veh_spd_pts_mps_surf(1,:)];


% Plot surface and points
if (hold_fig)
    hold on
end

surf_h = surf(lat_acc_pts_g_surf, lng_acc_pts_g_surf, veh_spd_pts_mps_surf);
if(strcmpi(surf_clr,'parula'))
    set(surf_h,'FaceAlpha',0.5,'EdgeColor',[0.5 0.5 0.5]);
    hold on
    plot3(lat_acc_pts_g,lng_acc_pts_g,veh_spd_pts_mps,'o','MarkerSize',4,'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5]);
    hold off
else
    % If color specified, plot faces and edges
    set(surf_h,'FaceAlpha',0.5,'FaceColor',surf_clr,'EdgeColor',surf_clr);
end

% Scale axes to have equivalent x- and y- scaling
maxxy = max([max(lat_acc_pts_g)-min(lat_acc_pts_g) max(lng_acc_pts_g)-min(lng_acc_pts_g)]);
set(gca,'DataAspectRatio',[1 1 (max(veh_spd_pts_mps)-min(veh_spd_pts_mps))/maxxy])

% Labels
zlabel('Speed m/s')
xlabel('Lateral Accel (g)')
ylabel('Long. Accel (g)')
if(~hold_fig)
    title(['GGV Diagram (Vehicle: ' vehicle_name ')']);
else
    title('GGV Diagram');
end     
    
view(100,7)
grid on
box on
