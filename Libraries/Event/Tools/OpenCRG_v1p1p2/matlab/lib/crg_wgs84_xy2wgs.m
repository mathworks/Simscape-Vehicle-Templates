function [wgs, data] = crg_wgs84_xy2wgs(data, pxy)
%CRG_WGS84_XY2WGS CRG transform point in xy to WGS84.
%   [WGS, DATA] = CRG_WGS84_XY2WGS(DATA, PXY) transforms points given in xy
%   system to WGS84 coordinates.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%   PXY     (np, 2) array of points in xy system
%
%   Outputs:
%   WGS     (np, 2) array of latitude/longitude (north/east) wgs84
%           coordinate pairs (in degrees)
%   DATA    struct array as defined in CRG_INTRO.
%
%   Examples:
%   [wgs, data] = crg_wgs84_xy2wgs(data, pxy)
%   transforms pxy points to WGS84 coordinates
%
%   See also CRG_INTRO, CRG_WGS84_WGSXY2WGS.

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
%   $Id: crg_wgs84_xy2wgs.m 222 2011-02-13 09:33:47Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% simplyfy data access

crgeps = data.opts.ceps;
crgtol = data.opts.ctol;

xbeg = data.head.xbeg;
ybeg = data.head.ybeg;

wgs = zeros(size(pxy));


%% check if WGS84 end is available, evaluate

if isfield(data.head, 'eend') % start and end are both defined
    wgs1 = [data.head.nbeg data.head.ebeg];
    wgs2 = [data.head.nend data.head.eend];
    pxy1 = [data.head.xbeg data.head.ybeg];
    pxy2 = [data.head.xend data.head.yend];
    wgs = crg_wgs84_wgsxy2wgs(wgs1, wgs2, pxy1, pxy2, pxy, crgeps, crgtol);
elseif isfield(data.head, 'ebeg') % only start is defined
    for i = 1:size(pxy, 1)
        dist = sqrt((pxy(i,1)-xbeg)^2 + (pxy(i,2)-ybeg)^2);
        if dist <= crgtol
            wgs(i,1) = data.head.nbeg;
            wgs(i,2) = data.head.ebeg;
        else
            error('CRG:wgs84Error', 'insufficient WGS84 information available')
        end
    end
else
    error('CRG:wgs84Error', 'no WGS84 information available')
end

end
