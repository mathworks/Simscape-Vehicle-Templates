function [data] = crg_plot_refline_xy_overview_map(data, iu)
% CRG_PLOT_REFLINE_XY_OVERVIEW_MAP CRG road refline XY overview map plot.
%   DATA = CRG_PLOT_REFLINE_XY_OVERVIEW_MAP(DATA, IU) plots CRG refline map
%   in current axes object.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   IU      U index for plot selection (default: full CRG)
%           IU(1): longitudinal start index
%           IU(2): longitudinal end index
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_plot_refline_xy_overview_map(data)
%       plots full map.
%   data = crg_show_refline_xy_overview_map(data, [1000 2000])
%       plots full map and highlights selected part.
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
%   $Id: crg_plot_refline_xy_overview_map.m 331 2013-10-15 17:18:12Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% evaluate DATA.z size

nu = size(data.z, 1);

%% check/complement optional arguments

if nargin < 2
    iu =  [1 nu];
end
if iu(1)<1 || iu(1) >= iu(2) || iu(2) > nu
    error('CRG:plotError', 'illegal IU index values iu=[%d %d] with nu=%d', iu(1), iu(2), nu);
end

%% generate auxiliary data

u = zeros(1, nu);
for i = 1:nu
    u(i) = data.head.ubeg + (i-1)*data.head.uinc;
end

if isfield(data, 'rx')
    rx = data.rx;
    ry = data.ry;
else
    rx = interp1([data.head.ubeg data.head.uend], [data.head.xbeg data.head.xend], u);
    ry = interp1([data.head.ubeg data.head.uend], [data.head.ybeg data.head.yend], u);
end

%% plot refline XY overview map

if iu(1)>1 || iu(2)<nu
    plot(rx, ry, ':') % plot total refline
    hold on
end

plot(rx(iu(1):iu(2)), ry(iu(1):iu(2)), '-') % plot selected refline part

hold on
plot(rx(iu(1)), ry(iu(1)), '>') % mark start of selected part
plot(rx(iu(2)), ry(iu(2)), 's') % mark end of selected part

axis equal
grid on

title('CRG reference line XY overview map')
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

end
