function [data] = crg_check_single(data)
%CRG_CHECK_SINGLE single type check of core data.
%   [DATA] = CRG_CHECK_SINGLE(DATA) makes CRG data type check for
%   core data vectors and arrays.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with unchanged contents.
%
%   Examples:
%   data = crg_check_single(data);
%       checks CRG core data to single type.
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
%   $Id: crg_check_single.m 184 2010-09-22 07:41:39Z jorauh $


%% remove ok flag, initialize error/warning counter

if isfield(data, 'ok')
    data = rmfield(data, 'ok');
end
ierr = 0;

%% check core vectors and arrays for single type

% core elevation grid data
if isfield(data, 'z') && ~isa(data.z, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.z')
    ierr = ierr + 1;
end
if isfield(data, 'v') && ~isa(data.v, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.v')
    ierr = ierr + 1;
end
if isfield(data, 'b') && ~isa(data.b, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.b')
    ierr = ierr + 1;
end

% core reference line data
if isfield(data, 'u') && ~isa(data.u, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.u')
    ierr = ierr + 1;
end
if isfield(data, 'p') && ~isa(data.p, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.p')
    ierr = ierr + 1;
end
if isfield(data, 's') && ~isa(data.s, 'single')
    warning('CRG:checkWarning', 'non-single type of core DATA.s')
    ierr = ierr + 1;
end

%% set ok-flag

if ierr == 0
    data.ok = 0;
end

end
