function [data] = crg_plot_road_uv2xyz_map(data, u, v)
% CRG_PLOT_ROAD_UV2XYZ_MAP CRG road XYZ map.
%   DATA = CRG_PLOT_ROAD_UV2XYZ_MAP(DATA, U, V) plots CRG road map
%   in current axes object for a given uv grid.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   U       vector of U grid values
%   V       vector of V grid values
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_plot_road_uv2xyz_map(data, 0:0.1:100, -2:0.1:2)
%       plots CRG road.
%   See also CRG_INTRO.

%   Copyright 2005-2013 OpenCRG - Daimler AG - Jochen Rauh
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%
%   More Information on OpenCRG open file formats and tools can be found at
%
%       http://www.opencrg.org
%
%   $Id: crg_plot_road_uv2xyz_map.m 331 2013-10-15 17:18:12Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% generate auxiliary data

nuiu = length(u);
nviv = length(v);

% grid coordinates in inertial system
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
    [pz, data] = crg_eval_xy2z(data, pxy);
    z(i, :) = pz;
end

%% plot road XYZ perspective map

data = crg_surf(data, x', y', z');

if data.head.xoff == 0 || data.head.poff ~= 0
    xlabel('X [m]')
else
    xlabel(sprintf('X [m] (%+dm)', data.head.xoff))
end
if data.head.yoff == 0 || data.head.poff ~= 0
    ylabel('Y [m]')
else
    ylabel(sprintf('Y [m] (%+dm)', data.head.yoff))
end
if data.head.zoff == 0
    zlabel('Z [m]')
else
    zlabel(sprintf('Z [m] (%+dm)', data.head.zoff))
end
title('CRG road XYZ map (in curved XY grid)')

view(3)

end
