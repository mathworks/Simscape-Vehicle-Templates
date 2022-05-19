function [ data ] = crg_limiter( data, mmlim, iu, iv )
% CRG_LIMITER limits z-values of a crg-file.
%   DATA = CRG_LIMITER( DATA, MMLIM, IU, IV ) limits z-values.
%
%   Inputs:
%   DATA        struct array as defined in CRG_INTRO
%   MMLIM       minimal, maximal limits of z values
%               MMLIM(1): minimum limit
%               MMLIM(2): maximum limit
%   IU          U index for separate selection (default: full CRG)
%               IU(1): longitudinal start index
%               IU(2): longitudinal end index
%   IV          V index for separate selection (default: full CRG)
%               IV(1): lateral start index
%               IV(2): lateral end index
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_limiter( data, mmlim, iu, iv )
%       limits z-values.
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
%   $Id: crg_limiter.m 23 2009-08-21 10:25:32Z helmich $

%% default

[nu nv] = size(data.z);

if nargin < 4 || isempty(iv), iv = [1 nv];      end
if nargin < 3 || isempty(iu), iu = [1 nu];      end

if length(iv) < 2, iv = [iv nv];                end
if length(iu) < 2, iu = [iu nu];                end
if length(mmlim) <2, mmlim = [mmlim mmlim];     end

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
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

%% cut off limits

[XI, YI] = meshgrid(u,v);

z = crg_eval_uv2z(data, [XI(:), YI(:)]);

z = reshape(z, size(XI, 1), size(XI, 2));

z(z < mmlim(1)) = mmlim(1);
z(z > mmlim(2)) = mmlim(2);

data.z(iu(1):iu(2), iv(1):iv(end)) = z';

%% delete slope/banking

if isfield(data, 's')
    data = rmfield(data, 's');
    data.head = rmfield(data.head, 'sbeg');
    data.head = rmfield(data.head, 'send');
end

if isfield(data, 'b')
    data = rmfield(data, 'b');
    data.head = rmfield(data.head, 'bbeg');
    data.head = rmfield(data.head, 'bend');
end

%% check

data = crg_single(data);

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end % function crg_limiter( data, mmlim, iu, iv )
