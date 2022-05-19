function [data, roff2] = crg_append(data1, data2)
%CRG_APPEND CRG append a second compatible CRG to a first CRG.
%   [CRG] = CRG_APPEND(DATA1, DATA2) appends a second compatible CRG to a
%   first one by using an overlap of one uinc increment, which defines
%   re-postioning of the second CRG for a smooth joint connection.
%   The last cross cut of DATA1 and the first cross cut of DATA2 will be
%   dropped due to overlap.
%   Incomplete or inconsistent WGS84 lon/lat or alt values at the interface
%   will result in omitting the WGS84 information in the result.
%
%   Inputs:
%   DATA1   struct array as defined in CRG_INTRO.
%   DATA2   struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO.
%   ROFF2   struct with refline offset applied to DATA2
%       .rlox (refline_offset_x): translate by rlox
%       .rloy (refline_offset_y): translate by rloy
%       .rloz (refline_offset_z): translate by rloz
%       .rlop (refline_offset_phi): rotate by rlop around (xbeg, ybeg)
%
%   Examples:
%   crg = crg_append(crg1, crg2);
%   appends a second CRG to a first one.
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
%   $Id: crg_append.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data1, 'ok')
    data1 = crg_check(data1);
    if ~isfield(data1, 'ok' )
        error('CRG:checkError', 'check of DATA1 was not completely successful')
    end
end
if ~isfield(data2, 'ok')
    data2 = crg_check(data2);
    if ~isfield(data2, 'ok' )
        error('CRG:checkError', 'check of DATA2 was not completely successful')
    end
end

%% simplify data access

ubeg1 = data1.head.ubeg;
uinc1 = data1.head.uinc;
uinc2 = data2.head.uinc;

ceps1 = data1.opts.ceps;

%% CRG sizes

[nu1 nv1 ]= size(data1.z);
[nu2 nv2 ]= size(data2.z);

nu = nu1 + nu2 - 2;

%% check for compatibility

if abs(uinc1 - uinc2) > ceps1*(uinc1 + uinc2)
    error('CRG:appendError', 'DATA2.head.uinc=%d not compatible with DATA1.head.uinc=%d', uinc2, uinc1);
end

if nv1 ~= nv2
    error('CRG:appendError', 'DATA2.z witdth not compatible with DATA1.z width')
end

if length(data1.v) ~= length(data2.v) || max(abs(data1.v-data2.v)) > ceps1*max(abs(data1.v))
    error('CRG:appendError', 'DATA2.v not compatible with DATA1.v')
end

%% adapt slope of first uinc interval of second CRG to first CRG

if abs(data1.head.send - data2.head.sbeg) > ceps1
    sdel = data1.head.send - data2.head.sbeg;

    if ~isfield(data2, 's') || length(data2.s)==1
        data2.s = zeros(1, nu2-1, 'single');
        data2.s = data2.s + data2.head.sbeg;
    end

    % adapt first slope of DATA2 to slope of DATA1
    data2.head.sbeg = data2.head.sbeg + sdel;
    data2.s(1)      = data2.s(1)      + sdel;

    % correct first elevation of DATA2 accordingly
    data2.head.zbeg = data2.head.zbeg - sdel*uinc2;
    data2.z(1,:)    = data2.z(1,:)    + sdel*uinc2;

    % correct first altitude of DATA2 accordingly
    if isfield(data2.head, 'abeg')
        data2.head.abeg = data2.head.abeg - sdel*uinc2;
    end

    data2 = crg_check(data2);
end

%% reposition first uinc interval of second CRG to last uinc interval of first CRG

% next to last refline point of first CRG
xend1_1 = data1.head.xend - uinc1*data1.dved.penc;
yend1_1 = data1.head.yend - uinc1*data1.dved.pens;
zend1_1 = data1.head.zend - uinc1*data1.head.send;

% heading of last refline interval of first CRG

pend1 = data1.head.pend;

% offset modifiers to apply to second CRG to match it's first refline
% point to the second last refline point of the first CRG

roff2=struct; % reset mods

roff2.rlox = xend1_1 - data2.head.xbeg;
roff2.rloy = yend1_1 - data2.head.ybeg;
roff2.rloz = zend1_1 - data2.head.zbeg;

% offset modifier to apply to second CRG to match it's first refline
% interval heading to the last refline interval heading of the first CRG

roff2.rlop = pend1 - data2.head.pbeg;

