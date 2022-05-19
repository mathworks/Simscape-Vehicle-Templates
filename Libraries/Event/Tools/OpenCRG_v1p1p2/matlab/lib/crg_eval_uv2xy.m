function [pxy, data] = crg_eval_uv2xy(data, puv)
%CRG_UV2XY CRG tranform point in uv to xy.
%   [PXY, DATA] = CRG_UV2XY(DATA, PUV) transforms points given in uv
%   coordinate system to xy coordinate system.
%
%   Inputs:
%       DATA    struct array as defined in CRG_INTRO.
%       PUV     (np, 2) array of points in uv system
%
%   Outputs:
%       PXY     (np, 2) array of points in xy system
%       DATA    struct array as defined in CRG_INTRO.
%
%   Examples:
%   pxy = crg_eval_uv2xy(data, puv) transforms puv positions to pxy
%   positions.
%
%   See also CRG_INTRO.

%   Copyright 2005-2010 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_eval_uv2xy.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% simplify data access 1

ubeg = data.head.ubeg;

xbeg = data.head.xbeg;
ybeg = data.head.ybeg;

pbec = data.dved.pbec;
pbes = data.dved.pbes;

%% straight reference line: simple transformation only

if ~isfield(data, 'rx')
    du = puv(:, 1) - ubeg;
    dv = puv(:, 2);

    pxy(:, 1) = xbeg + pbec*du - pbes*dv;
    pxy(:, 2) = ybeg + pbes*du + pbec*dv;

    return
end

%% for closed refline: map u values to valid interval

if data.opts.rflc==1 && data.dved.ulex~=0
    puv(:,1) = mod(puv(:,1)-data.dved.ubex, data.dved.ulex) + data.dved.ubex;
end

%% simplify data access 2

uinc = data.head.uinc;

xend = data.head.xend;
yend = data.head.yend;

penc = data.dved.penc;
pens = data.dved.pens;

rx   = data.rx;
ry   = data.ry;
nu = length(rx);

np = size(puv,1);

%% pre-allocate output

pxy = zeros(np, 2);

%% work on all points

for ip = 1:np
    pui = puv(ip, 1);
    pvi = puv(ip, 2);

    % find u interval in constantly spaced u axis
    ui = (pui - ubeg) / uinc;
    iu = min(max(0, floor(ui)), nu-2); % find u interval
    ui = ui - iu; % may be < 0 or > 1 to allow extrapolation

    if ui < 0 % extrapolation beyond ubeg: simple transformation
        du = ui*uinc;
        pxy(ip, 1)  = xbeg + du*pbec - pvi*pbes;
        pxy(ip, 2)  = ybeg + du*pbes + pvi*pbec;
        continue
    end

    if ui > 1 % extrapolation beyond uend: simple transformation
        du = (ui-1)*uinc;
        pxy(ip, 1)  = xend + du*penc - pvi*pens;
        pxy(ip, 2)  = yend + du*pens + pvi*penc;
        continue
    end

    iu = iu + 1; % MATLAB counts from 1

    x1 = rx(iu);
    x2 = rx(iu+1);
    y1 = ry(iu);
    y2 = ry(iu+1);

    if pvi == 0
        % A == P1 and B == P2
        xa = x1;
        xb = x2;
        ya = y1;
        yb = y2;
    else
        % calculate normal n12 on P1-P2
        n12x = -(y2-y1);
        n12y =  (x2-x1);
        nrm = 1.0 / sqrt(n12x^2 + n12y^2); % is 1/uinc if rx/ry are precise
        n12x = nrm*n12x;
        n12y = nrm*n12y;

        % calculate A
        if iu == 1 % first interval
            % n1 := n12 (normal n1 on P2-P1 as above)
            n1x = n12x;
            n1y = n12y;
        else % other intervals
            % calculate normal n1 on P2-P0
            x0 = rx(iu-1);
            y0 = ry(iu-1);
            n1x = -(y2-y0);
            n1y =  (x2-x0);
            nrm = 1.0 / sqrt(n1x^2 + n1y^2);
            n1x = nrm*n1x;
            n1y = nrm*n1y;
            % scale n1 by inverse of dot product n1.n12
            nrm = 1.0 / (n1x*n12x + n1y*n12y);
            n1x = nrm*n1x;
            n1y = nrm*n1y;
        end
        %  A is on (scaled) n1 through P1
        xa = x1 + pvi*n1x;
        ya = y1 + pvi*n1y;

        % calculate B
        if iu == nu-1 % last interval
            % n2 := n12 (normal n2 on P2-P1 as above)
            n2x = n12x;
            n2y = n12y;
        else
            % calculate normal n2 on P3-P1
            x3 = rx(iu+2);
            y3 = ry(iu+2);
            n2x = -(y3-y1);
            n2y =  (x3-x1);
            nrm = 1.0 / sqrt(n2x^2 + n2y^2);
            n2x = nrm*n2x;
            n2y = nrm*n2y;
            % scale n2 by inverse of dot product n2.n12
            nrm = 1.0 / (n2x*n12x + n2y*n12y);
            n2x = nrm*n2x;
            n2y = nrm*n2y;
        end
        %  B is on (scaled) n2 through P2
        xb = x2 + pvi*n2x;
        yb = y2 + pvi*n2y;
    end

    % evaluate x(u, v) and y(u, v) by linear interpolation on B-A
    pxy(ip, 1)  = (xb - xa)*ui + xa;
    pxy(ip, 2)  = (yb - ya)*ui + ya;
end
end
