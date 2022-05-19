function [data] = crg_plot_refline_xy_map_and_curv(data, iu)
% CRG_PLOT_REFLINE_XY_MAP_AND_CURV CRG road refline XY map and curv plot.
%   DATA = CRG_PLOT_REFLINE_XY_MAP_AND_CURV(DATA, IU) plots CRG refline map
%   with norm. neg. curvature representation as orthogonal of reference
%   line in current axes object.
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
%   data = crg_plot_refline_xy_map_and_curv(data)
%       plots full map.
%   data = crg_plot_refline_xy_map_and_curv(data, [1000 2000])
%       plots selected map part.
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
%   $Id: crg_plot_refline_xy_map_and_curv.m 331 2013-10-15 17:18:12Z jorauh $

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

nuiu = iu(2) - iu(1) + 1;

u = zeros(1, nuiu);
for i = 1:nuiu
    u(i) = data.head.ubeg + (i-1+iu(1)-1)*data.head.uinc;
end

if isfield(data, 'rx')
    rx = data.rx(iu(1):iu(2));
    ry = data.ry(iu(1):iu(2));
    ph = [double(data.p) data.head.pend]; ph = ph(iu(1):iu(2));
    rc = [0 data.rc 0]                  ; rc = rc(iu(1):iu(2));
    rcmax = max(abs(data.rc));
else
    rx = interp1([data.head.ubeg data.head.uend], [data.head.xbeg data.head.xend], u);
    ry = interp1([data.head.ubeg data.head.uend], [data.head.ybeg data.head.yend], u);
    ph = zeros(1, nuiu) + data.head.pbeg;
    rc = zeros(1, nuiu);
    rcmax = 0;
end

% generate norm. curvature as orthogonal of refline
% global curvature scaled to 0.1 of selected refline length

rrmax = nuiu*data.head.uinc;
rcmax = rcmax + data.opts.ceps;

cnorm = -0.1 * rrmax/rcmax; % scale to 0.1 of selected refline size

rxc = rx - cnorm*rc.*sin(ph);
ryc = ry + cnorm*rc.*cos(ph);

%% plot refline XY map with norm. curvature

plot(rx, ry, '-', rxc, ryc, '-')

hold on
plot(rx(  1), ry(  1), '>') % mark start
plot(rx(end), ry(end), 's') % mark end

axis equal
grid on

title('CRG reference line XY map with norm. neg. curvature')
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
legend('reference line', 'n. n. curvature')

end
