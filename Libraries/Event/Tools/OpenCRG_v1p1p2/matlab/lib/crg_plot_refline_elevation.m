function [data] = crg_plot_refline_elevation(data, iu)
% CRG_PLOT_REFLINE_ELEVATION CRG road refline elevation plot.
%   DATA = CRG_PLOT_REFLINE_ELEVATION(DATA, IU) plots CRG refline elevation
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
%   data = crg_plot_refline_elevation(data)
%       plots full refline data.
%   data = crg_plot_refline_elevation(data, [1000 2000])
%       plots selected refline data part.
%   See also CRG_INTRO.

%   Copyright 2005-2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_plot_refline_elevation.m 216 2011-02-05 21:59:55Z jorauh $

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

if isfield(data, 'rz')
    rz = data.rz(iu(1):iu(2));
else
    rz = zeros(1, nuiu) + data.head.zbeg;
end

%% plot refline elevation

plot(u, rz, '-')

hold on
plot(u(  1), rz(  1), '>') % mark start
plot(u(end), rz(end), 's') % mark end

grid on

title('CRG reference line elevation')
xlabel('U [m]')
if data.head.zoff == 0
    ylabel('Z [m]')
else
    ylabel(sprintf('Z [m] (%+dm)', data.head.zoff))
end

end
