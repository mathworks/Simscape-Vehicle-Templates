function [data] = crg_show_info(data)
% CRG_SHOW_INFO CRG road text info visualizer.
%   DATA = CRG_SHOW_INFO(DATA) visualizes CRG info in text form.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_show_info (data)
%       shows full text info.
%   See also CRG_INTRO.

%   Copyright 2010-2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_show_info.m 286 2011-05-16 15:39:28Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% define figure frame

if ~isfield(data, 'fopt') || ~isfield(data.fopt, 'tit')
    data.fopt.tit = 'CRG information';
    data          = crg_figure(data);
    data.fopt     = rmfield(data.fopt, 'tit');
else
    data = crg_figure(data);
end

%% left annotation textbox

c = cell(1,0);

% SIZE

[nu nv] = size(data.z);
c{end+1} = 'CRG elevation grid size:';
c{end+1} = sprintf('%s = %20.12g','length                   ', nu);
c{end+1} = sprintf('%s = %20.12g','width                    ', nv);
c{end+1} = '';

% HEAD

head = data.head;

c{end+1} = 'CRG header data:';
if isfield(head, 'ubeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_u   ', head.ubeg); end
if isfield(head, 'uend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_u     ', head.uend); end
if isfield(head, 'uinc'), c{end+1} = sprintf('%s = %20.12g','reference_line_increment ', head.uinc); end

if isfield(head, 'vmin'), c{end+1} = sprintf('%s = %20.12g','long_section_v_right     ', head.vmin); end
if isfield(head, 'vmax'), c{end+1} = sprintf('%s = %20.12g','long_section_v_left      ', head.vmax); end
if isfield(head, 'vinc'), c{end+1} = sprintf('%s = %20.12g','long_section_v_increment ', head.vinc); end

if isfield(head, 'xbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_x   ', head.xbeg); end
if isfield(head, 'xend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_x     ', head.xend); end
if isfield(head, 'xoff'), c{end+1} = sprintf('%s = %20.12g','reference_line_offset_x  ', head.xoff); end

if isfield(head, 'ybeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_y   ', head.ybeg); end
if isfield(head, 'yend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_y     ', head.yend); end
if isfield(head, 'yoff'), c{end+1} = sprintf('%s = %20.12g','reference_line_offset_y  ', head.yoff); end

if isfield(head, 'zbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_z   ', head.zbeg); end
if isfield(head, 'zend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_z     ', head.zend); end
if isfield(head, 'zoff'), c{end+1} = sprintf('%s = %20.12g','reference_line_offset_z  ', head.zoff); end

if isfield(head, 'pbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_phi ', head.pbeg); end
if isfield(head, 'pend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_phi   ', head.pend); end
if isfield(head, 'poff'), c{end+1} = sprintf('%s = %20.12g','reference_line_offset_phi', head.poff); end

