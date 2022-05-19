function [data] = crg_wgs84_setend(data, dref)
%CRG_WGS84_SETEND CRG set WGS84 end coordinate.
%   [DATA] = CRG_WGS84_SETEND(DATA, DREF) sets missing WGS84 end
%   coordinate with given refline beg->end direction.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%   DREF    direction (bearing) for refline beg->end (in deg)
%           = -90 -> x-axis to west
%           =   0 -> x-axis to north
%           = +90 -> x-axis to east (default)
%           = 180 -> x-axis to south
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Examples:
%   [data] = crg_wgs84_setend(data)
%   sets missing WGS84 position with x-axis east orientation of beg->end
%
%   See also CRG_INTRO.

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
%   $Id: crg_wgs84_setend.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% check/complement optional arguments

if nargin < 2
    dref = 90;
end

%% simplyfy data access

xbeg = data.head.xbeg;
ybeg = data.head.ybeg;
xend = data.head.xend;
yend = data.head.yend;

%% check if WGS84 end is available, evaluate

if isfield(data.head, 'eend') % start and end are both defined
    error('CRG:wgs84Error', 'WGS84 end coordinate already set')
elseif isfield(data.head, 'ebeg') % only start is defined
    wgs1 = [data.head.nbeg data.head.ebeg];

    pref = atan2(yend-ybeg, xend-xbeg); % beg->end direction in xy
    dbeg = dref*pi/180 - pref; % beg->end direction in WGS84

    dist = sqrt((xend-xbeg)^2 + (yend-ybeg)^2);

    wgs2 = crg_wgs84_invdist(wgs1, dbeg, dist);

    data.head.nend = wgs2(1,1);
    data.head.eend = wgs2(1,2);
else
    error('CRG:wgs84Error', 'WGS84 beg coordinate missing')
end

%% check head again

data = crg_check_head(data); % force check

end
