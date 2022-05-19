function [data] = crg_check_data(data)
% CRG_CHECK_DATA CRG check, fix, and complement data.
%   [DATA] = CRG_CHECK_DATA(DATA) checks CRG data for consistency
%   and accuracy, fixes slight accuracy problems giving some info, and
%   complements the CRG data as far as possible.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    is a checked, purified, and eventually completed version of
%           the function input argument DATA
%
%   Examples:
%   data = crg_check_data(data) checks and complements CRG data.
%
%   See also CRG_INTRO.

%   Copyright 2005-2015 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_check_data.m 365 2015-11-17 21:48:41Z jorauh@EMEA.CORPDIR.NET $

%% remove ok flag, initialize error/warning counter

if isfield(data, 'ok')
    data = rmfield(data, 'ok');
end
ierr = 0;

%% some local variables

crgeps = data.opts.ceps;
mininc = data.opts.cinc*(1-crgeps);
midinc = data.opts.cinc;
crgtol = data.opts.ctol;

%% check minimal CRG contents

if ~isfield(data, 'z')
    error('CRG:checkError', 'DATA.z missing')
end

if ~isfield(data, 'u')
    error('CRG:checkError', 'DATA.u missing')
end

if ~isfield(data, 'v')
    error('CRG:checkError', 'DATA.v missing')
end

%% evaluate DATA.z size

[nu nv] = size(data.z);

if nu < 2 || nv < 2
    error('CRG:checkError', 'size of DATA.z too small')
end

%% evaluate/condense DATA.u and evaluate/complete DATA.head
%   DATA.head.ubeg
%   DATA.head.uend
%   DATA.head.uinc

switch length(data.u)
    case 1 % length of reference line
        ubeg = 0;
        uend = double(data.u(1));
    case 2 % start/end value of u
        ubeg = double(data.u(1));
        uend = double(data.u(2));
    otherwise
        error('CRG:checkError', 'illegal size of DATA.u')
end

