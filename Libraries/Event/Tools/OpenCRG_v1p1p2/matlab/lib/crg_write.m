function [ier] = crg_write(data, file)
% CRG_WRITE CRG road file writer.
%   IER = CRG_WRITE(DATA, FILE) writes CRG (curved regular grid)
%   road data file
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%   FILE    file to write
%
%   Outputs:
%   IER     error flag
%           = 0: o.k.
%           =-1: error
%
%   Example:
%   ier = crg_write(data, file) writes CRG data structure to CRG file.
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
%   $Id: crg_write.m 334 2013-11-30 15:06:30Z jorauh $

%% force check

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

%% generate struct data blocks

crgdat.struct = cell(1,0);

%% generate struct data block $CT with comment text

c = cell(1,0);

if isfield(data, 'ct')
    for i=1:length(data.ct)
        c{end+1} = data.ct{i}; %#ok<AGROW>
    end
else
    error('CRG:writeError', 'comment text in DATA.ct missing')
end

crgdat.struct = sdf_add(crgdat.struct, 'CT', c);

%% generate struct data block $ROAD_CRG with header data

head = data.head;

c = cell(1,0);

if isfield(head, 'ubeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_u   ', head.ubeg); end
if isfield(head, 'uend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_u     ', head.uend); end
if isfield(head, 'uinc'), c{end+1} = sprintf('%s = %24.16e','reference_line_increment ', head.uinc); end
if isfield(head, 'vmin'), c{end+1} = sprintf('%s = %24.16e','long_section_v_right     ', head.vmin); end
if isfield(head, 'vmax'), c{end+1} = sprintf('%s = %24.16e','long_section_v_left      ', head.vmax); end
if isfield(head, 'vinc'), c{end+1} = sprintf('%s = %24.16e','long_section_v_increment ', head.vinc); end
if isfield(head, 'sbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_s   ', head.sbeg); end
if isfield(head, 'send'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_s     ', head.send); end
if isfield(head, 'bbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_b   ', head.bbeg); end
if isfield(head, 'bend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_b     ', head.bend); end
if isfield(head, 'xbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_x   ', head.xbeg); end
if isfield(head, 'ybeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_y   ', head.ybeg); end
if isfield(head, 'xend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_x     ', head.xend); end
if isfield(head, 'yend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_y     ', head.yend); end
if isfield(head, 'xoff'), c{end+1} = sprintf('%s = %24.16e','reference_line_offset_x  ', head.xoff); end
if isfield(head, 'yoff'), c{end+1} = sprintf('%s = %24.16e','reference_line_offset_y  ', head.yoff); end
if isfield(head, 'pbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_phi ', head.pbeg); end
if isfield(head, 'pend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_phi   ', head.pend); end
if isfield(head, 'poff'), c{end+1} = sprintf('%s = %24.16e','reference_line_offset_phi', head.poff); end
if isfield(head, 'zbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_z   ', head.zbeg); end
if isfield(head, 'zend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_z     ', head.zend); end
if isfield(head, 'zoff'), c{end+1} = sprintf('%s = %24.16e','reference_line_offset_z  ', head.zoff); end
if isfield(head, 'ebeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_lon ', head.ebeg); end
if isfield(head, 'nbeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_lat ', head.nbeg); end
if isfield(head, 'eend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_lon   ', head.eend); end
if isfield(head, 'nend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_lat   ', head.nend); end
if isfield(head, 'abeg'), c{end+1} = sprintf('%s = %24.16e','reference_line_start_alt ', head.abeg); end
if isfield(head, 'aend'), c{end+1} = sprintf('%s = %24.16e','reference_line_end_alt   ', head.aend); end

crgdat.struct = sdf_add(crgdat.struct, 'ROAD_CRG', c);

clear c head

%% generate struct data block $MODS with modifier data

mods = data.mods;

% generate struct data block lines

c = cell(1,0);

% CRG scaling
if isfield(mods, 'szgd'), c{end+1} = sprintf('%s = %24.16e','scale_z_grid         ', mods.szgd); end
if isfield(mods, 'sslp'), c{end+1} = sprintf('%s = %24.16e','scale_slope          ', mods.sslp); end
if isfield(mods, 'sbkg'), c{end+1} = sprintf('%s = %24.16e','scale_banking        ', mods.sbkg); end
if isfield(mods, 'slth'), c{end+1} = sprintf('%s = %24.16e','scale_length         ', mods.slth); end
if isfield(mods, 'swth'), c{end+1} = sprintf('%s = %24.16e','scale_width          ', mods.swth); end
if isfield(mods, 'scrv'), c{end+1} = sprintf('%s = %24.16e','scale_curvature      ', mods.scrv); end

% CRG elevation grid NaN handling
if isfield(mods, 'gnan'), c{end+1} = sprintf('%s = %24.16e','grid_nan_mode       ', mods.gnan); end
if isfield(mods, 'gnao'), c{end+1} = sprintf('%s = %24.16e','grid_nan_offset     ', mods.gnao); end

% CRG re-positioning: refline by offset
if isfield(mods, 'rlrx'), c{end+1} = sprintf('%s = %24.16e','refline_rotcenter_x ', mods.rlrx); end
if isfield(mods, 'rlry'), c{end+1} = sprintf('%s = %24.16e','refline_rotcenter_y ', mods.rlry); end
if isfield(mods, 'rlop'), c{end+1} = sprintf('%s = %24.16e','refline_offset_phi  ', mods.rlop); end
if isfield(mods, 'rlox'), c{end+1} = sprintf('%s = %24.16e','refline_offset_x    ', mods.rlox); end
if isfield(mods, 'rloy'), c{end+1} = sprintf('%s = %24.16e','refline_offset_y    ', mods.rloy); end
if isfield(mods, 'rloz'), c{end+1} = sprintf('%s = %24.16e','refline_offset_z    ', mods.rloz); end

% CRG re-positioning: refline by refpoint
if isfield(mods, 'rptu'), c{end+1} = sprintf('%s = %24.16e','refpoint_u         ', mods.rptu); end
if isfield(mods, 'rpfu'), c{end+1} = sprintf('%s = %24.16e','refpoint_u_fraction', mods.rpfu); end
if isfield(mods, 'rpou'), c{end+1} = sprintf('%s = %24.16e','refpoint_u_offset  ', mods.rpou); end
if isfield(mods, 'rptv'), c{end+1} = sprintf('%s = %24.16e','refpoint_v         ', mods.rptv); end
if isfield(mods, 'rpfv'), c{end+1} = sprintf('%s = %24.16e','refpoint_v_fraction', mods.rpfv); end
if isfield(mods, 'rpov'), c{end+1} = sprintf('%s = %24.16e','refpoint_v_offset  ', mods.rpov); end
if isfield(mods, 'rptx'), c{end+1} = sprintf('%s = %24.16e','refpoint_x         ', mods.rptx); end
if isfield(mods, 'rpty'), c{end+1} = sprintf('%s = %24.16e','refpoint_y         ', mods.rpty); end
if isfield(mods, 'rptz'), c{end+1} = sprintf('%s = %24.16e','refpoint_z         ', mods.rptz); end
if isfield(mods, 'rptp'), c{end+1} = sprintf('%s = %24.16e','refpoint_phi       ', mods.rptp); end

% write only non-default struct data block
default = struct;
default = crg_check_mods(default);
if ~isequal(mods, default.mods)
     crgdat.struct = sdf_add(crgdat.struct, 'ROAD_CRG_MODS', c);
end

clear c mods default

%% generate struct data block $OPTS with option data

opts = data.opts;

% get/check/remove default opts
default = struct;
default = crg_check_opts(default);
f = fieldnames(opts);
for i = 1:size(f)
    if isfield(default.opts, f{i}) && (opts.(f{i}) == default.opts.(f{i}))
        opts = rmfield(opts, f{i});
    end
end
clear f default

% generate struct data block lines

c = cell(1,0);

% CRG border modes in u and v directions
if isfield(opts, 'bdmu'), c{end+1} = sprintf('%s = %24.16e','border_mode_u       ', opts.bdmu); end
if isfield(opts, 'bdmv'), c{end+1} = sprintf('%s = %24.16e','border_mode_v       ', opts.bdmv); end
if isfield(opts, 'bdou'), c{end+1} = sprintf('%s = %24.16e','border_offset_u     ', opts.bdou); end
if isfield(opts, 'bdov'), c{end+1} = sprintf('%s = %24.16e','border_offset_v     ', opts.bdov); end
if isfield(opts, 'bdss'), c{end+1} = sprintf('%s = %24.16e','border_smooth_ubeg  ', opts.bdss); end
if isfield(opts, 'bdse'), c{end+1} = sprintf('%s = %24.16e','border_smooth_uend  ', opts.bdse); end

% CRG reference line continuation
if isfield(opts, 'rflc'), c{end+1} = sprintf('%s = %24.16e','refline_continuation', opts.rflc); end

% CRG reference line search strategy
if isfield(opts, 'sfar'), c{end+1} = sprintf('%s = %24.16e','refline_search_far  ', opts.sfar); end
if isfield(opts, 'scls'), c{end+1} = sprintf('%s = %24.16e','refline_search_close', opts.scls); end

% CRG message options
if isfield(opts, 'wmsg'), c{end+1} = sprintf('%s = %24.16e','warn_msgs           ', opts.wmsg); end
if isfield(opts, 'wcvl'), c{end+1} = sprintf('%s = %24.16e','warn_curv_local     ', opts.wcvl); end
if isfield(opts, 'wcvg'), c{end+1} = sprintf('%s = %24.16e','warn_curv_global    ', opts.wcvg); end
if isfield(opts, 'lmsg'), c{end+1} = sprintf('%s = %24.16e','log_msgs            ', opts.lmsg); end
if isfield(opts, 'leva'), c{end+1} = sprintf('%s = %24.16e','log_eval            ', opts.leva); end
if isfield(opts, 'levf'), c{end+1} = sprintf('%s = %24.16e','log_eval_freq       ', opts.levf); end
if isfield(opts, 'lhst'), c{end+1} = sprintf('%s = %24.16e','log_hist            ', opts.lhst); end
if isfield(opts, 'lhsf'), c{end+1} = sprintf('%s = %24.16e','log_hist_freq       ', opts.lhsf); end
if isfield(opts, 'lsta'), c{end+1} = sprintf('%s = %24.16e','log_stat            ', opts.lsta); end
if isfield(opts, 'lstf'), c{end+1} = sprintf('%s = %24.16e','log_stat_freq       ', opts.lstf); end

% CRG check options
if isfield(opts, 'ceps'), c{end+1} = sprintf('%s = %24.16e','check_eps           ', opts.ceps); end
if isfield(opts, 'cinc'), c{end+1} = sprintf('%s = %24.16e','check_inc           ', opts.cinc); end
if isfield(opts, 'ctol'), c{end+1} = sprintf('%s = %24.16e','check_tol           ', opts.ctol); end

% write only non-empty struct data block
if size(c, 2) > 0
    crgdat.struct = sdf_add(crgdat.struct, 'ROAD_CRG_OPTS', c);
end

clear c opts

%% add further struct data if available

if isfield(data, 'struct')
    for i=1:length(data.struct)
        crgdat.struct{end+1} = data.struct{i};
    end
end

%% add timestamp

crgdat.struct{end+1} = ...
    sprintf('* written by %s at %s', mfilename, datestr(now, 31));

%% generate data for $KD_DEFINITION block and data array

%  generate virtual data channel definition
crgdat.kd_ind = cell(1,0);
crgdat.kd_ind{end+1} = sprintf('reference line u,m,%.3f,%.3f', data.head.ubeg, data.head.uinc);

%  generate dependant channel definitions and data array
crgdat.kd_def = cell(1,0);
crgdat.kd_dat = [];

%  generate dependant channel definitions: heading
if isfield(data, 'p') && length(data.p) > 1
    crgdat.kd_def{end+1} = 'reference line phi,rad';
    % first value will be ignored on reading
    crgdat.kd_dat = [crgdat.kd_dat [NaN('single') single(data.p)]'];
end

%  generate dependant channel definitions: slope
if isfield(data, 's') && length(data.s) > 1
    crgdat.kd_def{end+1} = 'reference line slope,m/m';
    % first value will be ignored on reading
    crgdat.kd_dat = [crgdat.kd_dat [NaN('single') single(data.s)]'];
end

%  generate dependant channel definitions: banking
if isfield(data, 'b') && length(data.b) > 1
    crgdat.kd_def{end+1} = 'reference line banking,m/m';
    crgdat.kd_dat = [crgdat.kd_dat single(data.b)'];
end

%  generate dependant channel definitions: long section position/number
nv = size(data.z, 2);
if isfield(data, 'v') && length(data.v) == nv
    for i = 1:nv
        crgdat.kd_def{end+1} = sprintf('long section at v = %.3f,m', double(data.v(i)));
    end
else
    for i = 1:nv
        crgdat.kd_def{end+1} = sprintf('long section %d,m', i);
    end
end
crgdat.kd_dat = [crgdat.kd_dat single(data.z)];

% write all CRG data as IPLOS-KRBI data file

ier = ipl_write(crgdat, file, 'KRBI');

end
