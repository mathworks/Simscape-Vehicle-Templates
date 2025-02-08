function grid_surface = sm_car_points_to_gridsurface(terrain_points,npts_x,npts_y,varargin)
%sm_car_points_to_gridsurface Produce grid surface data array of points.
%   grid_surface = sm_car_points_to_gridsurface(terrain_points,npts_x,npts_y,<showplot>)
%   This function returns grid surface data extracted from STL geometry.
%   The output is a structure with fields:
%
%        x              Vector of x-coordinates
%        y              Vector of y-coordinates
%        z_heights      Matrix of heights along z-axis
%        z_heights_data Matrix of heights along z-axis 
%                       (backup in case z_heights is set to 0 to test a
%                       flat surface)
%
%   You must specify:
%       terrain_points  Array of points [npoints x 3]
%       npts_x          Number of sample points along x
%       npts_y          Number of sample points along y
%
%   You can optionally specify:
%       showplot        'plot' to produce a plot of data with STL mesh

% Copyright 2021-2024 The MathWorks, Inc

showplot = 'n';
if (nargin==4)
    showplot = varargin(end);
end

% Remove repeated XY points
[~ ,uniqueInd] = unique(terrain_points(:,[1 2]),'Rows','stable');
terrain_points_new = terrain_points(uniqueInd,:);

% Separate them into x, y, and z data
x = terrain_points_new(:,1);
y = terrain_points_new(:,2);
z = terrain_points_new(:,3);

% Create an interpolant that fits a surface of the form z = F(x,y)
F = scatteredInterpolant(x,y,z);

% Create grid vectors with desired spacing for grid surface
grid_surface.xg = linspace(min(x), max(x), npts_x); % x-grid vector
grid_surface.yg = linspace(min(y), max(y), npts_y); % y-grid vector

%  Using this syntax to conserve memory when querying a large grid of points.
grid_surface.z_heights = F({grid_surface.xg,grid_surface.yg}); 

% Store a backup of the heights in case model sets them to zero.
% - not needed for grid surface test, kept for reference
%grid_surface.z_heights_data = grid_surface.z_heights; 

% Create point cloud visualization on top of the grid.
% For plot only
[Xg, Yg] = ndgrid(grid_surface.xg, grid_surface.yg);
gs.ptcloud = [Xg(:) Yg(:) grid_surface.z_heights(:)];

% Plot diagram to show parameters and extrusion
if (nargin == 0 || strcmpi(showplot,'plot'))

    % Figure name
    figString = ['h1_' mfilename];
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
    clf(fig_h)

    temp_colororder = get(gca,'defaultAxesColorOrder');

    %trimesh(stl_points,'DisplayName','STL File','FaceAlpha',0);
    hold on
    mesh(grid_surface.xg,grid_surface.yg,grid_surface.z_heights','LineWidth',2,'EdgeColor',temp_colororder(2,:),'FaceAlpha',0.2,'DisplayName','Grid Surface')

    % Code to show original x-y-z data from STL
    plot3(gs.ptcloud(:,1),gs.ptcloud(:,2),gs.ptcloud(:,3),'k.',...
    'MarkerSize',10,'DisplayName','Point Cloud')

    hold off
    % For large surfaces, it may be better to let axes scale automatically
    %axis equal
    legend('Location','Best');
    box on
    title('STL to Surface (axes not equal)')

end
