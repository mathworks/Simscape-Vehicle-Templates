function sm_car_grid_to_crg(road_name,road_opts)
% Function to produce road and geometry from grid data in Excel.
%
% <root file name>_dat.mat          Skeleton data to produce CRG file
% <root file name>.crg              Road definition
% <root file name>.stl              Road geometry
%
% Copyright 2019-2025 The MathWorks, Inc.

% Basic settings
root_outfiles = strrep(road_name,' ','_');
create_stl_files   = road_opts.create_stl_files;

% Move to directory for file creation
cd(fileparts(which([root_outfiles '_grid.xlsx'])));

%% Import the grid data from Excel workbook.
tbl = readtable([root_outfiles '_grid.xlsx'], "UseExcel", false);

% Extract longitudinal grid data (nx1)
x_o = tbl.x_m;

% Extract lateral grid data (mx1)
yidx = startsWith(string(tbl.Properties.VariableNames),"y");
ycol = tbl{:,yidx};
% Likely far fewer points than length, must remove NaN
y_o = ycol(~isnan(ycol));

% Extract vertical grid data (nxm)
zidx = startsWith(string(tbl.Properties.VariableNames),"z");
z_o = tbl{:,zidx};

% Extract heading grid data (length, nx1)
phiidx = startsWith(string(tbl.Properties.VariableNames),"phi");
phi_o = tbl{:,phiidx};

% Distance is x-data  
Distance_m  = x_o;
    
% Scale distance to an even number of meters
Distance_m = Distance_m*(floor(Distance_m(end))/Distance_m(end));
    
% Move start of track to [0 0 0]
x_o = x_o - x_o(1);
y_o = y_o - (y_o(end)+y_o(1))/2;
z_o = z_o - max(z_o(1,:));

% Interpolate to get regular grid
r_d = road_opts.decim_data;
dist_i = linspace(0,Distance_m(end),(Distance_m(end))/r_d+1);
x_i = interp1(Distance_m,x_o,dist_i,'linear')';
% Do not inerpolate y (width of road)
z_i = interp1(Distance_m,z_o,dist_i,'linear');
phi_i = interp1(Distance_m,phi_o,dist_i,'linear');
    
% Create Data structure for CRG file for road
road.u = dist_i(end); % Distance along the road
road.ct{1} = strrep(root_outfiles,'_', ' ');

%% Define grid points along width
road.v = y_o;

% Define table for grid height
road.z = z_i;

% Define table for heading angle
road.p = phi_i(2:end);

%% Generate CRG file for road surface
assignin('base','road',road)
crg_write(crg_single(road), [root_outfiles '.crg']);

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

%% Plot x-y-z grid
% Prepare first figure and handle
fig_handle_name =   'h1_grid_xyz';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Generate x, y, z vectors for all points
[xgrid, ygrid] = meshgrid(x_i,y_o);
xgrid = xgrid';
ygrid = ygrid';
xvec  = reshape(xgrid,[],1);
yvec  = reshape(ygrid,[],1);
zvec  = reshape(z_i,[],1);

% Plot using scatter3 to vary point color with height
scatter3(xvec,yvec,zvec,1,zvec);
box on
title('Road Grid Points');
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
