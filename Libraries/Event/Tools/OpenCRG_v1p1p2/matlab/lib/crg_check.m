function [data] = crg_check(data)
% CRG_CHECK CRG check, fix, and complement data.
%   [DATA] = CRG_CHECK(DATA) checks CRG data for consistency
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
%   data = crg_check(data) checks and complements CRG data.
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
%   $Id: crg_check.m 184 2010-09-22 07:41:39Z jorauh $

%% initialize error/warning counter

ierr = 0;

%% check opts consistency

data = crg_check_opts(data);
if ~isfield(data, 'ok')
    ierr = ierr + 1;
end

%% check mods consistency

data = crg_check_mods(data);
if ~isfield(data, 'ok')
    ierr = ierr + 1;
end

%% check head consistency

data = crg_check_head(data);
if ~isfield(data, 'ok')
    ierr = ierr + 1;
end

%% check data consistency

data = crg_check_data(data);
if ~isfield(data, 'ok')
    ierr = ierr + 1;
end

%% check core data type

data = crg_check_single(data);
if ~isfield(data, 'ok')
    ierr = ierr + 1;
end

%% set ok-flag

if ierr == 0
    data.ok = 0;
else
    warning('CRG:checkWarning', 'check of DATA was not completely successful')
    if isfield(data, 'ok')
        data = rmfield(data, 'ok');
    end
end

end
