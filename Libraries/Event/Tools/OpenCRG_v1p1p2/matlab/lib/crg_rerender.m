function [ data ] = crg_rerender( crg, inc, v )
%CRG_RERENDER renders the crg-file with new spacing in u and v
%   [DATA] = CRG_RERENDER( CRG, INC, V ) renders CRG with
%   u/v-increment and v-spacing.
%
%   Inputs:
%   CRG     struct array as defined in CRG_INTRO
%   INC     new u/v-spacing increment (single)
%           length(inc) == 1: uinc
%           length(inc) == 2: vinc
%   V       vector of v values (single)
%           length(v) == 1: defines half width of road
%           length(v) == 2: defines right/left edge of road
%           length(v) == nv: defines length cut positions
%
%   Output:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_rerender(crg, inc, v) rerenders crg with u/v-spacing
%
%   See also CRG_INTRO

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - Holger Helmich
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
%   $Id: crg_rerender 2009-10-27 15:11:00Z hhelmich $

%% default

if nargin < 3 || isempty(v), v = crg.v;             end
if nargin < 2 || isempty(inc), inc = crg.head.uinc; end

dvinc = 0.01; % default v-inc

%% check if already succesfully checked

if ~isfield(crg, 'ok')
    crg = crg_check(crg);
    if ~isfield(crg, 'ok')
        error('CRG:checkError', 'check of CRG was not completely successful')
    end
end

%% build uv

ubeg = crg.head.ubeg;
uend = crg.head.uend;
uinc = inc(1);
u = ubeg:uinc:uend;
du = ubeg:crg.head.uinc:uend;

vmin = crg.head.vmin;
vmax = crg.head.vmax;

if length(inc) == 2
    vinc = inc(2);
    vi = vmin:vinc:vmax;
%     v = [vi(1) vi(end)];
else
    if isfield(crg.head, 'vinc'), vinc = crg.head.vinc;
    else vinc = dvinc; end
    switch length(v)
        case 1
            vi = -v:vinc:v;
        case 2
            vi = v(1):vinc:v(2);
        otherwise
            vi = v;
    end
end

%% interpolate reference line ( set u-grid )

data = struct;              % build basic crg_structure
data.head = struct;

data.head.ubeg = u(1);
data.head.uend = u(end);
data.head.uinc = uinc;
data.head.pbeg = crg.head.pbeg;
data.head.pend = crg.head.pend;
data.head.xbeg = crg.head.xbeg;
data.head.ybeg = crg.head.ybeg;

data.opts.bdmv = crg.opts.bdmv;
data.opts.bdmu = crg.opts.bdmu;

data.u = [u(1) u(end)];

if isfield(crg, 'p')
    if length(crg.p) == 1   % constant curvature
        data.p = crg.p;
    else                    % variable curvature
        ppx = spline(du,crg.rx);
        ppy = spline(du,crg.ry);

        ppxy = ppx;
        ppxy.coefs = complex(ppx.coefs, ppy.coefs);
        clear ppx ppy

        data = crg_gen_ppxy2phi(ppxy, uinc);

        u = data.head.ubeg:uinc:data.head.uend;

    end
end

%% seperate slope banking

if isfield(crg,'s')     % slope
    ts = crg.s;

    crg = rmfield(crg, 's');
    crg.head = rmfield(crg.head, 'sbeg');
    crg.head = rmfield(crg.head, 'send');
    crg.head = rmfield(crg.head, 'zbeg');
    crg.head = rmfield(crg.head, 'zend');

end

if isfield(crg,'b')     % banking
    tb = crg.b;

    crg = rmfield(crg, 'b');
    crg.head = rmfield(crg.head, 'bbeg');
    crg.head = rmfield(crg.head, 'bend');
end

if exist('tb', 'var') || exist('ts', 'var')
    crg = crg_check(crg);
    if ~isfield(crg, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% add pseudo values to check basic crg-file

data.v = single(vi);

data.z = zeros(length(u),length(vi), 'single');

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

%% get z from u,v

[XI, YI] = meshgrid(u, vi);

z = crg_eval_uv2z(crg, [XI(:), YI(:)]);

z = reshape(z, size(XI,1), size(XI,2));

clear XI YI;

%% add data

data.z = single(z');

if exist('ts', 'var')     % slope
    if length(ts) == 1, ts = zeros(1,size(data.z,1)-1)+ts; end
    data.s = interp1(1:length(ts),ts,linspace(1,length(ts),size(data.z,1)-1));
    data.head.sbeg = data.s(1);
    data.head.send = data.s(end);
    data.head = rmfield(data.head, 'zbeg');
    data.head = rmfield(data.head, 'zend');
end

if exist('tb', 'var')     % banking
    if length(tb) == 1, tb = zeros(1,size(data.z,1))+tb; end
    data.b = interp1(1:length(tb),tb,linspace(1,length(tb),size(data.z,1)));
    data.head.bbeg = data.b(1);
    data.head.bend = data.b(end);
end

clear ts tb;

%% final check

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end % function crg_rerender(crg, u, v)
