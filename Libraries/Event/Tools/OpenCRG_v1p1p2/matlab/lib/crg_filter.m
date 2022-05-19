function [data] = crg_filter(data, iu, iv, fm, mask, wopt)
% CRG_FILTER filters crg data in uv.
%   DATA = CRG_FILTER(DATA, IU, IV, FM, MASK, WOPT) applies filtermask on
%   CRG data.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   IU      U index for cut selection (default: full CRG)
%           IU(1): longitudinal start index
%           IU(2): longitudinal end index
%   IV      V index for cut selection (default: full CRG)
%           IV(1): lateral start index
%           IV(2): lateral end index
%   FM      filter method
%           'mean':     mean filter mask
%           'gauss':    gaussian filter mask
%                       'average in x and y direction'
%           'sobel':    sobel filter mask (modified)
%                       'derive 1x in x and average in y direction'
%           '2diff':    second derivation (binomial filter) (modified)
%                       derive 2x in x take the mean in y direction
%           'laplace:   laplacian filter mask (modified)
%                       'derive 2x in x and y direction'
%   MASK    size of filter mask (default: [3 3])
%           MASK(1): u-direction
%           MASK(2): v-direction
%   WOPT    optional (default: [1 1])
%           wopt(1):    weight of filter mask
%           wopt(2):    filter mask repeating factor
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_filter(data, [], [], 'mean', [5 5], [1 10])
%       filters CRG data with a 5x5 median filter mask.
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
%   $Id: crg_filter.m 41 2009-09-16 15:51:32Z hhelmich $

%% default
[nu nv] = size(data.z);

if nargin < 6, wopt = [1 1]; end
if nargin < 5 || isempty(mask), mask = [3 3]; end
if nargin < 4 || isempty(fm), fm = 'mean'; end
if nargin < 3 || isempty(iv), iv = [1 nv]; end
if nargin < 2 || isempty(iu), iu = [1 nu]; end

if length(wopt) == 1, wopt = [wopt 1]; end
if length(mask) == 1, mask = [mask mask]; end
if length(iv) == 1, iv = [1 iv]; end
if length(iu) == 1, iu = [1 iu]; end


%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% check/complement optional arguments

if iu(1)<1 || iu(1) >= iu(2) || iu(2) > nu
    error('CRG:cutError', 'illegal IU index values iu=[%d %d] with nu=%d', iu(1), iu(2), nu);
end

if iv(1)<1 || iv(1) >= iv(2) || iv(2) > nv
    error('CRG:cutError', 'illegal IV index values iv=[%d %d] with nv=%d', iv(1), iv(2), nv);
end

%% build uv

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
    v = data.v;
end

%% get base z-values

[ux, vx] = meshgrid(u, v);

z = crg_eval_uv2z(data, [ux(:), vx(:)]);

z = reshape(z, size(ux,1), size(ux,2));

clear ux vx;

%% gernerate filter mask

switch fm
    case 'mean'
        fmask = ones(mask(1), mask(2));     % filter mask ones
        fmask = fmask/sum(sum(fmask));      % normalize
        fmask = fmask*wopt(1);              % add weight
    case 'gauss'
        fmask = binf([mask(1) 0, mask(2) 0], true);
    case 'sobel'
        fmask = binf([mask(1) 0, mask(2) 1], true);
        if sum(sum(fmask)) == 0,
            fmask(round(mask(1)/2),round(mask(2)/2)) = fmask(round(mask(1)/2),round(mask(2)/2))+1;
        end
    case '2diff'
        fmask = binf([mask(1) 0, mask(2) 2], true);
        if sum(sum(fmask)) == 0,
            fmask(round(mask(1)/2),round(mask(2)/2)) = fmask(round(mask(1)/2),round(mask(2)/2))+1;
        end
    case 'laplace'
        fmask = binf([mask(1) 2, mask(2) 2], true);
        if sum(sum(fmask)) == 0,
            fmask(round(mask(1)/2),round(mask(2)/2)) = fmask(round(mask(1)/2),round(mask(2)/2))+1;
        end
end

fmask = fmask * wopt(1);                    % add factor

for i = 1:wopt(2)                           % filter multiple times
    tz = conv2(z, fmask, 'valid');
    z(round(mask(1)/2):round(mask(1)/2)+ size(tz,1)-1, ...
        round(mask(2)/2):round(mask(2)/2)+ size(tz,2)-1) = tz;
end


%% write patch back

data.z(iu(1):iu(end), iv(1):iv(end)) = z';

clear z;

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

end % function crg_filter

function [fmask, nf] = binf(koef, norm)
% BINF generate binomialfilter mask.
%   [FMASK, NF] = BINF(KOEF, NORM) builds binomial filter mask given
%   by koef.
%
%   Inputs:
%   KOEF    vector of mask length and derivative
%           koef(1): x-length
%           koef(2): derivation in x
%           koef(3): y-length
%           koef(4): derivation in y
%   NORM    [true, false]: normalisation
%
%   Outputs:
%   FMASK   filter mask
%   NF      normalization factor
%
%   Examples:
%   [famsk, nf] = binf( [3 2 3 2], true) builds 3x3 laplacian filter mask

% default
fmask = 1;
nf = 1;

% Implemtation:
% 1. convolution with [1,1] (n-k-1) times
% 2. concolution with [-1,1] k times
% 3. normalize with 1/2^(n-k-1)
for i = 1:2:length(koef)
    mask = 1;
    n = koef(i);
    k = koef(i+1);
    for j = 1:n-k-1
        mask = conv( mask, [1 1] );
    end
    for j = 1:k
        mask = conv( mask, [-1 1] );
    end
    fmask = kron( mask, fmask );
    nf = nf * 2^(-n+k+1);
end

fmask = reshape( fmask, [koef(1) koef(3)]);

if norm     % normalization
    fmask = fmask * nf;
end

end %function binf