% set and apply DATA2 modifiers

data2.mods = roff2;
data2 = crg_mods(data2);

%% create output CRG struct

data = struct;

%% build uv information

data.head.ubeg = ubeg1;
data.head.uinc = uinc1;
data.head.uend = ubeg1 + (nu-1)*uinc1;
data.u = single([data.head.ubeg data.head.uend]);

data.head.vmin = data1.head.vmin;
data.head.vmax = data1.head.vmax;
if isfield(data1.head, 'vinc')
    data.head.vinc = data1.head.vinc;
end
data.v = data1.v;

%% build p information

if isfield(data1, 'rx') || isfield(data2, 'rx') % at least one curved CRG
    data.p = zeros(1, nu-1, 'single');

    if isfield(data2, 'p'), data.p(nu1-1:end  ) = data2.p; end
    if isfield(data1, 'p'), data.p(    1:nu1-1) = data1.p; end
elseif isfield(data1, 'p') % nonzero heading
    data.p = data1.p;
end

data.head.pbeg = data1.head.pbeg;
data.head.pend = data2.head.pend;

data.head.xbeg = data1.head.xbeg;
data.head.xend = data2.head.xend;

data.head.ybeg = data1.head.ybeg;
data.head.yend = data2.head.yend;

%% build s information

if isfield(data1, 's') || isfield(data2, 's') % at least one CRG with slope
    data.s = zeros(1, nu-1, 'single');

    if isfield(data1, 's'), data.s(    1:nu1-1) = data1.s; end

    % overwrite last slope of first CRG by first slope of second CRG
    if isfield(data2, 's'), data.s(nu1-1:end  ) = data2.s; end
end

data.head.sbeg = data1.head.sbeg;
data.head.send = data2.head.send;

data.head.zbeg = data1.head.zbeg;
data.head.zend = data2.head.zend;

%% build b information

if isfield(data1, 'b') || isfield(data2, 'b') % at least one CRG with banking
    data.b = zeros(1, nu, 'single');

    if isfield(data1, 'b'), data.b(    1:nu1) = data1.b; end

    % drop last banking of first CRG and first banking of second CRG
    if isfield(data2, 'b')
        if length(data2.b) == 1
            data.b(nu1:end) = data2.b;
        else
            data.b(nu1:end) = data2.b(2:end);
        end
    end
end

data.head.bbeg = data1.head.bbeg;
data.head.bend = data2.head.bend;

%% build WGS84 information only if consistent definitions exist

if isfield(data1.head, 'eend') && isfield(data2.head, 'eend') % both have lon/lat data
    wgs1_1    = crg_wgs84_xy2wgs(data1, [xend1_1 yend1_1]);
    wgs2(1,1) = data2.head.nbeg;
    wgs2(1,2) = data2.head.ebeg;

    if crg_wgs84_dist(wgs1_1, wgs2) < ceps1*uinc1*nu
        data.head.nbeg = data1.head.nbeg;
        data.head.nend = data2.head.nend;

        data.head.ebeg = data1.head.ebeg;
        data.head.eend = data2.head.eend;
    else
        warning('CRG:appendWarning', 'WGS84 lon/lat at end of DATA1=[%.6f %.6f] not fully consistent to begin of DATA2=[%.6f %.6f]', wgs1_1(1,1), wgs1_1(1,2), wgs2(1,1), wgs2(1,2))
    end
end

if isfield(data1.head, 'aend') && isfield(data2.head, 'aend') % both have alt data
    aend1_1 = data1.head.aend - uinc1*data1.head.send;
    abeg2   = data2.head.abeg;
    if abs(aend1_1 - abeg2) <= ceps1*(aend1_1 + abeg2) % both are consistent
        data.head.abeg = data1.head.abeg;
        data.head.aend = data2.head.aend;
    else
        warning('CRG:appendWarning', 'WGS84 altitude at end of DATA1=%d not fully consistent to begin of DATA2=%d', aend1_1, abeg2)
    end
elseif isfield(data1.head, 'aend') || isfield(data2.head, 'aend') % only one has alt data
        warning('CRG:appendWarning', 'WGS84 altitude only available for one of DATA1 and DATA2')
end


%% build elevation grid

% drop last cross cut of first CRG and first cross cut of second CRG
data.z = [data1.z(1:end-1,:); data2.z(2:end,:)];

%% force check

data = crg_check(data);

end
