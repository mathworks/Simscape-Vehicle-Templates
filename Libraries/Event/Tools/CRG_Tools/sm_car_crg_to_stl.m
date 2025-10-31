function [x1, y1, z1] = sm_car_crg_to_stl(crg_file,stl_file,varargin)
%sm_car_crg_to_stl  Create STL file from CRG file
%   sm_car_crg_to_stl(crg_file,stl_file)
%   Use CRG functions to generate MATLAB surface, 
%   and convert that surface to an STL.
%
%   Outputs are points used to define the STL.
%
% Copyright 2018-2025 The MathWorks, Inc.

% Defaults
x_extension = 0;
showplot = 'n';

% Check if extension specified
if (nargin >= 2)
    x_extension = varargin{1};
end
% Check if plot requested
if (nargin >= 2)
    showplot = varargin{2};
end

% Create STL from CRG
% crg_read is a from OpenCRG
crg_data = crg_read(crg_file);
data = crg_data;
[nu, nv] = size(data.z);

iu =  [1 nu];
iv =  [1 nv];

%% Generate Auxiliary Data
nuiu = iu(2) - iu(1) + 1;
nviv = iv(2) - iv(1) + 1;

u = zeros(1, nuiu);
for i = 1:nuiu
    u(i) = data.head.ubeg + (i-1+iu(1)-1)*data.head.uinc;
end

if isfield(data.head, 'vinc')
    v = zeros(1, nviv);
    for i=1:nviv
        v(i) = data.head.vmin + (i-1+iv(1)-1)*data.head.vinc;
    end
else
    v = double(data.v(iv(1):iv(2)));
end

% Grid Coordinates in Inertial System
x = zeros(nuiu, nviv);
y = zeros(nuiu, nviv);
z = zeros(nuiu, nviv);
puv = zeros(nviv, 2);
for i = 1:nuiu
    puv(:, 1) = u(i);
    puv(:, 2) = v';
    [pxy, data] = crg_eval_uv2xy(data, puv);
    x(i, :) = pxy(: , 1);
    y(i, :) = pxy(: , 2);
    [pz, data] = crg_eval_uv2z(data, puv);
    z(i, :) = pz;
end

% Add flat surface at end along +x axis if desired
x1 = [x;x(end,:)+x_extension];
y1 = [y;y(end,:)];
z1 = [z;z(end,:)];

% Write STLs for upper and lower surface temporarily
surf2stl('temp_stl_upper.stl',flipud(x1),flipud(y1),flipud(z1),'ascii')
surf2stl('temp_stl_lower.stl',x1,y1,z1,'ascii')

% Merge upper and lower surfaces into a single STL file.
upr_fid = fopen('temp_stl_upper.stl');
low_fid = fopen('temp_stl_lower.stl');
uprlow_fid = fopen(stl_file,'w');
line_of_text = 'firstline';

while(~contains(line_of_text,'endsolid'))
    line_of_text = fgets(upr_fid);
    if(~contains(line_of_text,'endsolid'))
        fprintf(uprlow_fid,line_of_text);
    end
end

skip_line = 1;
while(~feof(low_fid))
    line_of_text = fgets(low_fid);
    if((skip_line==1) && contains(line_of_text,'facet normal'))
        skip_line = 0;
    end
    if(skip_line==0)
        fprintf(uprlow_fid,line_of_text);
    end
end

% Close files
fclose(upr_fid);
fclose(low_fid);
fclose(uprlow_fid);

% Delete temporary STL files
delete('temp_stl_lower.stl');
delete('temp_stl_upper.stl');

% Plot surface if desired
if (strcmpi(showplot,'plot'))
    
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
    
    % Plot surface
    surf(x1',y1',z1','LineStyle','none')
    title(strrep(stl_file,'_','\_'));
    axis equal
    box on
end


