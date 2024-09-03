function sm_car_centerline_to_crg(road_name,road_opts)
% Function to produce road and geometry from centerline data in Excel.
%
% <root file name>_dat.mat          Skeleton data to produce CRG file
% <root file name>.crg              Road definition
% <root file name>.stl              Road geometry
% <root file name>_centerline.crg   Centerline definition
% <root file name>_centerline.stl   Centerline geometry
%
% Copyright 2019-2024 The MathWorks, Inc.

% Basic settings
root_outfiles = strrep(road_name,' ','_');
create_stl_files   = road_opts.create_stl_files;
create_stl_files_f = road_opts.create_stl_files_f;

% Move to directory for file creation
cd(fileparts(which([root_outfiles '_centerline.xlsx'])));

% If centerline is defined by GPS data

if(strcmpi(road_opts.datasrc,'gps'))
    %% Import the GPS-data from Excel workbook.
    % If no Altitude data is availiable you can use
    % 'https://www.gpsvisualizer.com/convert_input'
    % to get altitude based on GPS co-ordinates
    % Choose 'best availiable source' on the
    % dropdown menu titled 'Add DEM elevation data')
    opts = spreadsheetImportOptions("NumVariables", 5);
    opts.Sheet = "Sheet1";
    opts.VariableNames = ["latitude", "longitude", "altitude_m", "distance_km", "Distance_m"];
    opts.VariableTypes = ["double", "double", "double", "double", "double"];
    
    tbl = readtable([root_outfiles '_centerline.xlsx'], opts, "UseExcel", false);
    
    % Convert to output type and remove header row
    Altitude_m = tbl.altitude_m(2:end);
    Distance_m = tbl.Distance_m(2:end);
    Latitude   = tbl.latitude(2:end);
    Longitude  = tbl.longitude(2:end);
    
    % Remove sequential, duplicate points
    LongLatAlt = [Longitude Latitude Altitude_m];
    valid_inds = find([1 ;(sum([LongLatAlt(2:end,:) == LongLatAlt(1:end-1,:)],2)~=3)]);
    Distance_m = Distance_m(valid_inds);
    Latitude = Latitude(valid_inds);
    Longitude = Longitude(valid_inds);
    Longitude = Longitude(valid_inds);
    
    if(road_opts.reverse)
        Altitude_m = flipud(Altitude_m);
        Distance_m = Distance_m(end)-flipud(Distance_m);
        Latitude   = flipud(Latitude);
        Longitude  = flipud(Longitude);
    end
    
    % Scale distance to an even number of meters
    Distance_m = Distance_m*(floor(Distance_m(end))/Distance_m(end));
    
    % Ensure last point is same as first point
    if(road_opts.blending_distance>0)
        Altitude_m(end) = Altitude_m(1);
        Latitude(end)   = Latitude(1);
        Longitude(end)  = Longitude(1);
    end
    % Convert Data to x-y-z (Original data)
    [x_o,y_o,~] = deg2utm(Latitude,Longitude);
    
    % Move start of track to [0 0 0]
    x_o = x_o-x_o(1);
    y_o = y_o-y_o(1);
    z_o = Altitude_m - Altitude_m(1);
    
