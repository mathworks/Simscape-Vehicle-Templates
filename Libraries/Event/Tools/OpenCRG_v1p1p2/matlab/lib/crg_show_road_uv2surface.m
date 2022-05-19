function [data] = crg_show_road_uv2surface(data, u, v)
% CRG_SHOW_ELGRID_UV2SURFACE CRG road 3D surface visualizer.
%   DATA = CRG_SHOW_ELGRID_UV2SURFACE(DATA, U, V) visualizes CRG road 3D
%   surface info for a given uv grid.
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
%       shows CRG info.
%   See also CRG_INTRO.
%
%   Copyright 2005-2009 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_show_road_uv2surface.m 184 2010-09-22 07:41:39Z jorauh $

%% first check & fix & complement DATA

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% define figure frame

if ~isfield(data, 'fopt') || ~isfield(data.fopt, 'tit')
    data.fopt.tit = 'CRG road surface';
    data          = crg_figure(data);
    data.fopt     = rmfield(data.fopt, 'tit');
else
    data = crg_figure(data);
end

%% refline XY overview map

subplot(2,2,1)

data = crg_plot_refline_xy_overview_map(data);

puv(:,1) = [  u      0*v+u(end)   u(end:-1:1) 0*v+u(1)]';
puv(:,2) = [0*u+v(1)   v        0*u+v(end)      v     ]';

% puv(1,:) = [min(u) min(v)];
% puv(2,:) = [max(u) min(v)];
% puv(3,:) = [max(u) max(v)];
% puv(4,:) = [min(u) max(v)];
% puv(5,:) = puv(1,:);
[pxy data] = crg_eval_uv2xy(data, puv);
hold on
plot(pxy(:,1), pxy(:,2))

set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')


%% elevation grid XYZ perspective map

subplot(2,2,2)
data = crg_plot_road_uv2xyz_map(data, u, v);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

%% elevation grid UVZ orthographic map

subplot(2,2,[3 4])
data = crg_plot_road_uv2uvz_map(data, u, v);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

end
