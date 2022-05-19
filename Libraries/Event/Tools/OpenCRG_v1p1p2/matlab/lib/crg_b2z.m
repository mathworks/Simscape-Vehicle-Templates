function [data] = crg_b2z(data, b)
% CRG_B2Z applies banking to elevation grid.
%   CRG_B2Z(DATA, B) applies a new banking to the CRG struct, which
%   may or may not already contain separated banking information.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   B       (optional) new banking (default: 0)
%           length(b) == 1: constant banking
%           length(b) == nu: variable banking
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   crg = crg_b2z(crg)
%       merges existing banking information into the elevation grid.
%   crg = crg_b2z(crg, 0.03)
%       extracts a 3.0% banking from the elevation grid
%   crg = crg_b2z(crg, b)
%       extracts banking defined by b from the elevation grid.

%   Copyright 2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_b2z.m 217 2011-02-06 19:54:42Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% evaluate DATA.z size

[nu] = size(data.z,1);

%% handle optional args

if nargin < 2 || isempty(b)
    b = 0;
end

if length(b)~=1 && length(b)~=nu
    error('CRG:b2zError', 'illegal size of B')
end

%% build full v vector

if isfield(data.head, 'vinc')
    vmin = data.head.vmin;
    vmax = data.head.vmax;
    vinc = data.head.vinc;
    v = vmin:vinc:vmax;
else
    v = double(data.v);
end

%% get old banking

if isfield(data, 'b')
    if length(data.b) == 1
        bold = data.head.bbeg*ones(1, nu);
    else
        bold = double(data.b);
    end
else
    bold = zeros(1, nu);
end

%% put new banking

data.head.bbeg = b(1);
data.head.bend = b(end);

data.b = single(b);

if length(b) == 1
    bnew = data.head.bbeg*ones(1, nu);
else
    bnew = double(data.b);
end

%% apply new banking

for i = 1:nu
    zd = (bold(i)-bnew(i)) .* v;
    data.z(i,:) = single(double(data.z(i,:)) + zd);
end

%% check data

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end