elseif(strcmpi(road_opts.datasrc,'xyz'))
    %% Import the XYZ-data from Excel workbook.
    opts = spreadsheetImportOptions("NumVariables", 5);
    opts.Sheet = "Sheet1";
    opts.VariableNames = ["x_m", "y_m", "z_m", "Distance_m"];
    opts.VariableTypes = ["double", "double", "double", "double"];
    
    tbl = readtable([root_outfiles '_centerline.xlsx'], opts, "UseExcel", false);
    
    % Convert to output type and remove header row
    x_o         = tbl.x_m(2:end);
    y_o         = tbl.y_m(2:end);
    z_o         = tbl.z_m(2:end);
    Distance_m  = tbl.Distance_m(2:end);
    
	% Remove sequential, duplicate points
    xyz_o = [x_o y_o z_o];
    valid_inds = find([1; (sum([xyz_o(2:end,:) == xyz_o(1:end-1,:)],2)~=3)]);
    x_o = x_o(valid_inds);
    y_o = y_o(valid_inds);
    z_o = z_o(valid_inds);
    Distance_m = Distance_m(valid_inds);

    if(road_opts.reverse)
        x_o = flipud(x_o);
        y_o = flipud(y_o);
        z_o = flipud(z_o);
        Distance_m = Distance_m(end)-flipud(Distance_m);
    end
    
    % Scale distance to an even number of meters
    Distance_m = Distance_m*(floor(Distance_m(end))/Distance_m(end));
    
    % Ensure last point is same as first point
    if(road_opts.blending_distance>0)
        x_o(end) = x_o(1);
        y_o(end) = y_o(1);
        z_o(end) = z_o(1);
    end
    
    % Move start of track to [0 0 0]
    x_o = x_o - x_o(1);
    y_o = y_o - y_o(1);
    z_o = z_o - z_o(1);
end

% Force final point to align with start point
if(road_opts.blending_distance>0)
    x_o(end) = x_o(1);
    y_o(end) = y_o(1);
    z_o(end) = z_o(1);
end

