function [ data ] = crg_map_uv2uv( data, crg_uv, iu, iv )
%CRG_MAP_UV2UV mapping crg-z-values in u,v to crg-file
%   [DATA] = CRG_MAP_UV2UV(DATA, CRG_UV, IU, IV) mapps z-values of CRG_UV
%   in u,v to DATA in uv
%
%   Inputs:
%   DATA        struct array as defined in CRG_INTRO
%   CRG_UV      struct array as defined in CRG_INTRO
%   IU          U index for separate selection (default: full CRG)
%               IU(1): longitudinal start index
%               IU(2): longitudinal end index
%   IV          V index for separate selection (default: full CRG)
%               IV(1): lateral start index
%               IV(2): lateral end index
%
%   Outputs:
%   DATA        struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_map_uv2uv(data, crg_uv, iu, iv) mapps z-values from
%   crg_uv to data in uv in range of iu/iv.
%
%   See also CRG_INTRO

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
%   $Id: crg_map_uv2uv 2009-08-15 12:17:00Z helmich $

%% default

[nu nv] = size(data.z);

if nargin < 4 || isempty(iv), iv = [1 nv];         end
if nargin < 3 || isempty(iu), iu = [1 nu];         end

if length(iv) < 2, iv = [iv nv];                   end
if length(iu) < 2, iu = [iu nu];                   end

ceps = data.opts.ceps;
ctol = data.opts.ctol;

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of CRG was not completely successful')
    end
end

if ~isfield(crg_uv, 'ok')
    crg_uv = crg_check(crg_uv);
    if ~isfield(crg_uv, 'ok')
        error('CRG:checkError', 'check of CRG_UV was not completely successful')
    end
end

if length(iu) < 1 || length(iu) > 2
    error('CRG:checkError', 'check of u-spacing was not successful')
end

if length(iv) < 1 || length(iv) > 2
    error('CRG:checkError', 'check of v-spacing was not successful')
end

%% build base uv

ubeg = data.head.ubeg + data.head.uinc*(iu(1)-1);
uend = data.head.ubeg + data.head.uinc*(iu(2)-1);
uinc = data.head.uinc;
u = ubeg:uinc:uend;

if isfield(data.head, 'vinc')
    vmin = data.head.vmin + data.head.vinc*(iv(1)-1);
    vmax = data.head.vmin + data.head.vinc*(iv(2)-1);
    vinc = data.head.vinc;
    v = vmin:vinc:vmax;
else
    v = data.v(iv(1):iv(2));
end

%% get base z-values

[ux, vx] = meshgrid(u, v);

z = crg_eval_uv2z(data, [ux(:), vx(:)]);

[xnu, xnv] = size(ux);
z = reshape(z, xnu, xnv);

clear ux vx;

%% rerender crg_uv for equal space

if abs(uinc - crg_uv.head.uinc) > max(ceps*(uinc + data.head.uinc), ctol)
   tuinc = uinc;
end

if isfield(crg_uv.head, 'vinc')
    if isfield(data.head, 'vinc')
        if abs(data.head.vinc - crg_uv.head.vinc) > max(ceps*(data.head.vinc + data.head.vinc), ctol)
            tvinc = data.head.vinc;
        end
    else
        tvinc = data.v;
    end
else
    if isfield(data.head, 'vinc')
        tvinc = data.head.vinc;
    elseif abs(data.v - crg_uv.v) > max(ceps*(data.v + data.v), ctol);
            tvinc = data.v;
    end
end

if exist('tuinc', 'var') && exist('tvinc', 'var')
    crg = crg_rerender(crg_uv, [tuinc tvinc]);
elseif exist('tuinc', 'var')
    crg = crg_rerender(crg_uv, tuinc);
elseif exist('tvinc', 'var')
    crg = crg_rerender(crg_uv, [uinc, tvinc]);
else
    crg = crg_uv;
end

%% build adding uv grid

cubeg = crg.head.ubeg;
cuend = crg.head.uend;
cuinc = crg.head.uinc;
cu = cubeg:cuinc:cuend;

if isfield(crg.head, 'vinc')
    cvmin = crg.head.vmin;
    cvmax = crg.head.vmax;
    cvinc = crg.head.vinc;
    cv = cvmin:cvinc:cvmax;
else
    cv = crg.v;
end

%% get adding z-values

[cux, cvx] = meshgrid(cu, cv);

cz = crg_eval_uv2z(crg, [cux(:), cvx(:)]);

[cxnu, cxnv] = size(cux);
cz = reshape(cz, cxnu, cxnv);

clear cux cvx;

%% add z-values

if xnu > cxnu                           % repeat horizontal
    cz = repmat(cz, ceil(xnu/cxnu),1);
end
if xnv > cxnv                           % repeat vertical
    cz = repmat(cz, 1, ceil(xnv/cxnv));
end
cz = cz(1:xnu,1:xnv);                   % limit cz to size of z

data.z(iu(1):iu(end),iv(1):iv(end)) = (cz + z)';

%% check

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of data was not completely successful')
end

end % function crg_map_uv2u(data, crg_uv, iu, iv)
