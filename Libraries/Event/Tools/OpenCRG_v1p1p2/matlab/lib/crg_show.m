function [data] = crg_show(data, iu, iv)
% CRG_SHOW CRG road visualizer.
%   DATA = CRG_SHOW_ELGRID_SURFACE(DATA, IU, IV) visualizes CRG road info.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   IU      U index for plot selection (default: full CRG)
%           IU(1): longitudinal start index
%           IU(2): longitudinal end index
%   IV      V index for plot selection (default: full CRG)
%           IV(1): lateral start index
%           IV(2): lateral end index
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_show(data)
%       shows full CRG info.
%   data = crg_show(data, [1000 2000], [10 20])
%       shows partial CRG info.
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
%   $Id: crg_show.m 223 2011-02-13 15:56:54Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% evaluate DATA.z size

[nu nv] = size(data.z);

%% check/complement optional arguments

if nargin < 2
    iu =  [1 nu];
end
if iu(1)<1 || iu(1) >= iu(2) || iu(2) > nu
    error('CRG:showError', 'illegal IU index values iu=[%d %d] with nu=%d', iu(1), iu(2), nu);
end

if nargin < 3
    iv =  [1 nv];
end
if iv(1)<1 || iv(1) >= iv(2) || iv(2) > nv
    error('CRG:showError', 'illegal IV index values iv=[%d %d] with nv=%d', iv(1), iv(2), nv);
end

%% generate only useful figures

if isfield(data, 'rx')
    data = crg_show_refline_map(data, iu);
end

if isfield(data, 'rz') || isfield(data, 'b')
    data = crg_show_refline_elevation(data, iu);
end

data = crg_show_elgrid_cuts_and_limits(data, iu, iv);

nuiu = iu(2) - iu(1) + 1;

if isfield(data, 'rz') || isfield(data, 'b')
    if nuiu > 3000
        data = crg_show_elgrid_surface(data, ...
            [iu(1)                   iu(1)+1000             ], [1 nv]); % start
        data = crg_show_elgrid_surface(data, ...
            [iu(1)+round(nuiu/2)-500 iu(1)+round(nuiu/2)+500], [1 nv]); % mid
        data = crg_show_elgrid_surface(data, ...
            [iu(2)-1000              iu(2)                  ], [1 nv]); % end
    else
        data = crg_show_elgrid_surface(data, iu, iv);
    end
end

if nuiu > 3000
    data = crg_show_road_surface(data, ...
        [iu(1)                   iu(1)+1000             ], [1 nv]); % start
    data = crg_show_road_surface(data, ...
        [iu(1)+round(nuiu/2)-500 iu(1)+round(nuiu/2)+500], [1 nv]); % mid
    data = crg_show_road_surface(data, ...
        [iu(2)-1000              iu(2)                  ], [1 nv]); % end
else
    data = crg_show_road_surface(data, iu, iv);
end

data = crg_show_info(data);

end
