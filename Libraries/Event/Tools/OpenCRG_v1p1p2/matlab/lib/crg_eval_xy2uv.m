function [puv, data] = crg_eval_xy2uv(data, pxy)
%CRG_EVAL_XY2UV CRG tranform point in xy to uv.
%   [PUV, DATA] = CRG_EVAL_XY2UV(DATA, PXY) transforms points given in
%   xy coordinate system to uv coordinate system. IF available, history of
%   a previous evaluations is used to start the search approprieately.
%
%   inputs:
%       DATA    struct array as defined in CRG_INTRO.
%       PXY     (np, 2) array of points in xy system
%
%   outputs:
%       PUV     (np, 2) array of points in uv system
%       DATA    struct array as defined in CRG_INTRO, with history added
%
%   Examples:
%   [puv, data] = crg_eval_xy2uv(data, pxy) transforms pxy points to puv
%   History information is updated in data on return from function.
%   [puv, data] = crg_eval_xy2uv(data, pxy) transforms pxy points to puv
%   History information is updated in data on return from function.
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
%   $Id: crg_eval_xy2uv.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% pre-allocate output

np = size(pxy, 1);
puv = zeros(np, 2);

%% simplify data access 1

px = pxy(:, 1);
py = pxy(:, 2);

ubeg = data.head.ubeg;

xbeg = data.head.xbeg;
ybeg = data.head.ybeg;

pbec = data.dved.pbec;
pbes = data.dved.pbes;

%% straight reference line: simple transformation only

if ~isfield(data, 'rx')
    dx = px - xbeg;
    dy = py - ybeg;

    puv(:, 1) = ubeg + pbec*dx + pbes*dy;
    puv(:, 2) =      - pbes*dx + pbec*dy;

    return
end

%% simplify data access

uend = data.head.uend;
uinc = data.head.uinc;

xend = data.head.xend;
yend = data.head.yend;

penc = data.dved.penc;
pens = data.dved.pens;

rx = data.rx;
ry = data.ry;
nu = length(rx);

%%  use history

mhisto = data.hist.m;
ohisto = data.hist.o;
chisto = data.hist.c;
fhisto = data.hist.f;
nhisto = data.hist.n;
ihisto = data.hist.i;
xhisto = data.hist.x;
yhisto = data.hist.y;

%TODO: preload/reset history with reference point, with special function, etc.
switch ohisto
    case -1 % forget history, restart search from beginning
        ohisto = 0;
        nhisto = 1;
        ihisto(1) = 1;
        xhisto(1) = rx(1);
        yhisto(1) = ry(1);
    case -2 % forget history, restart search from end
        ohisto = 0;
        nhisto = 1;
        ihisto(1) = nu;
        xhisto(1) = rx(nu);
        yhisto(1) = ry(nu);
end

iu = 0;
if ohisto > 0
    if nhisto > 0
        error('CRG:evalError', 'mixing of history seach and explicit history point no. not allowed')
    end
    if ohisto > mhisto
        error('CRG:evalError', 'history size of %d insufficient to store history point no.=%d', mhisto, ohisto)
    end
    if ihisto(ohisto) > 0
        jhisto = ohisto;
        iu = ihisto(ohisto);
    end
end

if iu == 0
    % look for search start interval in history
    dclose = realmax;
    iclose = 0;
    % TODO: search might be formulated more efficiently in MATLAB
    % using vector operations instead of loops
    for i = 1:nhisto
        hd = (pxy(1,1)-xhisto(i))^2 + (pxy(1,2)-yhisto(i))^2;
        if hd < chisto
            % first choice: closer than CHISTO to history points
            % (fast)
            dclose = hd;
            iclose = i;
            break;
        end
        if hd < dclose
            % second choice: find closest point in history
            % (still fairly fast)
            dclose = hd;
            iclose = i;
        end
    end

    if dclose < fhisto
        % we got a useful history point
        jhisto = iclose;
        iu = ihisto(iclose);
    else
        % best history point too far away, global search necessary
        dclose = realmax;
        iclose = 0;
        for i = 1:round(nu/1000):nu
            hd = (pxy(1,1)-rx(i))^2 +  (pxy(1,2)-ry(i))^2;
            if hd < dclose
                dclose = hd;
                iclose = i;
            end
        end
        jhisto = nhisto + 1;
        iu = iclose + 1;
    end
