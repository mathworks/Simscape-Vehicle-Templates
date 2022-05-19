function [data] = crg_mods(data)
%CRG_MODS apply modifiers on data.
%   [DATA] = CRG_MODS(DATA) applies modifiers defined in DATA.mods to CRG
%   data and removes them from DATA.mods afterwards.
%   If DATA.mods does not exist, default modifiers will be used.
%   If DATA.mods is empty, no modifiers will be applied.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated contents.
%
%   Examples:
%   data = crg_mods(data),
%       applies mods on CRG data.
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
%   $Id: crg_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $


%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% apply mods

data = crg_mods_scale(data);
data = crg_mods_gnan(data);
data = crg_mods_byref(data);
data = crg_mods_byoff(data);

end

%% subfunction crg_mods_scale

function [data] = crg_mods_scale(data)
%CRG_MODS_SCALE apply scaling mods.
%   [DATA] = CRG_MODS_SCALE(DATA) applies scaling modifiers.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated information.
%
%   Examples:
%   data = crg_mods_scale(data);
%       applies related mods on CRG data.
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
%   $Id: crg_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $

%% set defaults

szgd = 1.0;
sslp = 1.0;
sbkg = 1.0;

slth = 1.0;
swth = 1.0;
scrv = 1.0;

%% read and clear mods

todo = 0;

if isfield(data.mods, 'szgd') % scale_z_grid
    todo = 1;
    szgd = data.mods.szgd;
    data.mods = rmfield(data.mods, 'szgd');
end

if isfield(data.mods, 'sslp') % scale_slope
    todo = 1;
    sslp = data.mods.sslp;
    data.mods = rmfield(data.mods, 'sslp');
end

if isfield(data.mods, 'sbkg') % scale_banking
    todo = 1;
    sbkg = data.mods.sbkg;
    data.mods = rmfield(data.mods, 'sbkg');
end

if isfield(data.mods, 'slth') % scale_length
    todo = 1;
    slth = data.mods.slth;
    data.mods = rmfield(data.mods, 'slth');
end

if isfield(data.mods, 'swth') % scale_width
    todo = 1;
    swth = data.mods.swth;
    data.mods = rmfield(data.mods, 'swth');
end

if isfield(data.mods, 'scrv') % scale_curvature
    todo = 1;
    scrv = data.mods.scrv;
    data.mods = rmfield(data.mods, 'scrv');
end

%% return if no relevant mods are found

if todo == 0
    return
end

%% apply mods

done = 0;

if szgd ~= 1.0 % scale elevation grid
    data.z = szgd * data.z;
end

if sslp ~= 1.0 % scale slope information
    if isfield(data, 's')
        data.s = sslp * data.s;
    end
    data.head.sbeg = sslp * data.head.sbeg;
    data.head.send = sslp * data.head.send;
    done = 1; % force check
    data.head.zend = data.head.zbeg + sslp*(data.head.zend-data.head.zbeg);
    if isfield(data.head, 'aend')
        data.head = rmfield(data.head, 'aend');
    end
end

if sbkg ~= 1.0 % scale banking information
    if isfield(data, 'b')
        data.b = sbkg * data.b;
    end
    data.head.bbeg = sbkg * data.head.bbeg;
    data.head.bend = sbkg * data.head.bend;
    done = 1; % force check
end

if slth ~= 1.0 % scale u information
    data.head.uinc = slth * data.head.uinc;
    data.head.uend = data.head.ubeg + slth*(data.head.uend-data.head.ubeg);
    data.u = single([data.head.ubeg data.head.uend]);
    done = 1; % force check
    data.head.xend = data.head.xbeg + slth*(data.head.xend-data.head.xbeg);
    data.head.yend = data.head.ybeg + slth*(data.head.yend-data.head.ybeg);
    data.head.zend = data.head.zbeg + slth*(data.head.zend-data.head.zbeg);
    if isfield(data.head, 'eend')
        data.head = rmfield(data.head, 'eend');
        data.head = rmfield(data.head, 'nend');
    end
    if isfield(data.head, 'aend')
        data.head = rmfield(data.head, 'aend');
    end
