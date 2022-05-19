function [data] = crg_cut_iuiv(data, iu, iv)
% CRG_CUT_IUIV cuts out a part of a CRG road.
%   DATA = CRG_CUT_IUIV(DOUT, IU, IV) cuts out a part of a CRG road.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   IU      U index for cut selection (default: full CRG)
%           IU(1): longitudinal start index
%           IU(2): longitudinal end index
%   IV      V index for cut selection (default: full CRG)
%           IV(1): lateral start index
%           IV(2): lateral end index
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_cut_iuiv(data, [1000 2000], [10 30])
%       cuts selected elevation grid data part.
%   See also CRG_INTRO.

%   Copyright 2005-2018 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_cut_iuiv.m 366 2018-03-04 18:16:50Z jorauh@EMEA.CORPDIR.NET $

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

if nargin < 2 || isempty(iu)
    iu =  [1 nu];
end
if iu(1)<1 || iu(1) >= iu(2) || iu(2) > nu
    error('CRG:cutError', 'illegal IU index values iu=[%d %d] with nu=%d', iu(1), iu(2), nu);
end

if nargin < 3 || isempty(iv)
    iv =  [1 nv];
end
if iv(1)<1 || iv(1) >= iv(2) || iv(2) > nv
    error('CRG:cutError', 'illegal IV index values iv=[%d %d] with nv=%d', iv(1), iv(2), nv);
end

%% new dout structure

dout = struct;

%% build uv

dout.head.ubeg = data.head.ubeg + data.head.uinc*(iu(1)-1);
dout.head.uend = data.head.ubeg + data.head.uinc*(iu(2)-1);
dout.head.uinc = data.head.uinc;
dout.u = [dout.head.ubeg dout.head.uend];

if isfield(data.head, 'vinc')
    dout.head.vmin = data.head.vmin + data.head.vinc*(iv(1)-1);
    dout.head.vmax = data.head.vmin + data.head.vinc*(iv(2)-1);
    dout.head.vinc = data.head.vinc;
    dout.v = [dout.head.vmin dout.head.vmax];
else
    dout.head.vmin = double(data.v(iv(1)));
    dout.head.vmax = double(data.v(iv(2)));
    dout.v = data.v(iv(1):iv(2));
end

%% build refline xy

if isfield(data, 'rx')
    dout.head.xbeg = data.rx(iu(1));
    dout.head.xend = data.rx(iu(2));
    dout.head.ybeg = data.ry(iu(1));
    dout.head.yend = data.ry(iu(2));
    dout.head.pbeg = double(data.p(iu(1)));
    dout.head.pend = double(data.p(iu(2)-1));
    dout.p = data.p(iu(1):iu(2)-1);
else
    dout.head.xbeg = data.head.xbeg + data.dved.pbec*data.head.uinc*(iu(1)-1);
    dout.head.xend = data.head.xbeg + data.dved.pbec*data.head.uinc*(iu(2)-1);
    dout.head.ybeg = data.head.ybeg + data.dved.pbes*data.head.uinc*(iu(1)-1);
    dout.head.yend = data.head.ybeg + data.dved.pbes*data.head.uinc*(iu(2)-1);
    dout.head.pbeg = data.head.pbeg;
    dout.head.pend = data.head.pend;
    dout.p = data.head.pbeg;
end

if isfield(data.head, 'xoff')
    dout.head.xoff = data.head.xoff;
end

if isfield(data.head, 'yoff')
    dout.head.yoff = data.head.yoff;
end

%% build refline elevation

if isfield(data, 'rz')
    dout.head.zbeg = data.rz(iu(1));
    dout.head.zend = data.rz(iu(2));
else
    dout.head.zbeg = data.head.zbeg;
    dout.head.zend = data.head.zend;
end

if isfield(data.head, 'zoff')
    dout.head.zoff = data.head.zoff;
end

%% build longitude/latitude/altitude

if isfield(data, 'mpro')
    dout.mpro = data.mpro;
else
    if isfield(data.head, 'eend')
        wgs = crg_wgs84_xy2wgs(data, [dout.head.xbeg dout.head.ybeg]);
        dout.head.nbeg = wgs(1,1);
        dout.head.ebeg = wgs(1,2);
        wgs = crg_wgs84_xy2wgs(data, [dout.head.xend dout.head.yend]);
        dout.head.nend = wgs(1,1);
        dout.head.eend = wgs(1,2);
    elseif isfield(data.head, 'ebeg') && (iu(1) == 1)
        dout.head.nbeg = data.head.nbeg;
        dout.head.ebeg = data.head.ebeg;
    end
    if isfield(data.head, 'abeg')
        dout.head.abeg = data.head.abeg + (dout.head.zbeg - data.head.zbeg);
        dout.head.aend = data.head.aend + (dout.head.zend - data.head.zend);
    end
end

%% build refline slope

if isfield(data, 's') && length(data.s)>1
    dout.s = data.s(iu(1):iu(2)-1);
    if iu(1)==1
        dout.head.sbeg = data.head.sbeg;
    else
        dout.head.sbeg = dout.s(1);
    end
    if iu(2)==nu
        dout.head.send = data.head.send;
    else
        dout.head.send = dout.s(end);
    end
else
    dout.head.sbeg = data.head.sbeg;
    dout.head.send = data.head.send;
end

%% build banking

if isfield(data, 'b') && length(data.b)>1
    dout.b = data.b(iu(1):iu(2));
    if iu(1)==1
        dout.head.bbeg = data.head.bbeg;
    else
        dout.head.bbeg = dout.b(1);
    end
    if iu(2)==nu
        dout.head.bend = data.head.bend;
    else
        dout.head.bend = dout.b(end);
    end
else
    dout.head.bbeg = data.head.bbeg;
    dout.head.bend = data.head.bend;
end

%% build elevation grid

dout.z = data.z(iu(1):iu(2), iv(1):iv(2));

%% copy struct field

if isfield(data, 'struct')
    dout.struct = data.struct;
end

%% suppelment comment text

if isfield(data, 'ct')
    dout.ct = data.ct;
else
    dout.ct = cell(1,0);
end
dout.ct{end+1} = sprintf('* modified by %s at %s', mfilename, datestr(now, 31));

%% check

dout = crg_single(dout);

data = crg_check(dout);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end