end

iu = min(max(2, iu), nu-1);

%% work on all points

% FIXME: watch for multiple points too far away - only for the first point
% of each call a history search/update is done.

for ip = 1:np

    % TODO: look if interval number IU could be made more close to what is
    % expected by reading the theory doc.

    % search for relevant reference line interval iu
    %  looking at some points
    %  P0: iu0 = iu - 2: (X0, Y0)
    %  P1: iu1 = iu - 1: (X1, Y1)
    %  P2: iu2 = iu    : (X2, Y2)
    %  P3: iu3 = iu + 1: (X3, Y3)
    %  P :               (X , Y ) (current input from function call)
    x = px(ip);
    y = py(ip);

%   forward search

    t_hd = 0; % check uend/ubeg closer to (x,y) than ubeg/uend

    while 1
        ium1 =     iu - 1     ;
        iup1 = min(iu + 1, nu);

        x1 = rx(ium1);
        y1 = ry(ium1);
        x2 = rx(iu  );
        y2 = ry(iu  );
        x3 = rx(iup1);
        y3 = ry(iup1);

        % evaluate dot product (P -P2).(P3-P1):
        % - unnormalized projection of (P -P2) on (P3-P1)
        % - hd is negative for P "left"  of normal on P3-P1 through P2
        % - hd is positive for P "right" of normal on P3-P1 through P2
        hdf = (x -x2)*(x3-x1) + (y -y2)*(y3-y1);

        % look if P belongs to current interval iu:
        %  update interval upwards as long as necessary/possible
        %  to make hd negative
        if hdf > 0
            if iu < nu
                iu = iu + 1;
            elseif data.dved.ulex~=0

                t_hd = (x-rx(1))*(rx(2)-rx(1)) + (y-ry(1))*(ry(2)-ry(1));

                if t_hd <= 0, break; end % ubeg may be closer
                iu = 2;
            else
                break
            end
        else
            break
        end
    end

%   backward search

    while 1
        ium2 = max(1, iu-2);
        ium1 =        iu-1 ;

        x0 = rx(ium2);
        y0 = ry(ium2);
        x1 = rx(ium1);
        y1 = ry(ium1);
        x2 = rx(iu  );
        y2 = ry(iu  );

        % evaluate dot product (P -P1).(P2- P0)
        % - unnormalized projection of (P -P1) on (P2-P0)
        % - hd is negative for P "left"  of normal on P2-P0 through P1
        % - hd is positive for P "right" of normal on P2-P0 through P1
        xxx1 = x -x1;
        x2x0 = x2-x0;
        yyy1 = y -y1;
        y2y0 = y2-y0;
        hdb = xxx1*x2x0 + yyy1*y2y0;

        % look if P belongs to current interval:
        %  update interval downwards as long as necessary/possible
        %  to make hd positive
        if hdb < 0
            if iu > 2
                iu = iu - 1;
            elseif data.dved.ulex~=0

                if t_hd~=0, break; end % uend already checked

                t_hd = (x-rx(nu))*(rx(nu)-rx(nu-1))+(y-ry(nu))*(ry(nu)-ry(nu-1));
                if t_hd >= 0, break; end % uend may be closer

                iu = nu;
            else
                break
            end
        else
            break
        end
    end

%   at this point we have got the right interval

    if ip == 1 % store interval of first PXY for history
        iuhist = iu;
    end

