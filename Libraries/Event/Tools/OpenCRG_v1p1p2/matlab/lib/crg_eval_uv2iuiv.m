function [iu, iv] = crg_eval_uv2iuiv(data, u, v)
%CRG_UV2IUIV CRG evaluate index iu, iv of distance u,v.
%   [IU, IV] = CRG_UV2IUIV(DATA, U, V) transforms distances in uv to
%   index iu,iv.
%
%   Inputs:
%       DATA    struct array as defined in CRG_INTRO.
%       U       (np, 1) array of u-values in uv system
%       V       (np, 1) array of v-values in uv system
%
%   Outputs:
%       IU      (np, 1) array of u-index positions in uv system
%       IV      (np, 1) array of v-index positions in uv system
%
%   Examples:
%   [iu, iv] = crg_eval_uv2iuiv(data, u, v) transforms uv distance
%   to index positions, so that the range of u,v is always included.
%   The index positions are clipped to 1  and length(u) or length(v).
%
%   See also CRG_INTRO.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - Holger Helmich
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
%   $Id: crg_eval_uv2iuiv.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% for closed refline: map u values to valid interval

if data.opts.rflc==1 && data.dved.ulex~=0
    u = mod(u-data.dved.ubex, data.dved.ulex) + data.dved.ubex;
end

%% simplify data access

[nu, nv] = size(data.z);

ubeg = data.head.ubeg;
uinc = data.head.uinc;

if isfield(data.head, 'vinc')
    vmin = data.head.vmin;
    vmax = data.head.vmax;
    vinc = data.head.vinc;
else
    vmin = data.head.vmin;
    vmax = data.head.vmax;
end

%% find u-index positions iu

iu = max((u-ubeg)./uinc, 0);
iu = min(floor(iu+1), nu);

%% find v-index positions iv

if ~exist('v','var'), return; end

if isfield(data.head, 'vinc')
    iv = max((v-vmin)./vinc, 0);
    iv = min(floor(iv+1), nv);
else
    iv = max(v, vmin);
    iv = min(iv, vmax);
    for i = 1:length(iv)
        idx = max(find(data.v <= iv(i), 1, 'last'), 1);
        if isempty(idx)
            iv(i) = 1;
        else
            iv(i) = idx;
        end
    end
end

end %function crg_eval_uv2iuiv