if isfield(data.head, 'ubeg')
    if abs(data.head.ubeg-ubeg) > max(crgeps*(abs(data.head.ubeg) + abs(ubeg)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.ubeg=%d and DATA.u->ubeg=%d', data.head.ubeg, ubeg)
        ierr = 1;
    end
    ubeg = data.head.ubeg;
end
if abs(round(ubeg/midinc)*midinc - ubeg) > max(crgeps*abs(ubeg), crgtol)
    warning('CRG:checkWarning', 'DATA.u->ubeg=%d not a multiple of minimal CRG increment %d', ubeg, midinc)
    ierr = 1;
end
ubeg = round(ubeg/midinc)*midinc; % force alignment to double precision

if isfield(data.head, 'uend')
    if abs(data.head.uend-uend) > max(crgeps*(abs(data.head.uend) + abs(uend)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.uend=%d and DATA.u->uend=%d', data.head.uend, uend)
        ierr = 1;
    end
    uend = data.head.uend;
end
if abs(round(uend/midinc)*midinc - uend) > max(crgeps*abs(uend), crgtol)
    warning('CRG:checkWarning', 'DATA.u->uend=%d not a multiple of minimal CRG increment %d', uend, midinc)
    ierr = 1;
end
uend = round(uend/midinc)*midinc; % force alignment to double precision

uinc = (uend-ubeg) / (nu-1);
if uinc < mininc
    error('CRG:checkError', 'illegal DATA.u->uinc=%d', uinc)
end
if isfield(data.head, 'uinc')
    if abs(data.head.uinc-uinc) > max(crgeps*(abs(data.head.uinc) + abs(uinc)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.uinc=%d and DATA.u->uinc=%d', data.head.uinc, uinc)
        ierr = 1;
    end
    uinc = data.head.uinc;
end
if abs(round(uinc/midinc)*midinc - uinc) > max(crgeps*uinc, crgtol)
    warning('CRG:checkWarning', 'DATA.u->uinc=%d not a multiple of minimal CRG increment %d', uinc, midinc)
    ierr = 1;
end
uinc = round(uinc/midinc)*midinc; % force alignment to double precision

if round((uend-ubeg)/uinc)+1 ~= nu
    warning('CRG:checkWarning', 'DATA.u->ubeg/uend/uinc not consistent with number of rows of DATA.z')
    ierr = 1;
end
    
data.head.ubeg = ubeg;
data.head.uend = uend;
data.head.uinc = uinc;

if abs(data.head.ubeg) < crgeps*mininc
    data.u = data.head.uend;
else
    data.u = [data.head.ubeg data.head.uend];
end
data.u = single(data.u);

%% evaluate/condense DATA.v and evaluate/complete DATA.head
%   DATA.head.vmin
%   DATA.head.vmax
%   DATA.head.vinc (only for constant v spacing)

if ~issorted(data.v)
    error('CRG:checkError', 'vector DATA.v must be sorted')
end
switch length(data.v)
    case 1  % half width of road
        vmax = double(data.v(1));
        vmin = -vmax;
        vinc = 2*vmax/(nv-1);
    case 2 % right/left edge of road
        vmin = double(data.v(1));
        vmax = double(data.v(2));
        vinc = (vmax-vmin)/(nv-1);
    case nv % length cut positions
        vmin = double(data.v(1));
        vmax = double(data.v(end));
        vinc_min = min(diff(double(data.v)));
        vinc_max = max(diff(double(data.v)));
        if (vinc_max-vinc_min) < crgeps*(vmax-vmin)
            vinc = (vmax-vmin)/(nv-1);  % constant v spacing assumed
        else
            vinc = -vinc_min;   % variable spacing remembered by negative value
        end
    otherwise
        error('CRG:checkError', 'illegal size of DATA.v')
end

if isfield(data.head, 'vmin')
    if abs(data.head.vmin-vmin) > max(crgeps*(abs(data.head.vmin) + abs(vmin)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.vmin=%d and DATA.v->vmin=%d', data.head.vmin, vmin)
        ierr = 1;
    end
    vmin = data.head.vmin;
end
if abs(round(vmin/midinc)*midinc - vmin) > max(crgeps*abs(vmin), crgtol)
    warning('CRG:checkWarning', 'DATA.v->vmin=%d not a multiple of minimal CRG increment %d', vmin, midinc)
    ierr = 1;
end
vmin = round(vmin/midinc)*midinc; % force alignment to double precision

if isfield(data.head, 'vmax')
    if abs(data.head.vmax-vmax) > max(crgeps*(abs(data.head.vmax) + abs(vmax)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.vmax=%d and DATA.v->vmax=%d', data.head.vmax, vmax)
        ierr = 1;
    end
    vmax = data.head.vmax;
end
if abs(round(vmax/midinc)*midinc - vmax) > max(crgeps*abs(vmax), crgtol)
    warning('CRG:checkWarning', 'DATA.v->vmax=%d not a multiple of minimal CRG increment %d', vmax, midinc)
    ierr = 1;
end
vmax = round(vmax/midinc)*midinc; % force alignment to double precision

if isfield(data.head, 'vinc')
    if vinc < 0
        warning('CRG:checkWarning', 'DATA.head.vinc=%d must not be defined for variable v spacing', data.head.vinc)
        ierr = 1;
    elseif abs(data.head.vinc-vinc) > max(crgeps*(abs(data.head.vinc) + abs(vinc)), crgtol)
        warning('CRG:checkWarning', 'inconsistent value of DATA.head.vinc=%d and DATA.v->vinc=%d', data.head.vinc, vinc)
        ierr = 1;
    end
    vinc = data.head.vinc;
end

if vinc > 0
    if vinc < mininc
        error('CRG:checkError', 'illegal DATA.v->vinc=%d', vinc)
    end
    if abs(round(vinc/midinc)*midinc - vinc) > crgeps*max(midinc, vinc)
        warning('CRG:checkWarning', 'DATA.v->vinc=%d not a multiple of CRG increment %d', vinc, midinc)
        ierr = 1;
    end
    vinc = round(vinc/midinc)*midinc; % force alignment to double precision

    if  abs(vmin+vmax)<=crgeps*vinc
        vmax = vinc*(nv-1)/2; % symmetric road assumed
        vmin = -vmax;
        data.v = single(vmax); % symmetric road assumed
    else
        data.v = single([vmin vmax]);
    end
    
    if round((vmax-vmin)/vinc)+1 ~= nv
        warning('CRG:checkWarning', 'DATA.v->vmin/vmax/vinc not consistent with number of columns of DATA.z')
        ierr = 1;
    end
else
    for i = 1:nv
        d = double(data.v(i));
        if abs(round(d/midinc)*midinc - d) > max(crgeps*abs(d), crgtol)
            warning('CRG:checkWarning', 'DATA.v(%d)=%d not a multiple of minimal CRG increment %d', i, d, midinc)
            ierr = 1;
        end
        d = round(d/midinc)*midinc; % force alignment to double precision
        data.v(i) = single(d);
    end
end

data.head.vmin = vmin;
data.head.vmax = vmax;
if vinc > 0
    data.head.vinc = vinc;
end

%% evaluate/condense/remove DATA.p and evaluate/complete DATA.head
%   DATA.head.pbeg
%   DATA.head.pend
%   DATA.head.poff

if isfield(data, 'p')
    switch length(data.p)
        case 1
            pbeg = double(data.p(1));
            pend = pbeg;
        case nu-1
            pbeg = double(data.p(1));
            pend = double(data.p(end));
        otherwise
            error('CRG:checkError', 'illegal size of DATA.p')
    end

    pmin = min(double(data.p));
    pmax = max(double(data.p));
    if abs(pmin) > pi*(1+crgeps)
        warning('CRG:checkWarning', 'min(DATA.p)=%d outside range', pmin)
        ierr = 1;
    end
    if abs(pmax) > pi*(1+crgeps)
        warning('CRG:checkWarning', 'max(DATA.p)=%d outside range', pmax)
        ierr = 1;
    end

    pmin = min(unwrap(double(data.p)));
    pmax = max(unwrap(double(data.p)));
    if (pmax-pmin) <= crgeps*pi
        pbeg = atan2(sin(pmin)+sin(pmax), cos(pmin)+cos(pmax)); % constant heading (straight refline) assumed
        pend = pbeg;
    end

    if isfield(data.head, 'pbeg')
        if (cos(data.head.pbeg)-cos(pbeg))^2 + (sin(data.head.pbeg)-sin(pbeg))^2 > (pi*crgeps)^2
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.pbeg=%d and DATA.p->pbeg=%d', data.head.pbeg, pbeg)
            ierr = 1;
       end
    else
        data.head.pbeg = pbeg;
    end

    if isfield(data.head, 'pend')
        if (cos(data.head.pend)-cos(pend))^2 + (sin(data.head.pend)-sin(pend))^2 > (pi*crgeps)^2
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.pend=%d and DATA.p->pend=%d', data.head.pend, pend)
            ierr = 1;
         end
    else
        data.head.pend = pend;
    end
else
    if ~isfield(data.head, 'pbeg')
        data.head.pbeg = 0;
    end
    if isfield(data.head, 'pend')
        if (cos(data.head.pend)-cos(data.head.pbeg))^2 + (sin(data.head.pend)-sin(data.head.pbeg))^2 > (pi*crgeps)^2
            error('CRG:checkError', 'missing DATA.p while DATA.head.pend=%d differs from DATA.head.pbeg=%d', data.head.pend, data.head.pbeg)
        end
    else
        data.head.pend = data.head.pbeg;
    end
    data.p = atan2(sin(data.head.pbeg)+sin(data.head.pend), cos(data.head.pbeg)+cos(data.head.pend));
    data.p = single(data.p);
end

pmin = min([unwrap(double(data.p)) data.head.pbeg data.head.pend]);
pmax = max([unwrap(double(data.p)) data.head.pbeg data.head.pend]);
if (pmax-pmin) <= crgeps*pi
    data.p = atan2(sin(pmin)+sin(pmax), cos(pmin)+cos(pmax));  % constant heading (straight refline) assumed
    if abs(data.p) <= crgeps*pi
        data = rmfield(data, 'p'); % zero heading assumed
        data.head.pbeg = 0;
    else
        data.head.pbeg = data.p;
        data.p = single(data.p);
    end
    data.head.pend = data.head.pbeg;
end

if ~isfield(data.head, 'poff')
    data.head.poff = 0;
end

%% evaluate/condense/remove DATA.s and evaluate/complete DATA.head
%   DATA.head.sbeg
%   DATA.head.send

if isfield(data, 's')
    switch length(data.s)
        case 1
            sbeg = double(data.s(1));
            send = sbeg;
        case nu-1
            sbeg = double(data.s(1));
            send = double(data.s(end));
        otherwise
            error('CRG:checkError', 'illegal size of DATA.s')
    end

    smin = min(double(data.s));
    smax = max(double(data.s));
    if abs(smin) > 1
        warning('CRG:checkWarning', 'min(DATA.s)=%d outside range', smin)
        ierr = 1;
    end
    if abs(smax) > 1
        warning('CRG:checkWarning', 'max(DATA.s)=%d outside range', smax)
        ierr = 1;
    end
    if (smax-smin) <= crgeps
        sbeg = (smax+smin)/2; % constant slope assumed
        send = sbeg;
    end

    if isfield(data.head, 'sbeg')
        if abs(data.head.sbeg-sbeg) > crgeps
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.sbeg=%d and DATA.s->sbeg=%d', data.head.sbeg, sbeg)
            ierr = 1;
       end
    else
        data.head.sbeg = sbeg;
    end

    if isfield(data.head, 'send')
        if abs(data.head.send-send) > crgeps
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.send=%d and DATA.s->send=%d', data.head.send, send)
            ierr = 1;
        end
    else
        data.head.send = send;
    end
else
    if ~isfield(data.head, 'sbeg')
        data.head.sbeg = 0;
    end
    if isfield(data.head, 'send')
        if abs(data.head.send - data.head.sbeg) > crgeps
            error('CRG:checkError', 'missing DATA.s while DATA.head.send=%d differs from DATA.head.sbeg=%d', data.head.send, data.head.sbeg)
        end
    else
        data.head.send = data.head.sbeg;
    end
    data.s = (data.head.sbeg+data.head.send)/2;
    data.s = single(data.s);
end

smin = min([double(data.s) data.head.sbeg data.head.send]);
smax = max([double(data.s) data.head.sbeg data.head.send]);
if smax-smin <= crgeps
    data.s = (smax+smin)/2; % constant slope assumed
    if abs(data.s) <= crgeps
        data = rmfield(data, 's'); % zero slope assumed
        data.head.sbeg = 0;
    else
        data.head.sbeg = data.s;
        data.s = single(data.s);
    end
    data.head.send = data.head.sbeg;
end

%% evaluate/condense/remove DATA.b and evaluate/complete DATA.head
%   DATA.head.bbeg
%   DATA.head.bend

if isfield(data, 'b')
    switch length(data.b)
        case 1
            bbeg = double(data.b(1));
            bend = bbeg;
        case nu
            bbeg = double(data.b(1));
            bend = double(data.b(end));
        otherwise
            error('CRG:checkError', 'illegal size of DATA.b')
    end

    bmin = min(double(data.b));
    bmax = max(double(data.b));
    if abs(bmin) > 1
        warning('CRG:checkWarning', 'min(DATA.b)=%d outside range', bmin)
        ierr = 1;
    end
    if abs(bmax) > 1
        warning('CRG:checkWarning', 'max(DATA.b)=%d outside range', bmax)
        ierr = 1;
    end
    if (bmax-bmin) <= crgeps
        bbeg = (bmax+bmin)/2; % constant cross slope assumed
        bend = bbeg;
    end

    if isfield(data.head, 'bbeg')
        if abs(data.head.bbeg-bbeg) > crgeps
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.bbeg=%d and DATA.b->bbeg=%d', data.head.bbeg, bbeg)
            ierr = 1;
        end
    else
        data.head.bbeg = bbeg;
    end

    if isfield(data.head, 'bend')
        if abs(data.head.bend-bend) > crgeps
            warning('CRG:checkWarning', 'inconsistent value of DATA.head.bend=%d and DATA.b->bend=%d', data.head.bend, bend)
            ierr = 1;
       end
    else
        data.head.bend = bend;
    end
else
    if ~isfield(data.head, 'bbeg')
        data.head.bbeg = 0;
    end
    if isfield(data.head, 'bend')
        if abs(data.head.bend - data.head.bbeg) > crgeps
            error('CRG:checkError', 'missing DATA.b while DATA.head.bend=%d differs from DATA.head.bbeg=%d', data.head.bend, data.head.bbeg)
        end
    else
        data.head.bend = data.head.bbeg;
    end
    data.b = (data.head.bbeg+data.head.bend)/2;
    data.b = single(data.b);
end

bmin = min([double(data.b) data.head.bbeg data.head.bend]);
bmax = max([double(data.b) data.head.bbeg data.head.bend]);
if bmax-bmin <= crgeps
    data.b = (bmax+bmin)/2; % constant cross slope assumed
    if abs(data.b) <= crgeps
        data = rmfield(data, 'b'); % zero cross slope assumed
        data.head.bbeg = 0;
    else
        data.head.bbeg = data.b;
        data.b = single(data.b);
    end
    data.head.bend = data.head.bbeg;
end

%% check head data consistency again

data = crg_check_head(data);

%%  keep only what we know and want

dinp = data;
data = struct;

% head data
if isfield(dinp, 'head'  ), data.head   = dinp.head; end

% mpro data
if isfield(dinp, 'mpro'  ), data.mpro   = dinp.mpro; end

% mods data
if isfield(dinp, 'mods'  ), data.mods   = dinp.mods; end

% opts data
if isfield(dinp, 'opts'  ), data.opts   = dinp.opts; end

% file data
if isfield(dinp, 'ct'    ), data.ct     = dinp.ct    ; end
if isfield(dinp, 'struct'), data.struct = dinp.struct; end
if isfield(dinp, 'filenm'), data.filenm = dinp.filenm; end

% core elevation grid data
if isfield(dinp, 'z'     ), data.z      = dinp.z     ; end
if isfield(dinp, 'v'     ), data.v      = dinp.v     ; end
if isfield(dinp, 'b'     ), data.b      = dinp.b     ; end

% core reference line data
if isfield(dinp, 'u'     ), data.u      = dinp.u     ; end
if isfield(dinp, 'p'     ), data.p      = dinp.p     ; end
if isfield(dinp, 's'     ), data.s      = dinp.s     ; end

% figure opts data
if isfield(dinp, 'fopt'  ), data.fopt   = dinp.fopt  ; end

%% build reference line x and y, complete DATA.head and DATA.dved
%   DATA.head.xbeg, DATA.head.ybeg, DATA.head.xend, DATA.head.yend
%   DATA.head.xoff, DATA.head.yoff
%   DATA.dved.pbec, DATA.dved.pbes, DATA.dved.penc, DATA.dved.pens
%   DATA.rx, DATA.ry, DATA.rc (only for variable heading (curved refline))

if isfield(data, 'p') && length(data.p)==nu-1 % variable heading (curved refline)
    % location
    data.rx = zeros(1, nu);
    data.ry = zeros(1, nu);
    if isfield(data.head, 'xend') % backward / forward integration
        data.rx(nu) = data.head.xend;
        data.ry(nu) = data.head.yend;
        for i = nu-1:-1:1 % backward
            data.rx(i) = data.rx(i+1) - data.head.uinc*cos(double(data.p(i)));
            data.ry(i) = data.ry(i+1) - data.head.uinc*sin(double(data.p(i)));
        end
        err = sqrt((data.rx(1)-data.head.xbeg)^2 + (data.ry(1)-data.head.ybeg)^2);
        if err > max((data.head.uend-data.head.ubeg)*crgeps, crgtol)
            warning('CRG:checkWarning', 'inconsistent position after heading angle backward integration, err=%d', err)
            ierr = 1;
        end
        data.rx(1) = data.head.xbeg;
        data.ry(1) = data.head.ybeg;
        for i = 1:1:(nu-2) % forward with weighted interpolation
            data.rx(i+1) = ((nu-i-1)*(data.rx(i) + data.head.uinc*cos(double(data.p(i)))) + i*data.rx(i+1))/(nu-1);
            data.ry(i+1) = ((nu-i-1)*(data.ry(i) + data.head.uinc*sin(double(data.p(i)))) + i*data.ry(i+1))/(nu-1);
        end
        if max((diff(data.rx)-cos(data.p)*data.head.uinc).^2 + (diff(data.ry)-sin(data.p)*data.head.uinc).^2) > crgtol^2
            warning('CRG:checkWarning', 'inconsistent values in DATA.head.xend/xbeg/yend/ybeg/uinc and DATA.p')
            ierr = 1;
        end
    else % simple forward integration
        if isfield(data.head, 'xbeg')
            data.rx(1) = data.head.xbeg;
            data.ry(1) = data.head.ybeg;
        end
        for i = 1:1:(nu-1) % forward
            data.rx(i+1) = data.rx(i) + data.head.uinc*cos(double(data.p(i)));
            data.ry(i+1) = data.ry(i) + data.head.uinc*sin(double(data.p(i)));
        end
        data.head.xbeg = data.rx(1);
        data.head.ybeg = data.ry(1);
        data.head.xend = data.rx(nu);
        data.head.yend = data.ry(nu);
    end

    % curvature
    dx = diff(data.rx);
    dy = diff(data.ry);
    data.rc = (dx(1:end-1).*dy(2:end)-dy(1:end-1).*dx(2:end)) / data.head.uinc^3;
    clear dx dy

    cmin = min(data.rc);
    cmax = max(data.rc);
    if abs(cmax) > crgeps
        if 1/cmax <= data.head.vmax && 1/cmax >= data.head.vmin
            warning('CRG:checkWarning', 'center of max. reference line curvature=%d inside road limits', cmax)
            ierr = 1;
        end
    end
    if abs(cmin) > crgeps
        if 1/cmin <= data.head.vmax && 1/cmin >= data.head.vmin
            warning('CRG:checkWarning', 'center of min. reference line curvature=%d inside road limits', cmin)
            ierr = 1;
        end
    end
else % constant heading (straight refline)
    if ~isfield(data.head, 'xbeg')
        data.head.xbeg = 0;
        data.head.ybeg = 0;
    end

    % forward integration with DATA.head.pbeg
    xend = data.head.xbeg + (data.head.uend-data.head.ubeg)*cos(data.head.pbeg);
    yend = data.head.ybeg + (data.head.uend-data.head.ubeg)*sin(data.head.pbeg);
    if isfield(data.head, 'xend')
        err = sqrt((xend-data.head.xend)^2 + (yend-data.head.yend)^2);
        if err > max((data.head.uend-data.head.ubeg)*crgeps, crgtol)
            warning('CRG:checkWarning', 'inconsistent position after heading angle forward integration, err=%d', err)
            ierr = 1;
        end
    else
        data.head.xend = xend;
        data.head.yend = yend;
    end
end

if ~isfield(data.head, 'xoff')
    data.head.xoff = 0;
end
if ~isfield(data.head, 'yoff')
    data.head.yoff = 0;
end

data.dved.pbec = cos(data.head.pbeg);
data.dved.pbes = sin(data.head.pbeg);
data.dved.penc = cos(data.head.pend);
data.dved.pens = sin(data.head.pend);

%% complete DATA.dved
%   DATA.dved.ubex, DATA.dved.uenx, DATA.dved.ulex

data = crg_check_data_rflc(data); % check if refline can be closed

if data.opts.rflc==1 && data.dved.ulex==0
    warning('CRG:checkWarning', 'refline cannot be closed, no valid intersection point found')
    ierr = 1;
end

%% build reference line z, complete DATA.head
%   DATA.head.zbeg, DATA.head.zend, DATA.head.zoff
%   DATA.rz (only for variable slope)

if isfield(data, 's') && length(data.s)==nu-1 % variable slope
    data.rz = zeros(1, nu);
    if isfield(data.head, 'zend') % backward / forward integration
        data.rz(nu) = data.head.zend;
        for i = nu-1:-1:1 % backward
            data.rz(i) = data.rz(i+1) - data.head.uinc*double(data.s(i));
        end
        err = abs(data.rz(1)-data.head.zbeg);
        if err > max((data.head.uend-data.head.ubeg)*crgeps, crgtol)
            warning('CRG:checkWarning', 'inconsistent refline altitude after slope backward integration, err=%d', err)
            ierr = 1;
        end
        data.rz(1) = data.head.zbeg;
        for i = 1:1:(nu-2) % forward with weighted interpolation
            data.rz(i+1) = ((nu-i-1)*(data.rz(i) + data.head.uinc*double(data.s(i))) + i*data.rz(i+1))/(nu-1);
        end
        if max(abs(diff(data.rz)/data.head.uinc - double(data.s))) > crgeps
            warning('CRG:checkWarning', 'inconsistent values in DATA.head.zend/zbeg/uinc and DATA.s')
            ierr = 1;
        end
    else % simple forward integration
        if isfield(data.head, 'zbeg')
            data.rz(1) = data.head.zbeg;
        end
        if length(data.s) == 1
            for i = 1:1:(nu-1) % forward
                data.rz(i+1) = data.rz(i) + data.head.uinc*double(data.s);
            end
        else
            for i = 1:1:(nu-1) % forward
                data.rz(i+1) = data.rz(i) + data.head.uinc*double(data.s(i));
            end
        end
        data.head.zbeg = data.rz(1);
        data.head.zend = data.rz(nu);
    end
else % constant slope
    if ~isfield(data.head, 'zbeg')
        data.head.zbeg = 0;
    end

    % forward integration with DATA.head.sbeg
    zend = data.head.zbeg + (data.head.uend-data.head.ubeg)*data.head.sbeg;
    if isfield(data.head, 'zend')
        err = zend - data.head.zend;
        if abs(err) > max((data.head.uend-data.head.ubeg)*crgeps, crgtol)
            warning('CRG:checkWarning', 'inconsistent refline altitude after slope forward integration, err=%d', err)
            ierr = 1;
        end
    else
        data.head.zend = zend;
    end
end

if ~isfield(data.head, 'zoff')
    data.head.zoff = 0;
end

%% complete WGS84 head data

if isfield(data.head, 'abeg')
    if ~isfield(data.head, 'aend')
        data.head.aend = data.head.abeg + (data.head.zend - data.head.zbeg);
    end
end

%% check NaNs in DATA.z

data.ir = zeros(1, nu);
data.il = zeros(1, nu);
for i = 1:nu
    valid = ~isnan(data.z(i, :));
    if sum(valid) == 0
        error('CRG:checkError', 'full NaN cross section in DATA.z(%d,:)', i)
    end
    r = find(valid, 1, 'first');
    l = find(valid, 1, 'last');
    if sum(valid(r:l)) ~= l-r+1
        error('CRG:checkError', 'NaN inside valid data of cross section in DATA.z(%d,:)', i)
    end
    data.il(i) = l;
    data.ir(i) = r;
end

%% prepare history

data.hist.m = 50; % should be sufficient for road trains...
data.hist.o = -1; % start search from beginning
data.hist.n = 0;
data.hist.c = ( 10*uinc)^2;
data.hist.f = (100*uinc)^2;
data.hist.i = zeros(1, data.hist.m);
data.hist.x = zeros(1, data.hist.m);
data.hist.y = zeros(1, data.hist.m);

%% set ok-flag

if ierr == 0
    data.ok = 0;
end

end

%% subfunction crg_check_data_rflc

function [data] = crg_check_data_rflc(data)
%CRG_CHECK_DATA_DATA_RFLC check if refline can be closed.
%   [DATA] = CRG_CHECK_DATA_RFLC(DATA) checks CRG data if refline
%   extrapolations at begin and end can be connected to build a closed
%   track.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    is a checked, purified, and eventually completed version of
%           the function input argument DATA
%
%   Examples:
%   data = crg_check_data_rflc(data) checks if refline can be closed.
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
%   $Id: crg_check_data.m 365 2015-11-17 21:48:41Z jorauh@EMEA.CORPDIR.NET $

% simplify data access

xbeg = data.head.xbeg;
ybeg = data.head.ybeg;
xend = data.head.xend;
yend = data.head.yend;

pbec = data.dved.pbec;
pbes = data.dved.pbes;
penc = data.dved.penc;
pens = data.dved.pens;

% set default for non-closable track

data.dved.ubex = data.head.ubeg;
data.dved.uenx = data.head.uend;
data.dved.ulex = 0;

% return if refline is straight

if ~isfield(data, 'rx')
    return
end

% return if refline does not extrapolate in roughly opposite directions

dotprod = pbec*penc + pbes*pens;
if dotprod < 0.5
    return % bend angle bigger 60 deg.
end

% return if orthogonal on begin cuts extrapolation of end on wrong side

duend = (pbes*(ybeg-yend) + pbec*(xbeg-xend)) / dotprod;
if duend < 0
    return
end

% return if orthogonal on end cuts extrapolation of begin on wrong side

dubeg = (pens*(yend-ybeg) + penc*(xend-xbeg)) / dotprod;
if dubeg > 0
    return
end

% closed refline without cut, potentially discontinuous in position and heading

data.dved.ubex = data.head.ubeg + dubeg*dotprod/2;
data.dved.uenx = data.head.uend + duend*dotprod/2;
data.dved.ulex = data.dved.uenx - data.dved.ubex;

% return if refline does extrapolate roughly parallel

crossprod = pbec*pens - pbes*penc;
if abs(crossprod) < eps
    return
end

% return if extrapolation of begin cuts at extrapolation of end on wrong side

duend = (pbec*(ybeg-yend) - pbes*(xbeg-xend)) / crossprod;
if duend < 0
    return
end

% return if extrapolation of end cuts at extrapolation of begin on wrong side

dubeg = (penc*(ybeg-yend) - pens*(xbeg-xend)) / crossprod;
if dubeg > 0
    return
end

% closed refline with cut, potentially discontinuous in heading

data.dved.ubex = data.head.ubeg + dubeg;
data.dved.uenx = data.head.uend + duend;
data.dved.ulex = data.dved.uenx - data.dved.ubex;

end