%   evaluate result

    if hdb < 0 % extrapolation beyond ubeg: simple transformation
        dx = x - xbeg;
        dy = y - ybeg;

        puv(ip, 1) = ubeg + pbec*dx + pbes*dy;
        puv(ip, 2) =      - pbes*dx + pbec*dy;

        if data.opts.rflc && data.dved.ulex~=0
            if puv(ip,1) < data.dved.ubex || ...
                     (puv(ip,1) > data.head.uend && puv(ip,1) < data.dved.uenx)
                dx = x - xend;
                dy = y - yend;

                puv(ip, 1) = uend + penc*dx + pens*dy;
                puv(ip, 2) =      - pens*dx + penc*dy;
            end
        end

        continue
    end

    if hdf > 0 % extrapolation beyond uend: simple transformation
        dx = x - xend;
        dy = y - yend;

        puv(ip, 1) = uend + penc*dx + pens*dy;
        puv(ip, 2) =      - pens*dx + penc*dy;

        if data.opts.rflc && data.dved.ulex~=0
            if puv(ip,1) > data.dved.uenx

                dx = x - xbeg;
                dy = y - ybeg;

                puv(ip, 1) = ubeg + pbec*dx + pbes*dy;
                puv(ip, 2) =      - pbes*dx + pbec*dy;
            end
        end

        continue
    end

    % evaluate v as distance between P and line trough P2-P1
    % by calculating the normalized cross product
    % (P2-P1)x(P-P1) / |P2-P1|
    x2x1 = x2-x1;
    y2y1 = y2-y1;
    %
    v = (x2x1*yyy1-y2y1*xxx1)/sqrt(x2x1^2+y2y1^2);

    % TODO: here we could check distance related to curvature:
    %  warn  if not closer than max/min curvature
    %  abort if not closer than current curvature

    % now we need a line parallel to P2-P1 through P,
    % cut this line with the normal on P2-P0 through P1 in A
    % cut this line with the normal on P3-P1 through P2 in B
    % evaluate
    %  du = |P-A|/|B-A|*|P2-P1|
    % which is (after some vector calculus) identical to
    %  du = ta/(ta+tb) * |P2-P1| with
    %  ta = ((P2-P0).(P -P1))/((P2-P0).(P2-P1))
    %  tb = ((P3-P1).(P2-P ))/((P3-P1).(P2-P1))
    iup1 = min(iu+1, nu);

    x3 = rx(iup1);
    y3 = ry(iup1);

    x3x1 = x3-x1;
    y3y1 = y3-y1;

    x2xx = x2-x;
    y2yy = y2-y;

    %ta= (x2x0*xxx1+y2y0*yyy1)/(x2x0*x2x1+y2y0*y2y1)
    ta = hdb                  /(x2x0*x2x1+y2y0*y2y1);
    tb = (x3x1*x2xx+y3y1*y2yy)/(x3x1*x2x1+y3y1*y2y1);

    puv(ip, 1) = ubeg + (iu-2 + ta/(ta+tb))*uinc;
    puv(ip, 2) = v;

end

%% update history

% save point in history, use result of pxy(1, :) search
if ohisto > 0
    % save current point
    ihisto(ohisto  ) = iuhist;
    xhisto(ohisto  ) = pxy(1            , 1);
    yhisto(ohisto  ) = pxy(1            , 2);
else
    jhisto = min(jhisto, mhisto);
    nhisto = max(jhisto, nhisto);
    % shift history
    ihisto(2:jhisto) = ihisto(1:jhisto-1);
    xhisto(2:jhisto) = xhisto(1:jhisto-1);
    yhisto(2:jhisto) = yhisto(1:jhisto-1);
    % insert current point
    ihisto(1       ) = iuhist;
    xhisto(1       ) = pxy(1            , 1);
    yhisto(1       ) = pxy(1            , 2);
end

%% save history in DATA

data.hist.o = ohisto;
data.hist.n = nhisto;
data.hist.i = ihisto;
data.hist.x = xhisto;
data.hist.y = yhisto;

end