%% Interpolate data
if(strcmpi(road_opts.datasrc,'gps'))
    % Number of points = 1 more than number of segments
    % Segment length resolution must be >= 1e-3 meters
    % Do not use linear interpolation, as curvature will be too sharp
    % Skip points if data is too discretized, let interpolation smooth it.
    r_d = road_opts.decim_data;
    a_d = road_opts.decim_alti;
    dist_i = linspace(0,Distance_m(end),(Distance_m(end))/r_d+1);
    lati_i = interp1(Distance_m,Latitude,dist_i,'spline');
    long_i = interp1(Distance_m,Longitude,dist_i,'spline');
    alti_i = interp1(Distance_m(1:a_d:end),Altitude_m(1:a_d:end),dist_i,'spline');
    
    % Convert Data to x-y-z (Interpolated)
    [x_i,y_i,~] = deg2utm(lati_i,long_i);
    
    % Move start of track at [0 0 0]
    x_i = x_i-x_i(1);
    y_i = y_i-y_i(1);
    z_i = [alti_i - alti_i(1)]';
    
    % Smooth altitude data
    z_i = smooth(z_i');
    
elseif(strcmpi(road_opts.datasrc,'xyz'))
    % Number of points = 1 more than number of segments
    % Segment length resolution must be >= 1e-3 meters
    % Do not use linear interpolation, as curvature will be too sharp
    % Skip points if data is too discretized, let interpolation smooth it.
    r_d = road_opts.decim_data;
    a_d = road_opts.decim_alti;
    dist_i = linspace(0,Distance_m(end),(Distance_m(end))/r_d+1);
    x_i = interp1(Distance_m,x_o,dist_i,'spline')';
    y_i = interp1(Distance_m,y_o,dist_i,'spline')';
    z_i = interp1(Distance_m(1:a_d:end),z_o(1:a_d:end),dist_i,'spline');
    
    % Move start of track at [0 0 0]
    x_i = x_i-x_i(1);
    y_i = y_i-y_i(1);
    z_i = [z_i - z_i(1)]';
    
    % Smooth altitude data
    z_i = smooth(z_i');
end

%% Determine Derivatives
x_d = diff(x_i);
y_d = diff(y_i);
z_d = diff(z_i);
s_d = diff(dist_i)';

%% Determine Slope (%/100)
Slope_c = z_d./s_d;
% Alternate calculation, appears not what is used by CRG
% Slope_c = z_d./sqrt(x_d.^2+y_d.^2);

%% Determine Heading (-pi ; pi)
% Unwrap the value to be able to smooth heading
Heading_c = ((unwrap(atan2(y_d,x_d))));
orient_xyz_o = Heading_c(1);
Heading_c = Heading_c - (Heading_c(1)); % Initial heading to 0 rad (+x)
Heading_c = wrapToPi(Heading_c); % wrap to Pi

% Create Data structure for CRG file for road
road.u = dist_i(end); % Distance along the road
road.p = Heading_c';  % Heading (rad, -pi to pi)
road.s = Slope_c';    % Slope (0 to 1)
road.b = 0;           % Bank
road.ct{1} = strrep(root_outfiles,'_', ' ');

%% Define road profile
% (road.z width + min_inc ) / (# points) = integer
%                    (15+1) / (16) = 1
%                    (15+1) / (4) = 4
% road.z(1:(length(x)+0),1:6) = 0; % Local road deviations - all set to 0 produces a smooth road
% road.z = rand([length(x) 4])/100; % Local road deviations - random - takes a looong time 16 can also work

% With gulleys on edges
% road.v = 15.0;   % Half width of the road
% road_profile_L = [0.3 -0.25 0.3 -0.1 0 0.05 0.07 0.08];

% Flat profile
road.v = road_opts.road_width;	% Half width of the road
road_profile_L = [0 0 0]; % Heights of profile

% Mirror profile
road_profile   = [road_profile_L fliplr(road_profile_L)];

% Define table for grid height
road.z = ones(length(x_i),length(road_profile));
for i = 1:length(road_profile)
    road.z(:,i) = road_profile(i);
end

%% Generate CRG file for road surface
assignin('base','road',road)
crg_write(crg_single(road), [root_outfiles '.crg']);

% Save key data to .mat file
dat = crg_read([root_outfiles '.crg']);

%% --- Regenerate CRG attempting to match start and end points
x_ctr = dat.rx;
y_ctr = dat.ry;

if(isfield(dat,'rz'))
    z_ctr = dat.rz;
else
    z_ctr = zeros(size(x_ctr));
end

% Calculate distance along trajectory.
% Used for interpolation.
s_ctr = [0 cumsum( sqrt( (diff(x_ctr)).^2 + (diff(y_ctr)).^2 + (diff(z_ctr)).^2))];

% For plot only
x_ctr_orig = x_ctr;
y_ctr_orig = y_ctr;
z_ctr_orig = z_ctr;
s_ctr_orig = s_ctr;
% Use data from first pass as a starting point
if(road_opts.blending_distance>0)
    
    
    % Determine offset from initial CRG (finish - start)
    offset_x = x_ctr(end) - x_ctr(1);
    offset_y = y_ctr(end) - z_ctr(1);
    offset_z = z_ctr(end) - y_ctr(1);
    
    % --- Smooth end of driver trajectory to line up with start
    % Interpolate from (end-blend distance) to (portion of start)
    blend_distance = road_opts.blending_distance;
    blend_inds_sta = find(s_ctr<(blend_distance*0.1));
    blend_inds     = find(s_ctr>(s_ctr(end)-blend_distance));
    
    % Assemble vector for interpolation: blend distance + portion of start
    % Offset scaling factors are trajectory specific (trial and error)
    xa = road_opts.xa;
    xb = road_opts.xb;
    ya = road_opts.ya;
    yb = road_opts.yb;
    za = road_opts.za;
    zb = road_opts.zb;
    
    x4_interp = [x_ctr(blend_inds) x_ctr(blend_inds_sta)-offset_x*xa+xb];
    y4_interp = [y_ctr(blend_inds) y_ctr(blend_inds_sta)-offset_y*ya+yb];
    z4_interp = [z_ctr(blend_inds) z_ctr(blend_inds_sta)+offset_z*za+zb];
    s4_interp = [0 cumsum( sqrt( (diff(x4_interp)).^2 + (diff(y4_interp)).^2 + (diff(z4_interp)).^2))];
    
    % Use a few points from start of blending distance and start of centerline
    interp_inds = [1:4 (length(s4_interp)-length(blend_inds_sta)+1):length(s4_interp)];
    % X: linear interpolation of points
    % Y: pchip interpolation, ensure transition at end is smooth
    % Z: pchip interpolation, ensure slope is aligned at end
    x_ctr_int = interp1(s4_interp(interp_inds),x4_interp(interp_inds),s4_interp);
    y_ctr_int = interp1(s4_interp(interp_inds),y4_interp(interp_inds),s4_interp,'pchip');
    z_ctr_int = interp1(s4_interp(interp_inds),z4_interp(interp_inds),s4_interp,'pchip');
    
    % Replace points on centerline with interpolated points
    x_ctr(blend_inds) = x_ctr_int(1:length(blend_inds));
    y_ctr(blend_inds) = y_ctr_int(1:length(blend_inds));
    z_ctr(blend_inds) = z_ctr_int(1:length(blend_inds));
    
    %% Do not recalculate distance with new interpolated points
    % Otherwise entire x-y-z data must be resampled
    % Distance calculation shown as reference
    %dist_i = [0 cumsum( sqrt( (diff(x_ctr)).^2 + (diff(y_ctr)).^2 + (diff(z_ctr)).^2))];
    
    %% Determine derivatives for slope, curvature
    x_d = diff(x_ctr);
    y_d = diff(y_ctr);
    z_d = diff(z_ctr);
    s_d = diff(dist_i);
    
    %% Determine Slope (0 - 1)
    Slope_c = z_d./s_d;
    
    %% Determine Heading (-pi ; pi)
    % Unwrap the value
    Heading_c = ((unwrap(atan2(y_d,x_d))));
    %orient_xyz = Heading_c(1);
    Heading_c = Heading_c - (Heading_c(1)); % Initial heading to 0 rad (+x)
    Heading_c = wrapToPi(Heading_c); % wrap to Pi
    
    % Create Data structure for CRG file for road
    road.u = dist_i(end); % Distance along the road
    road.p = Heading_c;   % Heading (rad, -pi to pi)
    road.s = Slope_c;     % Slope (0 to 1)
    
    % Flat profile
    road.v = road_opts.road_width;	% Half width of the road
    road_profile_L = [0 0 0];       % Heights of profile
    
    % Mirror profile
    road_profile   = [road_profile_L fliplr(road_profile_L)];
    
    % Define table for grid height
    road.z = ones(length(x_ctr),length(road_profile));
    for i = 1:length(road_profile)
        road.z(:,i) = road_profile(i);
    end
    
    %% Generate CRG file for road surface
    crg_write(crg_single(road), [root_outfiles '.crg']);
    
    %%----- End regenerate CRG
end
% Save key data to .mat file
dat = crg_read([root_outfiles '.crg']);
save([root_outfiles '_dat'],'dat');
movefile([root_outfiles '_dat.mat'],['..' filesep]);

% Show CRG
% Commented out on purpose - produces many plots
% crg_show(dat);

%% Generate STL file for road surface
if(create_stl_files)
    disp(['Creating ' root_outfiles '.stl ...']);
    sm_car_crg_to_stl(...
        [root_outfiles '.crg'],...
        [root_outfiles '.stl'],0,'plot')
    disp('... finished');
    % Move STL file down one level
    movefile(...
        [root_outfiles '.stl'],['..' filesep])
end

% Move CRG file down one level
movefile(...
    [root_outfiles '.crg'],['..' filesep])

%% Create CRG data structure for centerline
centerline = road;
centerline.v = 0.15; % width of the centerline [m]
centerline.z = zeros(length(x_ctr),4); % Flat profile

%% Write CRG file for STL generation only
crg_write(crg_single(centerline), [root_outfiles '_centerline.crg']);

%% Create STL
if(create_stl_files)
    disp(['Creating ' root_outfiles '_centerline.stl ...']);
    sm_car_crg_to_stl(...
        [root_outfiles '_centerline.crg'],...
        [root_outfiles '_centerline.stl'],0,'n')
    disp('... finished');
    % Move STL file down one level
    movefile(...
        [root_outfiles '_centerline.stl'],['..' filesep])
end

% Move CRG file down one level
movefile(...
    [root_outfiles '_centerline.crg'],['..' filesep])

%% Plot Centerline
if(~isfield(dat,'rz'))
    dat.rz = zeros(size(x_ctr));
end

dat_ctr = [0 cumsum( sqrt( (diff(dat.rx)).^2 + (diff(dat.ry)).^2 + (diff(dat.rz)).^2))];
label_str = sprintf('Road: %s',...
    strrep(root_outfiles,'_',' '));

% Prepare first figure and handle
fig_handle_name =   'h1_road_xy_centerline';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

R = [cos(-orient_xyz_o), -sin(-orient_xyz_o); sin(-orient_xyz_o), cos(-orient_xyz_o)];
xy_r = R*[x_o y_o]';

plot(dat.rx,dat.ry,'-','LineWidth',2);
hold on
plot(x_ctr_orig,y_ctr_orig,'--','LineWidth',1);
plot(xy_r(1,1:end-1),xy_r(2,1:end-1),'--o');
hold off
axis equal

ind_interval = 50;
inds = 1:ind_interval:length(x_o);
text(xy_r(1,inds),xy_r(2,inds),string(inds),'Color','b')

ind_interval = 1000;
inds = 1:ind_interval:length(x_i);
text(x_ctr(inds),y_ctr(inds),string(inds),'Color','r')

title('Road Centerline (x-y)');
text(0.05,0.05,label_str,...
    'Units','Normalized','Color',[1 1 1]*0.5);
legend({'CRG Final','CRG Original','GPS'},'Location','Best')

%% Plot x-y-z components
% Prepare first figure and handle
fig_handle_name =   'h2_road_xyz';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

simlog_handles(1) = subplot(3,1,1);
plot(Distance_m,xy_r(1,:),'-','LineWidth',1);
hold on
plot(dist_i,x_ctr,'--','LineWidth',1);
plot(s_ctr_orig,x_ctr_orig,'-.');
plot(dat_ctr,dat.rx);
hold off
title('Road Centerline (x, y, z vs Distance)');
text(0.025,0.2,label_str,...
    'Units','Normalized','Color',[1 1 1]*0.5);
legend({'Original','Interpolated','Initial CRG','Final CRG'},'Location','Best')
ylabel('X');

simlog_handles(2) = subplot(3,1,2);
plot(Distance_m,xy_r(2,:),'-');
hold on
plot(dist_i,y_ctr,'--');
plot(s_ctr_orig,y_ctr_orig,'-.');
plot(dat_ctr,dat.ry);
hold off
ylabel('Y');

simlog_handles(3) = subplot(3,1,3);
plot(Distance_m,z_o,'-');
hold on
plot(dist_i,z_ctr,'--');
plot(s_ctr_orig,z_ctr_orig,'-.');
plot(dat_ctr,dat.rz);
hold off
ylabel('Z');
xlabel('Distance along Road');

linkaxes(simlog_handles,'x');

%% Plots for reviewing interpolation
if(road_opts.blending_distance>0)
    fig_handle_name =   'h3_road_interp_xyz';
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    
    subplot(311),plot(s_ctr_orig,x_ctr_orig); hold on ;
    title('Centerline Cartesian Components')
    text(0.025,0.2,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    ylabel('x (m)');
    subplot(312),plot(s_ctr_orig,y_ctr_orig); hold on
    ylabel('y (m)');
    subplot(313),plot(s_ctr_orig,z_ctr_orig); hold on
    ylabel('z (m)');
    xlabel('Distance along Road (m)');
    
    % Overlay new data
    subplot(311),plot(s_ctr,x_ctr,'--'); hold off
    subplot(312),plot(s_ctr,y_ctr,'--'); hold off
    subplot(313),plot(s_ctr,z_ctr,'--'); hold off
    legend({'Original CRG','Input for Final CRG'},'Location','Best');
    
    fig_handle_name =   'h4_road_interp_section';
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    
    subplot(311),plot(s4_interp,x4_interp); hold on
    title('Interpolation Section, Cartesian Components')
    text(0.025,0.2,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    ylabel('x (m)');
    subplot(312),plot(s4_interp,y4_interp); hold on
    ylabel('y (m)');
    subplot(313),plot(s4_interp,z4_interp); hold on
    ylabel('z (m)');
    subplot(311),plot(s4_interp(interp_inds),x4_interp(interp_inds),'-d');
    subplot(312),plot(s4_interp(interp_inds),y4_interp(interp_inds),'-d');
    subplot(313),plot(s4_interp(interp_inds),z4_interp(interp_inds),'-d');
    xlabel('Distance along Road (m)');
    
    subplot(311),plot(s4_interp,x_ctr_int,'--'); hold off
    legend({'Original CRG','Points for Interp','Interpolated'},'Location','Best');
    subplot(312),plot(s4_interp,y_ctr_int,'--'); hold off
    subplot(313),plot(s4_interp,z_ctr_int,'--'); hold off
end
%% --- Road with no elevation ---
create_no_elevation = road_opts.create_no_elevation;
if(create_no_elevation)
    % Use dataset from road with elevation
    road_f = road;
    
    % Set elevation and slope to 0
    %    road_f.z = 0; % Overwrite previous data
    %    road_f.z = zeros(length(x_ctr),4) ;   % Local road elevation deltas
    road_f.z = zeros(size(road.z)) ;   % Local road elevation deltas
    road_f.s = zeros(1,length(x_ctr)-1); % Slope in percentage (0 to 1)
    road_f.b = 0; % Banking
    
    %% Generate CRG file for road surface (no elevation)
    crg_write(crg_single(road_f), [root_outfiles '_f.crg']);
    
    % Save key data to .mat file
    dat = crg_read([root_outfiles '_f.crg']);
    save([root_outfiles '_f_dat'],'dat');
    movefile([root_outfiles '_f_dat.mat'],['..' filesep]);
    
    % Show CRG
    % Commented out on purpose - produces many plots
    % crg_show(dat);
    
    %% Generate STL file for road surface (no elevation)
    if(create_stl_files_f)
        disp(['Creating ' root_outfiles '_f.stl ...']);
        sm_car_crg_to_stl(...
            [root_outfiles '_f.crg'],...
            [root_outfiles '_f.stl'],0,'n');
        disp('... finished');
        % Move STL file down one level
        movefile(...
            [root_outfiles '_f.stl'],['..' filesep])
    end
    % Move CRG file down one level
    movefile(...
        [root_outfiles '_f.crg'],['..' filesep])
    
    %% Use flat road data to create centerline for flat road
    centerline_f = road_f;
    centerline_f.v = 0.15; % Width of the centerline [m]
    
    %% Create CRG file for centerline (no elevation)
    crg_write(crg_single(centerline_f),...
        [root_outfiles '_f_centerline.crg']);
    
    %% Write CRG file (for STL generation only)
    if(create_stl_files_f)
        disp(['Creating ' root_outfiles '_f_centerline.stl ...']);
        sm_car_crg_to_stl(...
            [root_outfiles '_f_centerline.crg'],...
            [root_outfiles '_f_centerline.stl'],0,'n');
        disp('... finished');
        % Move STL file down one level
        movefile(...
            [root_outfiles '_f_centerline.stl'],['..' filesep])
    end
    
    % Move CRG file down one level
    movefile(...
        [root_outfiles '_f_centerline.crg'],['..' filesep])
end