if isfield(head, 'sbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_s   ', head.sbeg); end
if isfield(head, 'send'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_s     ', head.send); end

if isfield(head, 'bbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_b   ', head.bbeg); end
if isfield(head, 'bend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_b     ', head.bend); end

if isfield(head, 'ebeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_lon ', head.ebeg); end
if isfield(head, 'eend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_lon   ', head.eend); end

if isfield(head, 'nbeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_lat ', head.nbeg); end
if isfield(head, 'nend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_lat   ', head.nend); end

if isfield(head, 'abeg'), c{end+1} = sprintf('%s = %20.12g','reference_line_start_alt ', head.abeg); end
if isfield(head, 'aend'), c{end+1} = sprintf('%s = %20.12g','reference_line_end_alt   ', head.aend); end

c{end+1} = '';

% MODS

mods = data.mods;

c{end+1} = 'CRG modifier data:';
% CRG scaling
if isfield(mods, 'szgd'), c{end+1} = sprintf('%s = %20.12g','scale_z_grid             ', mods.szgd); end
if isfield(mods, 'sslp'), c{end+1} = sprintf('%s = %20.12g','scale_slope              ', mods.sslp); end
if isfield(mods, 'sbkg'), c{end+1} = sprintf('%s = %20.12g','scale_banking            ', mods.sbkg); end
if isfield(mods, 'slth'), c{end+1} = sprintf('%s = %20.12g','scale_length             ', mods.slth); end
if isfield(mods, 'swth'), c{end+1} = sprintf('%s = %20.12g','scale_width              ', mods.swth); end
if isfield(mods, 'scrv'), c{end+1} = sprintf('%s = %20.12g','scale_curvature          ', mods.scrv); end
% CRG elevation grid NaN handling
if isfield(mods, 'gnan'), c{end+1} = sprintf('%s = %20.12g','grid_nan_mode            ', mods.gnan); end
if isfield(mods, 'gnao'), c{end+1} = sprintf('%s = %20.12g','grid_nan_offset          ', mods.gnao); end
% CRG re-positioning: refline by offset
if isfield(mods, 'rlox'), c{end+1} = sprintf('%s = %20.12g','refline_offset_x         ', mods.rlox); end
if isfield(mods, 'rloy'), c{end+1} = sprintf('%s = %20.12g','refline_offset_y         ', mods.rloy); end
if isfield(mods, 'rloz'), c{end+1} = sprintf('%s = %20.12g','refline_offset_z         ', mods.rloz); end
if isfield(mods, 'rlop'), c{end+1} = sprintf('%s = %20.12g','refline_offset_phi       ', mods.rlop); end
% CRG re-positioning: refline by refpoint
if isfield(mods, 'rptu'), c{end+1} = sprintf('%s = %20.12g','refpoint_u               ', mods.rptu); end
if isfield(mods, 'rpfu'), c{end+1} = sprintf('%s = %20.12g','refpoint_u_fraction      ', mods.rpfu); end
if isfield(mods, 'rpou'), c{end+1} = sprintf('%s = %20.12g','refpoint_u_offset        ', mods.rpou); end
if isfield(mods, 'rptv'), c{end+1} = sprintf('%s = %20.12g','refpoint_v               ', mods.rptv); end
if isfield(mods, 'rpfv'), c{end+1} = sprintf('%s = %20.12g','refpoint_v_fraction      ', mods.rpfv); end
if isfield(mods, 'rpov'), c{end+1} = sprintf('%s = %20.12g','refpoint_v_offset        ', mods.rpov); end
if isfield(mods, 'rptx'), c{end+1} = sprintf('%s = %20.12g','refpoint_x               ', mods.rptx); end
if isfield(mods, 'rpty'), c{end+1} = sprintf('%s = %20.12g','refpoint_y               ', mods.rpty); end
if isfield(mods, 'rptz'), c{end+1} = sprintf('%s = %20.12g','refpoint_z               ', mods.rptz); end
if isfield(mods, 'rptp'), c{end+1} = sprintf('%s = %20.12g','refpoint_phi             ', mods.rptp); end
c{end+1} = '';

% OPTS

opts = data.opts;

c{end+1} = 'CRG option data:';

% CRG border modes in u and v directions
if isfield(opts, 'bdmu'), c{end+1} = sprintf('%s = %20.12g','border_mode_u            ', opts.bdmu); end
if isfield(opts, 'bdmv'), c{end+1} = sprintf('%s = %20.12g','border_mode_v            ', opts.bdmv); end
if isfield(opts, 'bdou'), c{end+1} = sprintf('%s = %20.12g','border_offset_u          ', opts.bdou); end
if isfield(opts, 'bdov'), c{end+1} = sprintf('%s = %20.12g','border_offset_v          ', opts.bdov); end
if isfield(opts, 'bdss'), c{end+1} = sprintf('%s = %20.12g','border_smooth_ubeg       ', opts.bdss); end
if isfield(opts, 'bdse'), c{end+1} = sprintf('%s = %20.12g','border_smooth_uend       ', opts.bdse); end
% CRG reference line continuation
if isfield(opts, 'rflc'), c{end+1} = sprintf('%s = %20.12g','refline_continuation     ', opts.rflc); end
% CRG reference line search strategy
if isfield(opts, 'sfar'), c{end+1} = sprintf('%s = %20.12g','refline_search_far       ', opts.sfar); end
if isfield(opts, 'scls'), c{end+1} = sprintf('%s = %20.12g','refline_search_close     ', opts.scls); end
%     % CRG message options
%     if isfield(opts, 'wmsg'), c{end+1} = sprintf('%s = %20.12g','warn_msgs                ', opts.wmsg); end
%     if isfield(opts, 'wcvl'), c{end+1} = sprintf('%s = %20.12g','warn_curv_local          ', opts.wcvl); end
%     if isfield(opts, 'wcvg'), c{end+1} = sprintf('%s = %20.12g','warn_curv_global         ', opts.wcvg); end
%     if isfield(opts, 'lmsg'), c{end+1} = sprintf('%s = %20.12g','log_msgs                 ', opts.lmsg); end
%     if isfield(opts, 'leva'), c{end+1} = sprintf('%s = %20.12g','log_eval                 ', opts.leva); end
%     if isfield(opts, 'levf'), c{end+1} = sprintf('%s = %20.12g','log_eval_freq            ', opts.levf); end
%     if isfield(opts, 'lhst'), c{end+1} = sprintf('%s = %20.12g','log_hist                 ', opts.lhst); end
%     if isfield(opts, 'lhsf'), c{end+1} = sprintf('%s = %20.12g','log_hist_freq            ', opts.lhsf); end
%     if isfield(opts, 'lsta'), c{end+1} = sprintf('%s = %20.12g','log_stat                 ', opts.lsta); end
%     if isfield(opts, 'lstf'), c{end+1} = sprintf('%s = %20.12g','log_stat_freq            ', opts.lstf); end
% CRG check options
if isfield(opts, 'ceps'), c{end+1} = sprintf('%s = %20.12g','check_eps                ', opts.ceps); end
if isfield(opts, 'cinc'), c{end+1} = sprintf('%s = %20.12g','check_inc                ', opts.cinc); end
if isfield(opts, 'ctol'), c{end+1} = sprintf('%s = %20.12g','check_tol                ', opts.ctol); end

c{end+1} = '';

% DVED

dved = data.dved;

c{end+1} = 'CRG derived data:';

% CRG roundtrip data
if isfield(dved, 'ubex'), c{end+1} = sprintf('%s = %20.12g','crossing_ubeg            ', dved.ubex); end
if isfield(dved, 'uenx'), c{end+1} = sprintf('%s = %20.12g','crossing_uend            ', dved.uenx); end
if isfield(dved, 'ulex'), c{end+1} = sprintf('%s = %20.12g','crossing_ulen            ', dved.ulex); end

p0 = [0.02 0.07 0.46 0.86];
s0 = 10;
a = annotation('textbox', p0, ...
    'BackgroundColor', 'w', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Interpreter', 'none', ...
    'LineStyle', 'none', ...
    'FontName', 'FixedWidth', ...
    'FontSize', s0, ...
    'FitBoxToText', 'off', ...
    'String', c);
set(a, 'FitBoxToText', 'on');
p1 = get(a, 'Position');
s1 = s0 * min(p0(3)/p1(3), p0(4)/p1(4));
if s1 < s0
    set(a, 'FontSize', s1)
end
set(a, 'FitBoxToText', 'off');
set(a, 'Position', p0);


%% right annotation textbox

c = cell(1,0);

c{end+1} = 'CRG comment data:';
c{end+1} = '';

if isfield(data, 'ct')
    for i = 1:length(data.ct)
        c{end+1} = data.ct{i}; %#ok<AGROW>
    end
end

p0 = [0.52 0.07 0.46 0.86];
s0 = 10;
a = annotation('textbox', p0, ...
    'BackgroundColor', 'w', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Interpreter', 'none', ...
    'LineStyle', 'none', ...
    'FontName', 'FixedWidth', ...
    'FontSize', s0, ...
    'FitBoxToText', 'off', ...
    'String', c);

set(a, 'FitBoxToText', 'on');
p1 = get(a, 'Position');
s1 = s0 * min(p0(3)/p1(3), p0(4)/p1(4));
if s1 < s0
    set(a, 'FontSize', s1)
end
set(a, 'FitBoxToText', 'off');
set(a, 'Position', p0);

end