end

if swth ~= 1.0 % scale v information
    data.v         = swth * data.v;
    data.head.vmin = swth * data.head.vmin;
    data.head.vmax = swth * data.head.vmax;
    if isfield(data.head, 'vinc')
        data.head.vinc = swth * data.head.vinc;
    end
    done = 1; % force check
end

if scrv ~= 1.0 % scale reference line's curvature
    if isfield(data, 'p')
        p = cumsum([data.head.pbeg scrv*diff(unwrap(double(data.p)))]);
        p = atan2(sin(p), cos(p)); % re-wrap
        data.p = single(p);
        data.head.pend = p(end);
        done = 1; % force check
        data.head = rmfield(data.head, 'xend');
        data.head = rmfield(data.head, 'yend');
        if isfield(data.head, 'eend')
            data.head = rmfield(data.head, 'eend');
            data.head = rmfield(data.head, 'nend');
        end
    end
end

%% return if no relevant mods are applied

if done == 0
    return
end

%% check data again

data = rmfield(data, 'ok'); % force check

data = crg_check_data(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end

%% subfunction crg_mods_byoff

function [data] = crg_mods_byoff(data)
%CRG_MODS_BYOFF pply mods for refline pos by offset.
%   [DATA] = CRG_MODS_BYOFF(DATA) applies modifiers
%   related to the reference line position by setting an offset.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated information.
%
%   Examples:
%   data = crg_mods_byoff(data);
%       applies related mods on CRG data.
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
%   $Id: crg_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $

%% check if already succesfully checked

if ~isfield(data, 'ok') || data.ok ~= 0
    data = crg_check_data(data);
    if data.ok ~= 0
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% set option defaults

rlrx = data.head.xbeg;
rlry = data.head.ybeg;
rlop = 0;
rlox = 0;
rloy = 0;
rloz = 0;

%% read and clear mods

todo = 0;

if isfield(data.mods, 'rlrx') % refline_rotcenter_x
    rlrx = data.mods.rlrx;
    data.mods = rmfield(data.mods, 'rlrx');
end

if isfield(data.mods, 'rlry') % refline_rotcenter_y
    rlry = data.mods.rlry;
    data.mods = rmfield(data.mods, 'rlry');
end

if isfield(data.mods, 'rlop') % refline_offset_phi
    todo = 1;
    rlop = data.mods.rlop;
    data.mods = rmfield(data.mods, 'rlop');
end

if isfield(data.mods, 'rlox') % refline_offset_x
    todo = 1;
    rlox = data.mods.rlox;
    data.mods = rmfield(data.mods, 'rlox');
end

if isfield(data.mods, 'rloy') % refline_offset_y
    todo = 1;
    rloy = data.mods.rloy;
    data.mods = rmfield(data.mods, 'rloy');
end

if isfield(data.mods, 'rloz') % refline_offset_z
    todo = 1;
    rloz = data.mods.rloz;
    data.mods = rmfield(data.mods, 'rloz');
end

%% return if no relevant mods are found

if todo == 0
    return
end

%% apply mods

done = 0;

% first rotate:

if rlop ~= 0 % rotate by rlop
    p = data.head.pbeg + rlop; data.head.pbeg = atan2(sin(p), cos(p));
    p = data.head.pend + rlop; data.head.pend = atan2(sin(p), cos(p));
    p = data.head.poff - rlop; data.head.poff = atan2(sin(p), cos(p));

    if isfield(data, 'p')
        p = double(data.p) + rlop;
        data.p = single(atan2(sin(p), cos(p)));
    end

    ps = sin(rlop);
    pc = cos(rlop);
    
    % rotate by rlop around (xbeg, ybeg)
    
    dx = data.head.xend - data.head.xbeg;
    dy = data.head.yend - data.head.ybeg;
    data.head.xend = data.head.xbeg + dx*pc - dy*ps;
    data.head.yend = data.head.ybeg + dx*ps + dy*pc;
    
    % add offset resulting from distance (rlrx, rlry)->(xbeg, ybeg) 
    
    dx = data.head.xbeg - rlrx;
    dy = data.head.ybeg - rlry;
    rlox = rlox + dx*pc - dy*ps - dx;
    rloy = rloy + dx*ps + dy*pc - dy;

    done = 1; % force check
end

% then translate:

if rlox ~= 0 % translate by rlox
    data.head.xbeg = data.head.xbeg + rlox;
    data.head.xend = data.head.xend + rlox;
    data.head.xoff = data.head.xoff - rlox;
    done = 1; % force check
end

if rloy ~= 0 % translate by rloy
    data.head.ybeg = data.head.ybeg + rloy;
    data.head.yend = data.head.yend + rloy;
    data.head.yoff = data.head.yoff - rloy;
    done = 1; % force check
end

if rloz ~= 0 % translate by rloz
    data.head.zbeg = data.head.zbeg + rloz;
    data.head.zend = data.head.zend + rloz;
    data.head.zoff = data.head.zoff - rloz;
    done = 1; % force check
end


%% return if no relevant mods are applied

if done == 0
    return
end

%% check head and data again

data = crg_check_head(data);

data = rmfield(data, 'ok'); % force check

data = crg_check_data(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end

%% subfunction crg_mods_byref

function [data] = crg_mods_byref(data)
%CRG_MODS_BYREF apply mods for refline by refpoint.
%   [DATA] = CRG_MODS_BYREF(DATA) applies modifiers related
%   to the reference line position by setting a refpoint's position.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated information.
%
%   Examples:
%   data = crg_mods_byref(data)
%       applies related mods on CRG data.
%
%   See also CRG_INTRO.

%   Copyright 2005-2013 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $

%% check if already succesfully checked

if ~isfield(data, 'ok') || data.ok ~= 0
    data = crg_check_data(data);
    if data.ok ~= 0
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% set option defaults

rptu = NaN;
rptv = NaN;
rptx = 0;
rpty = 0;
rptz = 0;
rptp = 0;

%% read and clear mods

todo = 0;

if isfield(data.mods, 'rpfu') % refpoint_u_fraction
    todo = 1;
    rptu = data.head.ubeg + data.mods.rpfu*(data.head.uend-data.head.ubeg);
    data.mods = rmfield(data.mods, 'rpfu');
end
if isfield(data.mods, 'rptu') % refpoint_u
    todo = 1;
    if ~isnan(rptu)
        error('CRG:modsError', 'DATA.mods.rpou and DATA.mods.rptu may not be both defined')
    end
    rptu = data.mods.rptu;
    data.mods = rmfield(data.mods, 'rptu');
end
if isnan(rptu)
    rptu = data.head.ubeg; % default
end
if isfield(data.mods, 'rpou') % refpoint_u_offset
    todo = 1;
    rptu = rptu + data.mods.rpou;
    data.mods = rmfield(data.mods, 'rpou');
end

if isfield(data.mods, 'rpfv') % refpoint_v_fraction
    todo = 1;
    rptv = data.head.vmin + data.mods.rpfv*(data.head.vmax-data.head.vmin);
    data.mods = rmfield(data.mods, 'rpfv');
end
if isfield(data.mods, 'rptv') % refpoint_v
    todo = 1;
    if ~isnan(rptv)
        error('CRG:modsError', 'DATA.mods.rpov and DATA.mods.rptv may not be both defined')
    end
    rptv = data.mods.rptv;
    data.mods = rmfield(data.mods, 'rptv');
end
if isnan(rptv)
    rptv = 0; % default
end
if isfield(data.mods, 'rpov') % refpoint_v_offset
    rptv = rptv + data.mods.rpov;
    data.mods = rmfield(data.mods, 'rpov');
end

if isfield(data.mods, 'rptx') % refpoint_x
    todo = 1;
    rptx = data.mods.rptx;
    data.mods = rmfield(data.mods, 'rptx');
end
if isfield(data.mods, 'rpty') % refpoint_y
    todo = 1;
    rpty = data.mods.rpty;
    data.mods = rmfield(data.mods, 'rpty');
end
if isfield(data.mods, 'rptz') % refpoint_z
    todo = 1;
    rptz = data.mods.rptz;
    data.mods = rmfield(data.mods, 'rptz');
end
if isfield(data.mods, 'rptp') % refpoint_phi
    todo = 1;
    rptp = data.mods.rptp;
    data.mods = rmfield(data.mods, 'rptp');
end

%% return if no relevant mods are found

if todo == 0
    return
end

%% find current refpoint position and orientation

[pxy data] = crg_eval_uv2xy(data, [rptu rptv]);
[pz  data] = crg_eval_uv2z (data, [rptu rptv]);

[phi data] = crg_eval_u2phi(data, rptu);

%% calculate offsets needed to move refpoint to target position

rlop = rptp - phi; % rotation around refline start point

dx = pxy(1, 1) - data.head.xbeg;
dy = pxy(1, 2) - data.head.ybeg;
px = data.head.xbeg + dx*cos(rlop) - dy*sin(rlop);
py = data.head.ybeg + dx*sin(rlop) + dy*cos(rlop);

rlox = rptx - px;
rloy = rpty - py;
rloz = rptz - pz;

%% set offset mods - they will be applied in subsequent crg_mods_byoff call

data.mods.rlrx = data.head.xbeg;
data.mods.rlry = data.head.ybeg;
data.mods.rlop = rlop;
data.mods.rlox = rlox;
data.mods.rloy = rloy;
data.mods.rloz = rloz;

end

%% subfunction crg_mods_gnan

function [data] = crg_mods_gnan(data)
%CRG_MODS_GNAN apply mods for elevation grid NaN.
%   [DATA] = CRG_MODS_GNAN(DATA) applies modifiers related to the
%   handling of NaN in the elevation grid.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated information.
%
%   Examples:
%   data = crg_mods_gnan(data);
%       executes related mods on CRG data.
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
%   $Id: crg_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $

%% set defaults

gnan = 2;
gnao = 0;

%% read and clear mods

todo = 0;

if isfield(data.mods, 'gnan') % grid_nan_mode
    todo = 1;
    gnan = data.mods.gnan;
    data.mods = rmfield(data.mods, 'gnan');
end

if isfield(data.mods, 'gnao') % grid_nan_offset
    todo = 1;
    gnao = data.mods.gnao;
    data.mods = rmfield(data.mods, 'gnao');
end

%% return if no relevant mods are found

if todo == 0
    return
end

%% apply mods

done = 0;

nu = size(data.z, 1);

switch gnan
    case 0 % keep NaN
    case 1 % set zero
        for i = 1:nu
            data.z(i,            1:data.ir(i)-1) = gnao;
            data.z(i, data.il(i)+1:end         ) = gnao;
        end
        done = 1; % force check
    case 2 % keep last
        for i = 1:nu
            data.z(i,            1:data.ir(i)-1) = data.z(i, data.ir(i)) + gnao;
            data.z(i, data.il(i)+1:end         ) = data.z(i, data.il(i)) + gnao;
        end
        done = 1; % force check
    otherwise
        error('CRG:checkError', 'illegal value of data.mods.gnan = %d', gnan)
end

%% return if no relevant mods are applied

if done == 0
    return
end

%% check data again

data = rmfield(data, 'ok'); % force check

data = crg_check_data(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end
