function [data] = crg_check_mods(data)
%CRG_CHECK_MODS check mods data.
%   [DATA] = CRG_CHECK_MODS(DATA) checks CRG mods data for consistency
%   of definitions and values, and provides missing defaults.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    is a checked, purified, and eventually completed version of
%           the function input argument DATA
%
%   Examples:
%   data = crg_check_mods(data) checks CRG mods data.
%
%   See also CRG_CHECK, CRG_INTRO.

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
%   $Id: crg_check_mods.m 358 2015-10-05 19:14:23Z jorauh@EMEA.CORPDIR.NET $

%% remove ok flag, initialize error/warning counter

if isfield(data, 'ok')
    data = rmfield(data, 'ok');
end
ierr = 0;

%% check for mods field

if ~isfield(data, 'mods') % set defaults
    data.mods = struct;

    % CRG elevation grid NaN handling
    data.mods.gnan = 2; % replace NaN by last value in cross section

    % CRG re-positioning: refline by refpoint
    data.mods.rptp = 0; % (setting one selects all defaults)
end

%%  keep only what we know and want

mods = struct;

if isfield(data.mods, 'szgd'), mods.szgd = data.mods.szgd; end
if isfield(data.mods, 'sslp'), mods.sslp = data.mods.sslp; end
if isfield(data.mods, 'sbkg'), mods.sbkg = data.mods.sbkg; end
if isfield(data.mods, 'slth'), mods.slth = data.mods.slth; end
if isfield(data.mods, 'swth'), mods.swth = data.mods.swth; end
if isfield(data.mods, 'scrv'), mods.scrv = data.mods.scrv; end

if isfield(data.mods, 'gnan'), mods.gnan = data.mods.gnan; end
if isfield(data.mods, 'gnao'), mods.gnao = data.mods.gnao; end

if isfield(data.mods, 'rlrx'), mods.rlrx = data.mods.rlrx; end
if isfield(data.mods, 'rlry'), mods.rlry = data.mods.rlry; end
if isfield(data.mods, 'rlop'), mods.rlop = data.mods.rlop; end
if isfield(data.mods, 'rlox'), mods.rlox = data.mods.rlox; end
if isfield(data.mods, 'rloy'), mods.rloy = data.mods.rloy; end
if isfield(data.mods, 'rloz'), mods.rloz = data.mods.rloz; end

if isfield(data.mods, 'rpfu'), mods.rpfu = data.mods.rpfu; end
if isfield(data.mods, 'rpou'), mods.rpou = data.mods.rpou; end
if isfield(data.mods, 'rptu'), mods.rptu = data.mods.rptu; end
if isfield(data.mods, 'rptv'), mods.rptv = data.mods.rptv; end
if isfield(data.mods, 'rpfv'), mods.rpfv = data.mods.rpfv; end
if isfield(data.mods, 'rpov'), mods.rpov = data.mods.rpov; end
if isfield(data.mods, 'rptx'), mods.rptx = data.mods.rptx; end
if isfield(data.mods, 'rpty'), mods.rpty = data.mods.rpty; end
if isfield(data.mods, 'rptz'), mods.rptz = data.mods.rptz; end
if isfield(data.mods, 'rptp'), mods.rptp = data.mods.rptp; end

data.mods = mods;

%% check singular value ranges and set missing defaults

% CRG scaling
if isfield(data.mods, 'slth')
    if data.mods.slth <= 0
        error('CRG:checkError', 'illegal DATA.mods.slth=%d', data.mods.slth)
    end
end
if isfield(data.mods, 'swth')
    if data.mods.swth <= 0
        error('CRG:checkError', 'illegal DATA.mods.swth=%d', data.mods.swth)
    end
end

% CRG elevation grid NaN handling
if isfield(data.mods, 'gnan')
    if data.mods.gnan<0 || data.mods.gnan>2 || data.mods.gnan~=round(data.mods.gnan)
        error('CRG:checkError', 'illegal DATA.mods.gnan=%d', data.mods.gnan)
    end
end
if isfield(data.mods, 'gnao')
    if ~isfield(data.mods, 'gnan')
        data.mods.gnan = 2; % default
    end
    if data.mods.gnan == 0 % check for useless offset setting
        error('CRG:checkError', 'inconsistent DATA.mods.gnan=%d and DATA.mods.gnao=%d', data.mods.gnan, data.mods.gnao)
    end
end

% CRG re-positioning: refline by offset (default: "by refpoint")
byoff = 0;
if isfield(data.mods, 'rlop'), byoff = 1; end
if isfield(data.mods, 'rlox'), byoff = 1; end
if isfield(data.mods, 'rloy'), byoff = 1; end
if isfield(data.mods, 'rloz'), byoff = 1; end

if byoff ~= 0
    if ~isfield(data.mods, 'rlop'), data.mods.rlop = 0; end % default
    if ~isfield(data.mods, 'rlox'), data.mods.rlox = 0; end % default
    if ~isfield(data.mods, 'rloy'), data.mods.rloy = 0; end % default
    if ~isfield(data.mods, 'rloz'), data.mods.rloz = 0; end % default
end

% CRG re-positioning: refline by refpoint (overwrites "by offset")
byref = 0;
if isfield(data.mods, 'rpfu'), byref = 1; end
if isfield(data.mods, 'rptu'), byref = 1; end
if isfield(data.mods, 'rpfv'), byref = 1; end
if isfield(data.mods, 'rptv'), byref = 1; end
if isfield(data.mods, 'rptx'), byref = 1; end
if isfield(data.mods, 'rpty'), byref = 1; end
if isfield(data.mods, 'rptz'), byref = 1; end
if isfield(data.mods, 'rptp'), byref = 1; end

if byref~=0 && byoff~=0
    data.mods = rmfield(data.mods, {'rlox' 'rloy' 'rloz' 'rlop'});
    warning('CRG:checkWarning', 'CRG re-positioning modifiers: refline "by refpoint" overwrites "by offset" setting')
    ierr = ierr + 1;
end

if byref~=0
    if isfield(data.mods, 'rpfu') && isfield(data.mods, 'rptu')
        error('CRG:checkError', 'only one of DATA.mods.rpfu and DATA.mods.rptu may be defined')
    end
    if ~isfield(data.mods, 'rpfu') && ~isfield(data.mods, 'rptu')
        data.mods.rpfu = 0; % default
    end
    if isfield(data.mods, 'rpfv') && isfield(data.mods, 'rptv')
        error('CRG:checkError', 'only one of DATA.mods.rpfv and DATA.mods.rptv may be defined')
    end
    if ~isfield(data.mods, 'rpfv') && ~isfield(data.mods, 'rptv')
        data.mods.rptv = 0; % default
    end
    if ~isfield(data.mods, 'rpou'), data.mods.rpou = 0; end % default
    if ~isfield(data.mods, 'rpov'), data.mods.rpov = 0; end % default
    if ~isfield(data.mods, 'rptx'), data.mods.rptx = 0; end % default
    if ~isfield(data.mods, 'rpty'), data.mods.rpty = 0; end % default
    if ~isfield(data.mods, 'rptz'), data.mods.rptz = 0; end % default
    if ~isfield(data.mods, 'rptp'), data.mods.rptp = 0; end % default
end

%% set ok-flag if no errors/warnings occured

if ierr == 0
    data.ok = 0;
end

end
